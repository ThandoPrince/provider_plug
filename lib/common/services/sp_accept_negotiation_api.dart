import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';

class AcceptNegotiationApi {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Calls the provider_accept_negotiation endpoint.
  static Future<Map<String, dynamic>> acceptNegotiationById(
    int negotiationId,
  ) async {
    try {
      final response = await ApiClient.instance.request(
        (token) => http.post(
          Uri.parse(
            '$_baseUrl/bookings/service_orders/negotiation/provider_accepts_negotiation/$negotiationId/',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      final dynamic decodedBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;

      final Map<String, dynamic> responseData =
          decodedBody is Map
              ? Map<String, dynamic>.from(decodedBody)
              : {};

      if (response.statusCode == 200) {
        return responseData;
      }

      if (kDebugMode) {
        print(
          '❌ NEGOTIATION ACCEPTANCE REJECTED '
          '[${response.statusCode}]: ${response.body}',
        );
      }

      throw ApiException(
        responseData['detail'] ??
            responseData['message'] ??
            responseData['error'] ??
            'Failed to accept negotiation.',
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        'Invalid response received from the server.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in AcceptNegotiationApi: $e');
      }

      throw const ApiException(
        'Failed to accept negotiation.',
      );
    }
  }
}