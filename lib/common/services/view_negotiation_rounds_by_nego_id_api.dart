import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ViewNegotiationRoundsByNegoIdApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch all rounds for a given negotiation ID.
  static Future<List<NegotiationRound>> fetchRoundsByNegotiationId(
    int negotiationId,
  ) async {
    try {
      final response = await ApiClient.instance.request(
        (token) => http.get(
          Uri.parse(
            '$baseUrl/bookings/service_orders/negotiation/rounds/$negotiationId/',
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
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          return decoded
              .map(
                (e) => NegotiationRound.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList();
        }

        throw const ApiException(
          'Invalid response received from the server.',
        );
      }

      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      throw ApiException(
        data['detail'] ??
            data['message'] ??
            data['error'] ??
            'Failed to fetch negotiation rounds.',
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        'Invalid response received from the server.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ ViewNegotiationRoundsByNegoIdApi: $e');
      }

      throw const ApiException(
        'Failed to fetch negotiation rounds.',
      );
    }
  }
}