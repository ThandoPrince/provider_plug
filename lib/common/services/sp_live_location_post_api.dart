import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/client_models/sp_live_location_post_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SpLiveLocationService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Transmits real-time service provider geo-coordinates to the backend gateway.
  static Future<bool> sendLiveLocation(SpLiveLocationPostModel location) async {
    final url = Uri.parse('$baseUrl/service_providers/sp/update-live-location/');
    
    // Auto-extract the active access token from the session state manager
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode(location.toJson()),
      ).timeout(const Duration(seconds: 10)); // Protect high-frequency telemetry streams from hanging

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          debugPrint("❌ Location telemetry failure [${response.statusCode}]: ${response.body}");
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("⚠️ Exception dispatching service provider telemetry: $e");
      }
      return false;
    }
  }
}