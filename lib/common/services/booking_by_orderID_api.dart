import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:http/http.dart' as http;

class BookingByOrderidApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetch a booking service order by its unique database ID.
  static Future<OrderService> fetchBookingByOrderID(
    int orderID,
  ) async {
    final url = Uri.parse(
      '$baseUrl/bookings/provider_service_orders/$orderID/',
    );

    try {
      final response = await ApiClient.instance.request(
        (token) {
          return http.get(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              if (token != null)
                'Authorization': 'Bearer $token',
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

          return OrderService.fromJson(decoded);

        case 400:
          throw Exception('Invalid booking request.');

        case 403:
          throw Exception(
            'You do not have permission to access this booking.',
          );

        case 404:
          throw Exception(
            'Booking not found.',
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
          'BookingByOrderidApi.fetchBookingByOrderID: $e',
        );
      }

      throw Exception(
        'Failed to fetch booking.',
      );
    }
  }
}