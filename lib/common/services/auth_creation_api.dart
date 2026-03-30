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
          "email_address": email.toLowerCase(),
          "password": password,
          "mobile_number": mobileNumber,
        
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {"success": true, "data": data};
      } else {
       
        String errorMessage = "Registration failed";
        
        if (data is Map) {
          if (data.containsKey('errors')) {
            
            var errorData = data['errors'];
            if (errorData is Map) {
            
              errorMessage = errorData.values.first[0];
            }
          } else if (data.containsKey('message')) {
            errorMessage = data['message'];
          }
        }
        
        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      return {"success": false, "message": "Check your internet connection."};
    }
  }
}