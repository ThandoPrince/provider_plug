import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_location_ping_model.dart';

class SessionLocationPingApi {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Generates request headers containing valid runtime authorization metadata
  static Map<String, String> _headers() {
    final String? token = AuthSessionController.instance.accessToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// POST: Dispatches precise provider telemetry metrics to verify booking geofence boundaries
  static Future<SessionLocationPingModel> postPing({
    required int sessionId,
    required double latitude,
    required double longitude,
    double? accuracy,
    String? travelMode,
  }) async {
    final uri = Uri.parse('$_baseUrl/bookings/sessions/geofence_check/$sessionId/');

    final payload = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (travelMode != null) 'travel_mode': travelMode,
    };

    try {
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10)); // Prevent background location queues from stalling

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decodedBody = jsonDecode(response.body);
        if (decodedBody is Map) {
          return SessionLocationPingModel.fromJson(Map<String, dynamic>.from(decodedBody));
        }
        throw const FormatException('Expected JSON map schema container in geofence verification response.');
      }

      if (kDebugMode) {
        print('❌ GEOFENCE PING REJECTED [${response.statusCode}]: ${response.body}');
      }
      throw HttpException('Ping failed (${response.statusCode})', response.body);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in SessionLocationPingApi: $e');
      }
      if (e is HttpException) rethrow;
      throw HttpException('Network or telemetry processing error', e.toString());
    }
  }
}

class HttpException implements Exception {
  final String message;
  final String responseBody;

  HttpException(this.message, this.responseBody);

  @override
  String toString() => '$message → $responseBody';
}