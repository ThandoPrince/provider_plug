import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

/// Marks an error as "there's no network path to the server" (no
/// connectivity, DNS failure, host unreachable) rather than a generic
/// socket/server error. Callers use this to decide not to keep retrying.
class NetworkUnavailableException implements Exception {
  final Object cause;
  NetworkUnavailableException(this.cause);

  @override
  String toString() => 'NetworkUnavailableException: $cause';
}

/// Best-effort classification. Checks typed SocketException fields first,
/// then falls back to matching on the stringified error, since some
/// network failures arrive wrapped (e.g. http package's ClientException)
/// rather than as a raw SocketException.
bool isNetworkUnavailableError(Object error) {
  const signatures = <String>[
    'network is unreachable',
    'no route to host',
    'host is unreachable',
    'failed host lookup',
    'no address associated with hostname',
  ];

  String text;
  if (error is SocketException) {
    text = '${error.message} ${error.osError?.message ?? ''}'.toLowerCase();
  } else {
    text = error.toString().toLowerCase();
  }

  return signatures.any(text.contains);
}

class ProviderBookingSocketService {
  ProviderBookingSocketService();

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  VoidCallback? onSocketReady;
  VoidCallback? onSocketLost;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isExplicitlyDisconnected = false;

  void Function(Map<String, dynamic> data)? onMessage;
  void Function()? onConnected;
  void Function()? onDisconnected;
  void Function(Object error)? onError;

  /// Establishes an authenticated WebSocket connection.
  /// Throws on failure — the caller (SPBookingController) owns retry
  /// scheduling and backoff, so this no longer reconnects itself.
  Future<void> connect() async {
    debugPrint("📡 connect() instance=${identityHashCode(this)}");
    _isExplicitlyDisconnected = false;
    disconnect(isExplicitDisconnect: false);

    final rawBaseUrl = (dotenv.env['API_BASE_URL'] ?? '').trim();

    if (rawBaseUrl.isEmpty) {
      throw Exception('API_BASE_URL is missing from environment variables.');
    }

    final baseUri = Uri.parse(rawBaseUrl);
    final wsScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    final accessToken = ApiClient.instance.getAccessToken();

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception("No access token available.");
    }

    final wsUri = Uri(
      scheme: wsScheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: '/ws/provider/',
      queryParameters: {'token': accessToken},
    );

    if (kDebugMode) {
      debugPrint("📡 Connecting Provider WebSocket: $wsUri");
    }

    try {
      _channel = WebSocketChannel.connect(wsUri);

      _subscription = _channel!.stream.listen(
        (message) {
          debugPrint("RAW SOCKET MESSAGE: $message");
          if (!_isConnected) {
            _isConnected = true;
            onConnected?.call();
            onSocketReady?.call();
          }

          try {
            final decoded = jsonDecode(message.toString());
            if (decoded is Map<String, dynamic>) {
              onMessage?.call(decoded);
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint("❌ Failed to decode websocket message: $e");
            }
          }
        },
        onError: (error) {
          _isConnected = false;
          if (kDebugMode) debugPrint("❌ Provider websocket error: $error");
          // Classify here, at the source — this is where raw connectivity
          // failures (DNS failure, unreachable network/host) actually
          // surface, since WebSocketChannel.connect() itself doesn't throw
          // synchronously for those.
          final reportedError = isNetworkUnavailableError(error)
              ? NetworkUnavailableException(error)
              : error;
          onError?.call(reportedError);
        },
        onDone: () {
          _isConnected = false;
          if (kDebugMode) debugPrint("🔌 Provider websocket disconnected.");
          onDisconnected?.call();
          onSocketLost?.call();
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (kDebugMode) debugPrint("❌ Failed to connect provider websocket: $e");
      throw isNetworkUnavailableError(e) ? NetworkUnavailableException(e) : e;
    }
  }

  Future<void> sendLocation({
    required double latitude,
    required double longitude,
  }) async {
    if (!_isConnected || _channel == null) return;

    try {
      _channel!.sink.add(
        jsonEncode({
          "type": "location_update",
          "latitude": latitude,
          "longitude": longitude,
        }),
      );
    } catch (e) {
      if (kDebugMode) debugPrint("Failed to send provider location: $e");
    }
  }

  void sendPing() {
    if (_channel == null || !_isConnected) return;
    try {
      _channel!.sink.add(jsonEncode({"type": "ping"}));
    } catch (_) {}
  }

  /// Reconnects after refreshing the access token. Use this after a couple
  /// of plain `connect()` failures in a row — that pattern usually means
  /// the token expired rather than a one-off network blip.
  Future<void> reconnectWithTokenRefresh() async {
    if (_isExplicitlyDisconnected) {
      throw Exception("Socket explicitly disconnected.");
    }

    disconnect(isExplicitDisconnect: false);

    debugPrint("🔄 Refreshing websocket access token...");

    String? token;
    try {
      token = await ApiClient.instance.refreshToken();
    } catch (e) {
      // Refreshing the token is itself a network call — classify failures
      // here too, otherwise a network-unavailable refresh looks like an
      // expired-token failure to the caller.
      throw isNetworkUnavailableError(e) ? NetworkUnavailableException(e) : e;
    }

    if (token == null) {
      debugPrint("❌ Refresh token expired.");
      await AuthSessionController.instance.clearSession();
      throw Exception("Session expired. Please log in again.");
    }

    debugPrint("✅ Access token refreshed.");
    await connect();
  }

  /// Disconnects the socket state completely.
  void disconnect({bool isExplicitDisconnect = true}) {
    if (isExplicitDisconnect) {
      _isExplicitlyDisconnected = true;
    }

    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect(isExplicitDisconnect: true);
  }
}