import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthCreationApiHelper {
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  Future<Map<String, dynamic>> registration({
    required String email,
    required String password,
    required String mobileNumber,
  }) async {
    final url = Uri.parse('$baseUrl/sp_profile/register/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email_address": email.trim().toLowerCase(),
          "password": password,
          "mobile_number": mobileNumber.trim(),
        }),
      );

      final dynamic dynamicBody = jsonDecode(response.body);
      if (dynamicBody is! Map) {
        return {"success": false, "message": "Unexpected server response layout."};
      }
      
      final Map<String, dynamic> body = Map<String, dynamic>.from(dynamicBody);

      if (response.statusCode == 201) {
        return {"success": true, "data": body};
      } else {
        String errorMessage = "Registration failed";
        
        if (body.containsKey('errors')) {
          final errorData = body['errors'];
          if (errorData is Map && errorData.isNotEmpty) {
            final firstErrorList = errorData.values.first;
            if (firstErrorList is List && firstErrorList.isNotEmpty) {
              errorMessage = firstErrorList.first.toString();
            }
          }
        } else if (body.containsKey('message')) {
          errorMessage = body['message'].toString();
        }
        
        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      return {"success": false, "message": "Check your internet connection."};
    }
  }
}