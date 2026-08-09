import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/ratings_model.dart';
import 'package:http/http.dart' as http;

class ProviderCompletedServicesApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches historical review ratings for a service provider.
  static Future<List<RatingModel>> fetchRatingsByProviderEmail(
    
  ) async {
   
    final url = Uri.parse(
      '$baseUrl/bookings/ratings/provider/',
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

          if (decoded is! List) {
            throw const FormatException(
              'Expected a JSON array.',
            );
          }

          return decoded
              .map<RatingModel>(
                (item) => RatingModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();

        case 400:
          throw Exception(
            'Invalid request.',
          );

        case 403:
          throw Exception(
            'You do not have permission to view these ratings.',
          );

        case 404:
          throw Exception(
            'No ratings were found.',
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
          'ProviderCompletedServicesApi.fetchRatingsByProviderEmail: $e',
        );
      }

      throw Exception(
        'Failed to fetch provider ratings.',
      );
    }
  }
}