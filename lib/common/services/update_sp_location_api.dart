import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

class UpdateSpLocationApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Updates the service provider's live tracking coordinates on the backend.
  static Future<bool> updateServiceProviderLocation({
    required String spEmail,
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$baseUrl/api/service_providersDB/update_sp_live_location/');
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'sp_email': spEmail.trim().toLowerCase(),
          'latitude': latitude,
          'longitude': longitude,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        if (kDebugMode) {
          print('❌ Failed to update location [${response.statusCode}]: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error executing location update API call: $e');
      }
      return false;
    }
  }
}