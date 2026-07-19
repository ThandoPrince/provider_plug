import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

class ProviderBookingSocketService {

  ProviderBookingSocketService() {
  
}

  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
VoidCallback? onSocketReady;
VoidCallback? onSocketLost;
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  String? _lastConnectedEmail;
  bool _isExplicitlyDisconnected = false;

  void Function(Map<String, dynamic> data)? onMessage;
  void Function()? onConnected;
  void Function()? onDisconnected;
  void Function(Object error)? onError;
  

  /// Establishes an authenticated WebSocket connection.
  Future<void> connect() async {

    debugPrint(
  "📡 connect() instance=${identityHashCode(this)}",
);
  _isExplicitlyDisconnected = false;
  _cancelReconnectTimer();
  disconnect(isExplicitDisconnect: false);

  final rawBaseUrl = (dotenv.env['API_BASE_URL'] ?? '').trim();

  if (rawBaseUrl.isEmpty) {
    throw Exception(
      'API_BASE_URL is missing from environment variables.',
    );
  }

  final baseUri = Uri.parse(rawBaseUrl);

  final wsScheme =
      baseUri.scheme == 'https'
          ? 'wss'
          : 'ws';

  final accessToken = ApiClient.instance.getAccessToken();

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception("No access token available.");
  }

  final wsUri = Uri(
    scheme: wsScheme,
    host: baseUri.host,
    port: baseUri.hasPort ? baseUri.port : null,
    path: '/ws/provider/',
    queryParameters: {
      'token': accessToken,
    },
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
          debugPrint("onMessage null? ${onMessage == null}");

          if (decoded is Map<String, dynamic>) {
            onMessage?.call(decoded);
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint("❌ Failed to decode websocket message: $e");
          }
        }
      },
      onError: (error) async {
        _isConnected = false;

        if (kDebugMode) {
          debugPrint("❌ Provider websocket error: $error");
        }

        onError?.call(error);

        _handleAutoReconnect();
      },
      onDone: () {
        _isConnected = false;

        if (kDebugMode) {
          debugPrint("🔌 Provider websocket disconnected.");
        }

        onDisconnected?.call();
        onSocketLost?.call();

        _handleAutoReconnect();
      },
      cancelOnError: false,
    );
  } catch (e) {
    if (kDebugMode) {
      debugPrint("❌ Failed to connect provider websocket: $e");
    }

    _handleAutoReconnect();
  }
}

Future<void> sendLocation({
  required double latitude,
  required double longitude,
}) async {

  debugPrint(
  "📤 sendLocation() instance=${identityHashCode(this)} connected=$_isConnected",
);
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
    if (kDebugMode) {
      debugPrint("Failed to send provider location: $e");
    }
  }
}

  /// Sends a heartbeat payload to maintain the connection.
  void sendPing() {
    debugPrint(
  "🏓 ping instance=${identityHashCode(this)}",
);
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
  if (_isExplicitlyDisconnected) return;

  _cancelReconnectTimer();

  _reconnectTimer = Timer(
    const Duration(seconds: 5),
    () async {
      if (_isConnected || _isExplicitlyDisconnected) {
        return;
      }

      try {
        // Triggers token refresh if the current access token has expired.
        await ApiClient.instance.request(
          (token) async => http.Response('', 200),
        );

        await connect();
      } catch (e) {
        if (kDebugMode) {
          debugPrint("❌ Provider websocket reconnect failed: $e");
        }

        _handleAutoReconnect();
      }
    },
  );
}

  void _cancelReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
}


