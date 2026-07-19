import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/booking_item_model.dart';
import 'package:http/http.dart' as http;

class BookingItemCreationApi {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Provider accepts a negotiation.
  static Future<AcceptNegotiationResponse> acceptNegotiation({
    required int negotiationId,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/bookings/service_orders/negotiation/provider_accepts_negotiation/$negotiationId/',
    );

    try {
      final response = await ApiClient.instance.request(
        (token) {
          return http.post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          );
        },
      );

      switch (response.statusCode) {
        case 200:
          final decoded = jsonDecode(response.body);

          if (decoded is! Map<String, dynamic>) {
            throw const FormatException(
              'Expected a JSON object.',
            );
          }

          return AcceptNegotiationResponse.fromJson(decoded);

        case 400:
          throw Exception(
            'The negotiation request is invalid.',
          );

        case 401:
          // Normally never reached because ApiClient handles refresh.
          throw Exception(
            'Authentication failed.',
          );

        case 403:
          throw Exception(
            'You are not allowed to accept this negotiation.',
          );

        case 404:
          throw Exception(
            'Negotiation not found.',
          );

        case 409:
          throw Exception(
            'This negotiation has already been accepted or is no longer available.',
          );

        case 500:
        case 502:
        case 503:
          throw Exception(
            'The server is temporarily unavailable.',
          );

        default:
          throw Exception(
            'Unexpected server response (${response.statusCode}).',
          );
      }
    } on ApiException {
      rethrow;
    } on FormatException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'BookingItemCreationApi.acceptNegotiation: $e',
        );
      }

      throw Exception(
        'Failed to accept negotiation.',
      );
    }
  }
}