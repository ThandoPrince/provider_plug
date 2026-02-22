import 'dart:convert';
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
      final response = await http.post(
        url,
         headers: {
    "Content-Type": "application/json",
  },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        
        return {"success": true, "status": data["status"], "service": data["service"]};
      } else {
        return {
          "success": false,
          "message": data["reason"] ?? data["error"] ?? "Unknown error"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}