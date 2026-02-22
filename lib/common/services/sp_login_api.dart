import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SPLoginApi {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Login service provider
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/sp_login/');
    final body = {
      "email": email,
      "password": password,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"success": true, "data": data};
      } else {
        return {"success": false, "message": data["errors"] ?? "Unknown error"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}