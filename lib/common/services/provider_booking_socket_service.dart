import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ProviderBookingSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void Function(Map<String, dynamic> data)? onMessage;
  void Function()? onConnected;
  void Function()? onDisconnected;
  void Function(Object error)? onError;

  Future<void> connect(String email) async {
    disconnect();

    final rawBaseUrl = (dotenv.env['API_BASE_URL'] ?? '').trim();
    if (rawBaseUrl.isEmpty) {
      throw Exception('API_BASE_URL is missing');
    }

    final baseUri = Uri.parse(rawBaseUrl);
    final encodedEmail = Uri.encodeComponent(email.trim().toLowerCase());

    final wsScheme = baseUri.scheme == 'https' ? 'wss' : 'ws';

    final wsUri = Uri(
      scheme: wsScheme,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: '/ws/provider-bookings/$encodedEmail/',
    );

    print('Connecting websocket to: $wsUri');

    _channel = WebSocketChannel.connect(wsUri);

    _subscription = _channel!.stream.listen(
      (message) {
        if (!_isConnected) {
          _isConnected = true;
          onConnected?.call();
        }

        print('WS message: $message');

        try {
          final decoded = jsonDecode(message);
          if (decoded is Map<String, dynamic>) {
            onMessage?.call(decoded);
          }
        } catch (e) {
          print('WS decode error: $e');
        }
      },
      onError: (error) {
        _isConnected = false;
        print('WS error: $error');
        onError?.call(error);
      },
      onDone: () {
        _isConnected = false;
        print('WS disconnected');
        onDisconnected?.call();
      },
      cancelOnError: false,
    );
  }

  void sendPing() {
    if (_channel == null) return;

    try {
      _channel!.sink.add(jsonEncode({"type": "ping"}));
    } catch (_) {}
  }

  void disconnect() {
    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
  }
}