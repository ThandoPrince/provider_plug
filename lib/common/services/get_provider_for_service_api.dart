import 'dart:convert';
import 'package:flutter_application_2/common/models/models/provider_for_service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class GetProviderForServiceApi {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> fetchProviderServices(String email) async {
    final uri = Uri.parse(
      '$baseUrl/service_provider/$email/services/',
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final decoded =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode == 200) {
        final List<dynamic> rawList =
            (decoded is Map<String, dynamic> && decoded['data'] is List)
                ? decoded['data'] as List<dynamic>
                : [];

        final services = rawList
            .map((item) => ProviderServiceModel.fromJson(
                  item is Map<String, dynamic> ? item : null,
                ))
            .toList();

        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': services,
          'count': decoded is Map<String, dynamic> ? decoded['count'] : null,
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': decoded is Map<String, dynamic>
            ? (decoded['message'] ??
                decoded['error'] ??
                'Failed to fetch provider services')
            : 'Failed to fetch provider services',
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': 500,
        'message': 'Something went wrong: $e',
      };
    }
  }
}