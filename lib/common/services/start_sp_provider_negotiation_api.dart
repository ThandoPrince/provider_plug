import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StartSpProviderNegotiationApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Starts a negotiation round for a provider.
  static Future<NegotiationRound?> startProviderRound({
    required int negotiationId,
   
    String? message,
    double? offeredPrice,
  }) async {
    final bodyPayload = <String, dynamic>{
    
      if (message != null && message.trim().isNotEmpty)
        'message': message.trim(),
      if (offeredPrice != null) 'offered_price': offeredPrice,
    };

    try {
      final response = await ApiClient.instance.request(
        (token) => http.post(
          Uri.parse(
            '$baseUrl/bookings/service_orders/negotiation/$negotiationId/provider_start_round/',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          body: jsonEncode(bodyPayload),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return NegotiationRound.fromJson(decoded);
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
            'Failed to start negotiation round.',
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        'Invalid response received from the server.',
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ StartSpProviderNegotiationApi: $e');
      }

      throw const ApiException(
        'Failed to start negotiation round.',
      );
    }
  }
}