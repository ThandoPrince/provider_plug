import 'dart:convert';
import 'package:flutter_application_2/common/models/models/sp_profile_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;



class FetchAuthApi {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> fetchSPProfile(String email) async {
    final uri = Uri.parse('$baseUrl/sp_profiles/${email.toLowerCase()}/');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final dynamic decodedBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : null;

      if (response.statusCode == 200) {
        final profile = SPProfileModel.fromJson(decodedBody);

        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': profile,
        };
      }

      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': decodedBody is Map<String, dynamic>
            ? (decodedBody['message'] ??
                decodedBody['error'] ??
                'Failed to fetch profile')
            : 'Failed to fetch profile',
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