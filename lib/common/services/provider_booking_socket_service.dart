import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

class ProviderBookingSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;

  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  String? _lastConnectedEmail;
  bool _isExplicitlyDisconnected = false;

  void Function(Map<String, dynamic> data)? onMessage;
  void Function()? onConnected;
  void Function()? onDisconnected;
  void Function(Object error)? onError;

  /// Establishes an authenticated WebSocket connection.
  Future<void> connect(String email) async {
    _isExplicitlyDisconnected = false;
    _lastConnectedEmail = email;
    _cancelReconnectTimer();
    disconnect(isExplicitDisconnect: false);

    final rawBaseUrl = (dotenv.env['API_BASE_URL'] ?? '').trim();
    if (rawBaseUrl.isEmpty) {
      throw Exception('API_BASE_URL is missing from environment variables.');
    }

    final baseUri = Uri.parse(rawBaseUrl);
    final encodedEmail = Uri.encodeComponent(email.trim().toLowerCase());
    final wsScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';
    
    // Pull JWT token from the session storage singleton
    final String? token = AuthSessionController.instance.accessToken;

    final wsUri = Uri(
      scheme: wsScheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: '/ws/provider-bookings/$encodedEmail/',
      queryParameters: {
        if (token != null && token.isNotEmpty) 'token': token,
      },
    );

    if (kDebugMode) {
      print('📡 Connecting WebSocket to: $wsUri');
    }

    try {
      _channel = WebSocketChannel.connect(wsUri);
      
      _subscription = _channel!.stream.listen(
        (message) {
          if (!_isConnected) {
            _isConnected = true;
            onConnected?.call();
          }

          if (kDebugMode) {
            print('📨 WS Received: $message');
          }

          try {
            final dynamic decoded = jsonDecode(message.toString());
            if (decoded is Map) {
              onMessage?.call(Map<String, dynamic>.from(decoded));
            }
          } catch (e) {
            if (kDebugMode) {
              print('❌ WS JSON Parsing Error: $e');
            }
          }
        },
        onError: (error) {
          _isConnected = false;
          if (kDebugMode) {
            print('❌ WS Connection Error: $error');
          }
          onError?.call(error);
          _handleAutoReconnect();
        },
        onDone: () {
          _isConnected = false;
          if (kDebugMode) {
            print('🔌 WS Connection Closed');
          }
          onDisconnected?.call();
          _handleAutoReconnect();
        },
        cancelOnError: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ WS Initialization failed: $e');
      }
      _handleAutoReconnect();
    }
  }

  /// Sends a heartbeat payload to maintain the connection.
  void sendPing() {
    if (_channel == null || !_isConnected) return;
    try {
      _channel!.sink.add(jsonEncode({"type": "ping"}));
    } catch (_) {}
  }

  /// Disconnects the socket state completely.
  void disconnect({bool isExplicitDisconnect = true}) {
    if (isExplicitDisconnect) {
      _isExplicitlyDisconnected = true;
      _cancelReconnectTimer();
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

  void _handleAutoReconnect() {
    if (_isExplicitlyDisconnected || _lastConnectedEmail == null) return;
    _cancelReconnectTimer();

    // Reconnect attempt backoff delay (e.g., 5 seconds)
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      if (!_isConnected && !_isExplicitlyDisconnected && _lastConnectedEmail != null) {
        if (kDebugMode) {
          print('🔄 Attempting WebSocket reconnect for: $_lastConnectedEmail');
        }
        connect(_lastConnectedEmail!);
      }
    });
  }

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
}