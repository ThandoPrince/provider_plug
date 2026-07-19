import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PatchRatingApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// PATCH: Submits a rating and optional review for a completed booking session.
  static Future<bool> patchRating({
    required String sessionId,

    required int score,
    String? review,
  }) async {
    final bodyPayload = {
      "score": score,
      "review": review?.trim() ?? "",
    };

    try {
      final providerID = AuthSessionController.instance.id;
      final response = await ApiClient.instance.request(
        (token) => http.patch(
          Uri.parse(
            '$baseUrl/bookings/$sessionId/rate-client/$providerID/',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          body: jsonEncode(bodyPayload),
        ),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      throw ApiException(
        data["detail"] ??
            data["message"] ??
            "Failed to submit rating.",
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        "Invalid response received from the server.",
      );
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ PatchRatingApi: $e");
      }

      throw const ApiException(
        "Failed to submit rating.",
      );
    }
  }
}