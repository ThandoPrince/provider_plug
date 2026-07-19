import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_application_2/common/models/models/client_models/client_ratings_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FetchClientRatingsApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<Map<String, dynamic>> fetchClientRatings(
    int clientId,
  ) async {


    final uri = Uri.parse(
      '$baseUrl/clients/$clientId/ratings/',
    );

    try {
      final response = await ApiClient.instance.request(
        (token) => http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final dynamic decoded =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;

      final Map<String, dynamic> body =
          decoded is Map<String, dynamic>
              ? decoded
              : <String, dynamic>{};

      if (response.statusCode == 200) {
        final ratings =
            (body['ratings'] as List<dynamic>? ?? [])
                .map(
                  (e) => ClientRatingModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList();

        return {
          'success': true,
          'statusCode': response.statusCode,
          'averageRating': body['average_rating'],
          'totalReviews': body['total_reviews'],
          'data': ratings,
        };
      }

      if (kDebugMode) {
        print(
          '❌ CLIENT RATINGS FETCH FAILED [${response.statusCode}]: ${response.body}',
        );
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message':
            body['message'] ??
            body['error'] ??
            'Failed to fetch client ratings.',
      };
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ FetchClientRatingsApi Exception: $e');
      }

      return {
        'success': false,
        'statusCode': 500,
        'message':
            'Network or parsing error while fetching client ratings.',
      };
    }
  }
}