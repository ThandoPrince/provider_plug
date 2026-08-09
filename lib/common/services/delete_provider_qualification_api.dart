import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DeleteProviderQualificationApi {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  // Existing methods...

  static Future<Map<String, dynamic>> deleteQualification({
    required int qualificationId,
  }) async {
    final url = Uri.parse(
      "$baseUrl/provider-qualification/$qualificationId/",
    );

    try {
      final response = await ApiClient.instance.request(
        (token) => http.delete(
          url,
          headers: {
            "Accept": "application/json",
            if (token != null)
              "Authorization": "Bearer $token",
          },
        ),
      );

      final dynamic decoded =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      final Map<String, dynamic> data =
          decoded is Map
              ? Map<String, dynamic>.from(decoded)
              : {};

      if (response.statusCode == 200) {
        return data;
      }

      if (kDebugMode) {
        print(
          "❌ DELETE QUALIFICATION FAILED "
          "[${response.statusCode}] ${response.body}",
        );
      }

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Unable to delete qualification.",
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ deleteQualification: $e");
      }
      rethrow;
    }
  }
}