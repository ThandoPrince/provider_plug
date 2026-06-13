import 'dart:convert';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShipmentStatusApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<bool> updateStatus(
    int shipmentId,
    String status,
  ) async {
    final url =
        Uri.parse('$baseUrl/bookings/shipment/$shipmentId/change_status/');
        final String? token = AuthSessionController.instance.accessToken;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'status': status, 
      }),
    );

    
    
    

    return response.statusCode == 200;
  }
}
