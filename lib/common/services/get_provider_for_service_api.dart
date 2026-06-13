import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/provider_for_service_model.dart';

class GetProviderForServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches active services offered by a provider matching their email identifier.
  static Future<Map<String, dynamic>> fetchProviderServices(String email) async {
    final providerID = AuthSessionController.instance.id;
    final uri = Uri.parse('$baseUrl/service_provider/services/$providerID');
    
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

      final dynamic decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final Map<String, dynamic> decodedMap = decoded is Map ? Map<String, dynamic>.from(decoded) : {};

      if (response.statusCode == 200) {
        final List<dynamic> rawList = decodedMap['data'] is List ? decodedMap['data'] : [];

        final services = rawList
            .map((item) => ProviderServiceModel.fromJson(
                  item is Map ? Map<String, dynamic>.from(item) : {},
                ))
            .toList();

        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': services,
          'count': decodedMap['count'] ?? services.length,
        };
      }

      if (kDebugMode) {
        print('❌ PROVIDER SERVICES QUERY REJECTED [${response.statusCode}]: ${response.body}');
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': decodedMap['message'] ?? decodedMap['error'] ?? 'Failed to fetch provider services.',
      };
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in GetProviderForServiceApi: $e');
      }
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Network or parsing error while loading provider profile details.',
      };
    }
  }
}