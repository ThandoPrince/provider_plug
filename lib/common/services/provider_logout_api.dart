import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProviderLogoutApi {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  static Future<Map<String, dynamic>> logout({
    required String refreshToken,
  }) async {
    final url = Uri.parse(
      '$baseUrl/provider/logout/',
    );

    try {
      final response = await ApiClient.instance.request(
        (token) => http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            if (token != null)
              "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "refresh": refreshToken,
          }),
        ),
      );

      final dynamic decodedBody = jsonDecode(response.body);

      final Map<String, dynamic> data =
          decodedBody is Map
              ? Map<String, dynamic>.from(decodedBody)
              : {};

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return {
          "success": true,
          "message":
              data["message"] ??
              "Logged out successfully.",
        };
      }

      if (kDebugMode) {
        debugPrint(
          "❌ LOGOUT REJECTED "
          "[${response.statusCode}]: ${response.body}",
        );
      }

      return {
        "success": false,
        "message":
            data["message"] ??
            data["error"] ??
            "Logout failed.",
      };
    } on ApiException {
      rethrow;
    } on FormatException {
      return {
        "success": false,
        "message": "Bad response format from server.",
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          "⚠️ Exception caught in ProviderLogoutApi: $e",
        );
      }

      return {
        "success": false,
        "message": "Unable to contact logout service.",
      };
    }
  }
}