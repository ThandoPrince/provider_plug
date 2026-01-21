// lib/common/services/accept_negotiation_api.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AcceptNegotiationApi {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Calls provider_accept_negotiation endpoint and returns the decoded JSON response.
  /// Throws on non-200 responses or network errors.
  static Future<Map<String, dynamic>> acceptNegotiationById(int negotiationId) async {
    final url = Uri.parse('$_baseUrl/bookings/service_orders/negotiation/provider_accepts_negotiation/$negotiationId/');

    try {
      final response = await http.post(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        // Try to parse error body if possible
        String message = 'Failed to accept negotiation [${response.statusCode}]';
        try {
          final Map<String, dynamic> err = jsonDecode(response.body);
          message = err['detail'] ?? err['message'] ?? message;
        } catch (_) {}
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Network or parsing error while accepting negotiation: $e');
    }
  }
}
