import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UpdateSpLocationApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Updates the service provider's live tracking coordinates on the backend.
  static Future<bool> updateServiceProviderLocation({
    required String spEmail,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await ApiClient.instance.request(
        (token) => http.post(
          Uri.parse(
            '$baseUrl/api/service_providersDB/update_sp_live_location/',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'sp_email': spEmail.trim().toLowerCase(),
            'latitude': latitude,
            'longitude': longitude,
          }),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      throw ApiException(
        data['detail'] ??
            data['message'] ??
            data['error'] ??
            'Failed to update service provider location.',
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        'Invalid response received from the server.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ UpdateSpLocationApi: $e');
      }

      throw const ApiException(
        'Failed to update service provider location.',
      );
    }
  }
}