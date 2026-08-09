import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DeactivateProviderServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<bool> deactivateProviderService({
    required int providerServiceId,
  }) async {
    try {
      final response = await ApiClient.instance.request(
        (token) => http.patch(
          Uri.parse(
            '$baseUrl/providers/provider-services/$providerServiceId/deactivate/',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return true;
      }

      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      throw ApiException(
        data['detail'] ??
            data['message'] ??
            data['error'] ??
            'Unable to remove linked service.',
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        'Invalid response received from the server.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ DeactivateProviderServiceApi: $e');
      }

      throw const ApiException(
        'Unable to remove linked service.',
      );
    }
  }
}