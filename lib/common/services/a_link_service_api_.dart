import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

class ALinkServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Submits or links a service to a provider's profile by email with secure headers.
  static Future<Map<String, dynamic>> submitService({
    required String serviceName,
    String description = '',
    String? serviceGroupId,
  }) async {
    final int? providerId = AuthSessionController.instance.id;

    final url = Uri.parse(
      '$baseUrl/service/a_upload_or_create/$providerId/',
    );

    final Map<String, dynamic> bodyPayload = {
      "service_name": serviceName.trim(),
      "description": description.trim(),
      if (serviceGroupId != null && serviceGroupId.trim().isNotEmpty)
        "service_group": serviceGroupId.trim(),
    };

    try {
      final response = await ApiClient.instance.request(
        (token) => http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            if (token != null) "Authorization": "Bearer $token",
          },
          body: jsonEncode(bodyPayload),
        ),
      );

      final dynamic decodedBody = jsonDecode(response.body);

      final Map<String, dynamic> data =
          decodedBody is Map
              ? Map<String, dynamic>.from(decodedBody)
              : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
  return {
    "success": true,
    "id": data["id"],
    "status": data["status"],
    "is_primary": data["is_primary"],
    "service": data["service"],
    "profile_status": data["profile_status"],
    "message": data["message"] ?? "Service linked successfully.",
  };

      } else {
        if (kDebugMode) {
          print(
            '❌ SERVICE SUBMISSION REJECTED [${response.statusCode}]: ${response.body}',
          );
        }

        final String errorMsg =
            data["reason"] ??
            data["message"] ??
            data["error"] ??
            "Server Error (${response.statusCode})";

        return {
          "success": false,
          "message": errorMsg,
        };
      }
    } on ApiException {
      rethrow;
    } on FormatException {
      return {
        "success": false,
        "message": "Bad response format from server.",
      };
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in LinkServiceApi: $e');
      }

      return {
        "success": false,
        "message": "An unexpected error occurred.",
      };
    }
  }
}