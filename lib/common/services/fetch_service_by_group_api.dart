import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/service_groups.dart';

class FetchServiceByGroupApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches all available service groups from the system index.
  static Future<List<ServiceGroupModel>> fetchServiceGroups() async {
    final uri = Uri.parse('$baseUrl/service_groups/');
    
    // Auto-extract the active access token from the session state manager
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

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        if (decodedData is List) {
          return decodedData
              .map((json) => ServiceGroupModel.fromJson(Map<String, dynamic>.from(json as Map)))
              .toList();
        }
        throw const FormatException('Expected an array schema layout for service groups.');
      } else {
        if (kDebugMode) {
          print('❌ SERVICE GROUPS LOAD FAILED [${response.statusCode}]: ${response.body}');
        }
        throw Exception('Server rejected service groups fetch with status: [${response.statusCode}]');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in fetchServiceGroups: $e');
      }
      throw Exception('Network or formatting error parsing service groupings: $e');
    }
  }
}