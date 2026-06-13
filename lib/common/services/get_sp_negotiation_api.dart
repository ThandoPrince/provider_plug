import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_model.dart';

class GetSpNegotiationApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches negotiation records by order ID and provider email with secure headers.
  static Future<List<NegotiationModel>> fetchNegotiations({
    required int orderId,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/negotiations/order/$orderId/provider/${email.trim().toLowerCase()}/');
    
    // Auto-extract token from session state manager
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        if (decodedData is List) {
          return decodedData
              .map((json) => NegotiationModel.fromJson(Map<String, dynamic>.from(json as Map)))
              .toList();
        }
        throw const FormatException('Expected a JSON list payload representation for negotiations.');
      } else if (response.statusCode == 404) {
        return [];
      } else {
        if (kDebugMode) {
          print('❌ Negotiations query failure [${response.statusCode}]: ${response.body}');
        }
        throw Exception('Failed to load negotiations [${response.statusCode}].');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in GetSpNegotiationApi: $e');
      }
      throw Exception('Network or formatting error parsing negotiations history: $e');
    }
  }
}