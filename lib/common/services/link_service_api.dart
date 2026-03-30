import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LinkServiceApi {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Submit a service for a provider by email
  Future<Map<String, dynamic>> submitService({
    required String email,
    required String serviceName,
    String description = '',
    String? serviceGroupId,
  }) async {
    final url = Uri.parse('$baseUrl/service/upload_or_create/$email/');

    final body = {
      "service_name": serviceName,
      "description": description,
      if (serviceGroupId != null) "service_group": serviceGroupId,
    };

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15)); // Critical for mobile UX

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
  return {
    "success": true, 
    "status": data["status"], 
    "service": data["service"],
    "message": data["message"] ?? "Service linked successfully"
  };
} else {
  // Extracting specific backend validation errors
  String errorMsg = "Submission declined.";
  if (data is Map) {
    errorMsg = data["reason"] ?? data["message"] ?? data["error"] ?? "Server Error (${response.statusCode})";
  }
  return {"success": false, "message": errorMsg};
}
    } on SocketException {
      return {"success": false, "message": "Check your internet connection."};
    } on TimeoutException {
      return {"success": false, "message": "Server took too long to respond. Try again."};
    } on FormatException {
      return {"success": false, "message": "Bad response format from server."};
    } catch (e) {
      return {"success": false, "message": "An unexpected error occurred: $e"};
    }
  }
}