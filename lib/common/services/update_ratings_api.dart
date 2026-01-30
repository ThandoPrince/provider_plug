import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PatchRatingApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<bool> patchRating({
    required String sessionId,
    required String providerEmail,
    required int score,
    String? review,
  }) async {
    final url = Uri.parse(
        '$baseUrl/bookings/$sessionId/rate-client/$providerEmail/');
    
    final body = jsonEncode({
      "score": score,
      "review": review ?? "",
    });

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }
}
