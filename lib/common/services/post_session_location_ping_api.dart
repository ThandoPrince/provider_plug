import 'dart:convert';
import 'package:flutter_application_2/common/models/models/order_service_models/session_location_ping_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class SessionLocationPingApi {
  static final String _baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  static Map<String, String> _headers() => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Future<SessionLocationPingModel> postPing({
    required int sessionId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/bookings/sessions/geofence_check/$sessionId/',
    );

    final payload = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
    };

    final response = await http.post(
      uri,
      headers: _headers(),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return SessionLocationPingModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw HttpException(
      'Ping failed (${response.statusCode})',
      response.body,
    );
  }
}

class HttpException implements Exception {
  final String message;
  final String responseBody;

  HttpException(this.message, this.responseBody);

  @override
  String toString() =>
      '$message → $responseBody';
}
