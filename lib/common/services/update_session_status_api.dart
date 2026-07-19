import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UpdateSessionStatusApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// PATCH: Updates a booking session status.
  static Future<Map<String, dynamic>> updateSessionStatus({
    required int sessionId,
    required String status,
    Map<String, dynamic>? checkoutLocation,
  }) async {
    final payload = {
      'session_status': status,
      if (checkoutLocation != null)
        'checkout_location': checkoutLocation,
    };

    try {
      final response = await ApiClient.instance.request(
        (token) => http.patch(
          Uri.parse(
            '$baseUrl/bookings/sessions/$sessionId/update_status/',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          body: jsonEncode(payload),
        ),
      );

      final responseData = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return responseData;
      }

      throw ApiException(
        responseData['detail'] ??
            responseData['message'] ??
            responseData['error'] ??
            'Failed to update session status.',
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        'Invalid response received from the server.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ UpdateSessionStatusApi: $e');
      }

      throw const ApiException(
        'Failed to update session status.',
      );
    }
  }
}