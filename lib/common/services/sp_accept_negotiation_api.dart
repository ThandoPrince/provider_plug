import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

class AcceptNegotiationApi {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Calls the provider_accept_negotiation endpoint with secure session headers.
  /// Throws an exception on non-200 responses or unexpected network faults.
  static Future<Map<String, dynamic>> acceptNegotiationById(int negotiationId) async {
    final url = Uri.parse('$_baseUrl/bookings/service_orders/negotiation/provider_accepts_negotiation/$negotiationId/');
    
    // Auto-extract token from session state manager
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

      final dynamic decodedBody = jsonDecode(response.body);
      final Map<String, dynamic> responseData = decodedBody is Map 
          ? Map<String, dynamic>.from(decodedBody) 
          : {};

      if (response.statusCode == 200) {
        return responseData;
      } else {
        if (kDebugMode) {
          print('❌ NEGOTIATION ACCEPTANCE REJECTED [${response.statusCode}]: ${response.body}');
        }
        
        final String serverMessage = responseData['detail'] ?? 
            responseData['message'] ?? 
            'Failed to accept negotiation [${response.statusCode}]';
            
        throw Exception(serverMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in AcceptNegotiationApi: $e');
      }
      throw Exception(e is Exception ? e.toString().replaceAll('Exception: ', '') : 'Network error or handshake rejection: $e');
    }
  }
}