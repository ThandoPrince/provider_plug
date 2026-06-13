import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_2/common/models/provider_login_response_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SPLoginApi {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<ProviderLoginResponseModel?> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/sp_login/');

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "identifier": email.toLowerCase(),
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ProviderLoginResponseModel.fromJson(data);
      } else {
        return null;
      }
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> updatePushToken({
    required String email,
    required String token,
    required String provider,
    required String authToken, // Made required to guarantee auth context availability
    String? deviceType,
    String? deviceName,
    String? osVersion,
    String? appVersion,
  }) async {
    final uri = Uri.parse('$baseUrl/sp/register/device-token/');

    // Build map cleanly outside literal to keep compiler happy
    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };
    if (authToken.isNotEmpty) {
      requestHeaders['Authorization'] = 'Bearer $authToken';
    }

    try {
      final response = await http.post(
        uri,
        headers: requestHeaders,
        body: jsonEncode({
          "email": email.toLowerCase(),
          "push_token": token,
          "device_type": deviceType,
          "device_name": deviceName,
          "os_version": osVersion,
          "app_version": appVersion,
          "provider": provider,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        "statusCode": response.statusCode,
        "data": data,
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {"error": "Failed to update push token: $e"},
      };
    }
  }
}