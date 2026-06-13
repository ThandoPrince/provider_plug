import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/booking_item_model.dart';

class BookingItemCreationApi {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Calls the provider negotiation acceptance endpoint with secure session headers.
  static Future<AcceptNegotiationResponse> acceptNegotiation({
    required int negotiationId,
  }) async {
    final url = Uri.parse('$_baseUrl/bookings/service_orders/negotiation/provider_accepts_negotiation/$negotiationId/');
    
    // Auto-extract secure bearer token from state manager
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        if (decodedBody is Map) {
          return AcceptNegotiationResponse.fromJson(Map<String, dynamic>.from(decodedBody));
        }
        throw const FormatException('Expected a JSON object container for negotiation validation updates.');
      } else {
        if (kDebugMode) {
          print('❌ NEGOTIATION CREATION ACCEPTANCE REJECTED [${response.statusCode}]: ${response.body}');
        }
        throw Exception('Server rejected booking confirmation step with status: [${response.statusCode}]');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught inside BookingItemCreationApi: $e');
      }
      throw Exception('Network or formatting error confirming booking line modifications: $e');
    }
  }
}