import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

class UpdateSessionStatusApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// PATCH: Updates a booking session status (e.g., checked-out, cancelled, completed)
  static Future<Map<String, dynamic>> updateSessionStatus({
    required int sessionId,
    required String status,
    Map<String, dynamic>? checkoutLocation,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/sessions/$sessionId/update_status/');
    
    // Auto-extract token from session state manager
    final String? token = AuthSessionController.instance.accessToken;

    final Map<String, dynamic> payload = {
      'session_status': status,
      if (checkoutLocation != null) 'checkout_location': checkoutLocation,
    };

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      final dynamic decodedResponse = jsonDecode(response.body);
      final Map<String, dynamic> responseData = decodedResponse is Map 
          ? Map<String, dynamic>.from(decodedResponse) 
          : {'message': response.body};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        final String serverError = responseData['message'] ?? responseData['error'] ?? response.body;
        throw Exception(kDebugMode
            ? 'Backend Error: $serverError'
            : 'Failed: $serverError');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ STATUS PATCH EXCEPTION: $e');
      }
      throw Exception('Network error or server rejected update: $e');
    }
  }
}