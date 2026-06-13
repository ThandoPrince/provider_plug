import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/sp_profile_model.dart';
import 'package:provider/provider.dart';

class FetchAuthApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches the service provider profile details by email identifier with secure headers.
  static Future<Map<String, dynamic>> fetchSPProfile(String email) async {
    final providerID= AuthSessionController.instance.id;
    final uri = Uri.parse('$baseUrl/sp_profiles/$providerID/');
    
    // Auto-extract token from session state manager
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final dynamic decodedBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final Map<String, dynamic> dataMap = decodedBody is Map ? Map<String, dynamic>.from(decodedBody) : {};

      if (response.statusCode == 200) {
        final profile = SPProfileModel.fromJson(dataMap);

        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': profile,
        };
      }

      if (kDebugMode) {
        print('❌ AUTH PROFILE FETCH REJECTED [${response.statusCode}]: ${response.body}');
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': dataMap['message'] ?? dataMap['error'] ?? 'Failed to fetch profile.',
      };
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in FetchAuthApi: $e');
      }
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Network or parsing error while validating service provider profile.',
      };
    }
  }
}