import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';

class StartSpProviderNegotiationApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Starts a negotiation round for a provider with secure headers
  static Future<NegotiationRound?> startProviderRound({
    required int negotiationId,
    required String providerEmail,
    String? message,
    double? offeredPrice,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/service_orders/negotiation/$negotiationId/provider_start_round/');
    
    // Auto-extract token from session state manager
    final String? token = AuthSessionController.instance.accessToken;

    final Map<String, dynamic> bodyPayload = {
      'provider_email': providerEmail.trim().toLowerCase(),
      if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
      if (offeredPrice != null) 'offered_price': offeredPrice,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyPayload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decodedData = jsonDecode(response.body);
        if (decodedData is Map) {
          return NegotiationRound.fromJson(Map<String, dynamic>.from(decodedData));
        }
        return null;
      } else {
        if (kDebugMode) {
          print('❌ Failed to start negotiation round [${response.statusCode}]: ${response.body}');
        }
        throw Exception('Server rejected negotiation initialization: [${response.statusCode}]');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in StartSpProviderNegotiationApi: $e');
      }
      throw Exception('Network or data processing error while starting negotiation: $e');
    }
  }
}