import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UpdateSessionStatusApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Update session status (check-out / cancel / complete)
  static Future<Map<String, dynamic>> updateSessionStatus({
    required int sessionId,
    required String status,
    String? accessToken,
    Map<String, dynamic>? checkoutLocation,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/bookings/sessions/$sessionId/update_status/',
    );

    final payload = {
      'session_status': status,
      if (checkoutLocation != null)
        'checkout_location': checkoutLocation,
    };

    final response = await http.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (accessToken != null)
          'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(
      'Session status update failed '
      '[${response.statusCode}]: ${response.body}',
    );
  }
}
