import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


import 'package:flutter_application_2/common/models/models/order_service_models/session_location_ping_model.dart';

class SessionLocationPingApi {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Dispatches precise provider telemetry metrics to verify booking geofence boundaries
  static Future<SessionLocationPingModel> postPing({
    required int sessionId,
    required double latitude,
    required double longitude,
    double? accuracy,
    String? travelMode,
  }) async {
    final uri =
        Uri.parse('$_baseUrl/bookings/sessions/geofence_check/$sessionId/');

    final payload = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (travelMode != null) 'travel_mode': travelMode,
    };

    try {
      final response = await ApiClient.instance.request(
        (token) => http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decodedBody = jsonDecode(response.body);

        if (decodedBody is Map) {
          return SessionLocationPingModel.fromJson(
            Map<String, dynamic>.from(decodedBody),
          );
        }

        throw const FormatException(
          'Expected JSON map schema container in geofence verification response.',
        );
      }

      if (kDebugMode) {
        print(
          '❌ GEOFENCE PING REJECTED [${response.statusCode}]: ${response.body}',
        );
      }

      throw HttpException(
        'Ping failed (${response.statusCode})',
        response.body,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in SessionLocationPingApi: $e');
      }

      if (e is HttpException) rethrow;

      throw HttpException(
        'Network or telemetry processing error',
        e.toString(),
      );
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