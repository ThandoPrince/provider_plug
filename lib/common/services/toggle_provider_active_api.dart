import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ToggleProviderActiveApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// PATCH: Toggles the provider's active/online availability status.
  static Future<Map<String, dynamic>> toggleProviderActive(
    
  ) async {
    try {
      final response = await ApiClient.instance.request(
        (token) => http.patch(
          Uri.parse('$baseUrl/providers/toggle-active/'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        return {
          "success": data["success"] == true,
          "is_active": data["is_active"] ?? false,
          "message": data["message"] ?? "Status updated successfully.",
        };
      }

      throw ApiException(
        data["message"] ??
            "Failed to toggle active status [${response.statusCode}].",
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        "Invalid response received from the server.",
      );
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ ToggleProviderActiveApi: $e");
      }

      throw const ApiException(
        "Failed to update online status.",
      );
    }
  }
}