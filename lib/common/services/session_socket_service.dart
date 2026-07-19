import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_location_ping_model.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_route_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Production session WebSocket client.
///
/// On top of the original connect/listen/reconnect loop this adds:
///  - Application-level heartbeat (ping/pong) with a pong watchdog, so a
///    connection that's silently dead (idle proxy/NAT drop) is detected
///    instead of `isConnected` staying stuck `true` forever.
///  - A connect timeout via `channel.ready`, so a hung handshake doesn't
///    leave the service "connecting" indefinitely.
///  - A guard against overlapping connect() calls.
///  - Exponential backoff with jitter for reconnects (capped), instead of
///    a fixed 5s retry that can hammer the server.
///  - Idempotent disconnect handling so onDone/onError can't both fire a
///    double "disconnected" notification / double reconnect schedule.
///  - A real dispose() that stops all retries permanently.
class SessionSocketService {
  SessionSocketService({
    this.heartbeatInterval = const Duration(seconds: 20),
    this.pongTimeout = const Duration(seconds: 8),
    this.connectTimeout = const Duration(seconds: 10),
    this.maxReconnectDelay = const Duration(seconds: 30),
    this.maxRetries, // null = retry indefinitely (capped delay via backoff)
  });

  /// How often to ping the server once connected.
  final Duration heartbeatInterval;

  /// How long to wait for a pong before treating the connection as dead.
  final Duration pongTimeout;

  /// How long to wait for the WS handshake to complete before giving up.
  final Duration connectTimeout;

  /// Ceiling for the exponential backoff delay between reconnect attempts.
  final Duration maxReconnectDelay;

  /// Max consecutive reconnect attempts. Null means retry forever (with a
  /// capped delay) — appropriate for a session-level socket.
  final int? maxRetries;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  Timer? _pongTimeoutTimer;

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isExplicitlyDisconnected = false;
  bool _isDisposed = false;

  int? _shipmentId;
  int _retryCount = 0;
  final Random _rng = Random();

  bool get isConnected => _isConnected;

  void Function(Map<String, dynamic>)? onMessage;
  VoidCallback? onConnected;
  VoidCallback? onDisconnected;
  void Function(Object error)? onError;

  //--------------------------------------------------------
  // CONNECT
  //--------------------------------------------------------

  Future<void> connect({required int shipmentId}) async {
    if (_isDisposed) {
      if (kDebugMode) {
        debugPrint('SessionSocketService: connect() called after dispose().');
      }
      return;
    }

    _shipmentId = shipmentId;
    _isExplicitlyDisconnected = false;
    _retryCount = 0;

    _cancelReconnectTimer();
    await _teardownChannel();

    await _connectInternal();
  }

  Future<void> _connectInternal() async {
    if (_isConnecting || _isExplicitlyDisconnected || _isDisposed) return;
    if (_shipmentId == null) return;

    _isConnecting = true;

    try {
      final rawBaseUrl = (dotenv.env['API_BASE_URL'] ?? '').trim();

      if (rawBaseUrl.isEmpty) {
        throw Exception('API_BASE_URL missing.');
      }

      final baseUri = Uri.parse(rawBaseUrl);

      final accessToken = ApiClient.instance.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token.');
      }

      final wsUri = Uri(
        scheme: baseUri.scheme == 'https' ? 'wss' : 'ws',
        host: baseUri.host,
        port: baseUri.hasPort ? baseUri.port : null,
        path: '/ws/session/$_shipmentId/',
        queryParameters: {'token': accessToken},
      );

      debugPrint('📡 Session websocket -> $wsUri');

      final channel = WebSocketChannel.connect(wsUri);

      // Requires web_socket_channel >=2.4.0. Bounds how long we'll wait
      // for the handshake instead of "connecting" hanging forever.
      await channel.ready.timeout(connectTimeout);

      if (_isExplicitlyDisconnected || _isDisposed) {
        unawaited(channel.sink.close());
        return;
      }

      _channel = channel;
      _retryCount = 0;
      _isConnected = true;

      onConnected?.call();

      _subscription = channel.stream.listen(
        _handleMessage,
        onDone: () => _handleDisconnect(),
        onError: (error) => _handleDisconnect(error: error),
        cancelOnError: true,
      );

      _startHeartbeat();
    } catch (e) {
      debugPrint('❌ Session socket connect failed: $e');
      await _teardownChannel();
      onError?.call(e);
      _scheduleReconnect();
    } finally {
      _isConnecting = false;
    }
  }

  //--------------------------------------------------------
  // MESSAGE HANDLING
  //--------------------------------------------------------

  void _handleMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message as String);

      if (decoded is! Map<String, dynamic>) return;

      switch (decoded["type"]) {
  case "pong":
    _onPongReceived();
    return;

  case "ping":
    _send({"type": "pong"});
    return;

  case "geofence_ping_ack":
  final data = decoded["data"];

  if (data is Map<String, dynamic>) {
    final ping = SessionLocationPingModel.fromJson(data);

    if (kDebugMode) {
      debugPrint(
        "📍 Geofence: "
        "inside=${ping.insideGeofence}, "
        "distance=${ping.distanceFromSiteMeters}m",
      );
    }
  }
  break;
}

