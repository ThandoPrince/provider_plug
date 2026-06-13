import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

class LinkServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Submits or links a service to a provider's profile by email with secure headers.
  static Future<Map<String, dynamic>> submitService({
    
    required String serviceName,
    String description = '',
    String? serviceGroupId,
  }) async {
final int? providerId = AuthSessionController.instance.id;
    final url = Uri.parse('$baseUrl/service/upload_or_create/$providerId/');
    
    // Auto-extract token from session state manager
    final String? token = AuthSessionController.instance.accessToken;

    final Map<String, dynamic> bodyPayload = {
      "service_name": serviceName.trim(),
      "description": description.trim(),
      if (serviceGroupId != null && serviceGroupId.trim().isNotEmpty) "service_group": serviceGroupId.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode(bodyPayload),
      ).timeout(const Duration(seconds: 15));

      final dynamic decodedBody = jsonDecode(response.body);
      final Map<String, dynamic> data = decodedBody is Map 
          ? Map<String, dynamic>.from(decodedBody) 
          : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          "success": true, 
          "status": data["status"], 
          "service": data["service"],
          "message": data["message"] ?? "Service linked successfully."
        };
      } else {
        if (kDebugMode) {
          print('❌ SERVICE SUBMISSION REJECTED [${response.statusCode}]: ${response.body}');
        }
        
        final String errorMsg = data["reason"] ?? 
            data["message"] ?? 
            data["error"] ?? 
            "Server Error (${response.statusCode})";
            
        return {"success": false, "message": errorMsg};
      }
    } on SocketException {
      return {"success": false, "message": "Check your internet connection."};
    } on TimeoutException {
      return {"success": false, "message": "Server took too long to respond. Try again."};
    } on FormatException {
      return {"success": false, "message": "Bad response format from server."};
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in LinkServiceApi: $e');
      }
      return {"success": false, "message": "An unexpected error occurred."};
    }
  }
}