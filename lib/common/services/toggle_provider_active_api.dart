import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ToggleProviderActiveApi {
  static Future<Map<String, dynamic>> toggleProviderActive(String email) async {
    try {
     final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

      final url = Uri.parse(
        "$baseUrl/providers/$email/toggle-active/",
      );

      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": data["success"] == true,
          "is_active": data["is_active"],
          "message": data["message"] ?? "Status updated",
        };
      }

      return {
        "success": false,
        "message": data["message"] ?? "Failed to toggle status",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "Error toggling provider status: $e",
      };
    }
  }
}