onMessage?.call(decoded);


    } catch (_) {
      // Ignore malformed frames.
    }
  }

  Future<void> sendRouteUpdate(ShipmentRoute route) async {
    debugPrint('📡 sendRouteUpdate() called');
    debugPrint('   connected=$_isConnected');
    debugPrint('   channel=${_channel != null}');
    debugPrint('   shipmentId=${route.shipmentId}');

    if (!_isConnected || _channel == null) {
      debugPrint('❌ Cannot send route update. Socket is not connected.');
      return;
    }

    final payload = {
      'type': 'route_update',
      'origin_lat': route.originLat,
      'origin_lng': route.originLng,
      'destination_lat': route.destinationLat,
      'destination_lng': route.destinationLng,
      'distance_meters': route.distanceMeters,
      'duration_seconds': route.durationSeconds,
      'geometry': route.geometry,
      'recalculated': route.recalculated,
    };

    debugPrint('📤 Sending route update:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(payload));

    if (_send(payload)) {
      debugPrint('✅ Route update sent successfully.');
    } else {
      debugPrint('❌ Failed to send route update.');
    }
  }

  Future<void> sendGeofencePing({
  required double latitude,
  required double longitude,
  required double accuracy,
}) async {
  if (!_isConnected || _channel == null) {
    debugPrint("❌ Cannot send geofence ping. Socket not connected.");
    return;
  }

  final payload = {
    "type": "geofence_ping",
    "latitude": latitude,
    "longitude": longitude,
    "accuracy": accuracy
  };

  if (kDebugMode) {
    debugPrint("📤 Sending geofence ping");
    debugPrint(const JsonEncoder.withIndent("  ").convert(payload));
  }

  _send(payload);
}

  /// Manually trigger a ping. Mostly useful for tests/debugging — the
  /// heartbeat timer calls this automatically while connected.
  void sendPing() => _send({'type': 'ping'});

  bool _send(Map<String, dynamic> payload) {
    if (!_isConnected || _channel == null) return false;
    try {
      _channel!.sink.add(jsonEncode(payload));
      return true;
    } catch (e) {
      debugPrint('❌ Session socket send failed: $e');
      return false;
    }
  }

  //--------------------------------------------------------
  // HEARTBEAT
  //--------------------------------------------------------

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) => _sendHeartbeatPing());
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = null;
  }

  void _sendHeartbeatPing() {
    if (!_send({'type': 'ping'})) {
      _handleDisconnect();
      return;
    }

    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = Timer(pongTimeout, () {
      debugPrint('⚠️ Session socket heartbeat timeout: no pong received.');
      _handleDisconnect();
    });
  }

  void _onPongReceived() {
    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = null;
  }

  //--------------------------------------------------------
  // DISCONNECT (internal, from a dead/closed socket)
  //--------------------------------------------------------

  /// Idempotent: safe to call from onDone, onError, and the heartbeat
  /// watchdog without triggering duplicate notifications/reconnects.
  void _handleDisconnect({Object? error}) {
    if (!_isConnected && _channel == null) return;

    _isConnected = false;
    _stopHeartbeat();

    unawaited(_teardownChannel());

    if (error != null) {
      onError?.call(error);
    }

    onDisconnected?.call();

    _scheduleReconnect();
  }

  Future<void> _teardownChannel() async {
    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close();
    _channel = null;
  }

  //--------------------------------------------------------
  // RECONNECT
  //--------------------------------------------------------

  void _scheduleReconnect() {
    if (_isExplicitlyDisconnected || _isDisposed || _shipmentId == null) return;

    if (maxRetries != null && _retryCount >= maxRetries!) {
      debugPrint('Session socket: max reconnect attempts reached, giving up.');
      return;
    }

    _retryCount++;

    final baseDelayMs = min(
      1000 * pow(2, _retryCount - 1).toInt(),
      maxReconnectDelay.inMilliseconds,
    );
    final jitterMs = (baseDelayMs * 0.3 * (_rng.nextDouble() * 2 - 1)).toInt();
    final delayMs = (baseDelayMs + jitterMs).clamp(1000, maxReconnectDelay.inMilliseconds);

    _cancelReconnectTimer();
    _reconnectTimer = Timer(Duration(milliseconds: delayMs), _attemptReconnect);
  }


  

  Future<void> _attemptReconnect() async {
    if (_isExplicitlyDisconnected || _isDisposed || _isConnected) return;

    try {
      // Best-effort: gives ApiClient a chance to refresh the auth token
      // (if it does so as a side effect of wrapped requests) before we
      // try to re-open the socket with it.
      await ApiClient.instance.request((token) async => http.Response('', 200));
    } catch (_) {
      // Ignore — still attempt to reconnect with whatever token we have.
    }

    await _connectInternal();
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  //--------------------------------------------------------
  // DISCONNECT / DISPOSE (external)
  //--------------------------------------------------------

  /// Closes the connection and stops retrying. The service can be reused
  /// afterwards via connect().
  Future<void> disconnect({bool isExplicitDisconnect = true}) async {
    if (isExplicitDisconnect) {
      _isExplicitlyDisconnected = true;
      _cancelReconnectTimer();
    }

    _isConnected = false;
    _stopHeartbeat();

    await _teardownChannel();
  }

  /// Permanently shuts the service down. Call from State.dispose(). After
  /// calling this, connect() is a no-op.
  void dispose() {
    _isDisposed = true;
    unawaited(disconnect());
    onMessage = null;
    onConnected = null;
    onDisconnected = null;
    onError = null;
  }
}