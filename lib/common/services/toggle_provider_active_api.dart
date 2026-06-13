import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

class ToggleProviderActiveApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// PATCH: Toggles the provider's active/online availability status on the system
  static Future<Map<String, dynamic>> toggleProviderActive(String email) async {
    final url = Uri.parse('$baseUrl/providers/toggle-active/');
    
    // Auto-extract token from session state manager
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final dynamic decodedBody = jsonDecode(response.body);
      final Map<String, dynamic> data = decodedBody is Map 
          ? Map<String, dynamic>.from(decodedBody) 
          : {};

      if (response.statusCode == 200) {
        return {
          "success": data["success"] == true,
          "is_active": data["is_active"] ?? false,
          "message": data["message"] ?? "Status updated successfully.",
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Failed to toggle active status [${response.statusCode}].",
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ TOGGLE ACTIVE EXCEPTION: $e');
      }
      return {
        "success": false,
        "message": "Connection error while updating online status.",
      };
    }
  }
}