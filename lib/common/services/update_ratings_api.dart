import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

class PatchRatingApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// PATCH: Submits a rating and optional review for a completed booking session
  static Future<bool> patchRating({
    required String sessionId,
    required String providerEmail,
    required int score,
    String? review,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/$sessionId/rate-client/$providerEmail/');
    
    // Auto-extract token from session state manager
    final String? token = AuthSessionController.instance.accessToken;

    final Map<String, dynamic> bodyPayload = {
      "score": score,
      "review": review?.trim() ?? "",
    };

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyPayload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        if (kDebugMode) {
          print('❌ RATING PATCH FAILED [${response.statusCode}]: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception thrown during rating API submission: $e');
      }
      return false;
    }
  }
}