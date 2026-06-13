import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_model.dart';

class SessionApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches a single session record by its associated shipment ID.
  static Future<SessionModel> getSessionByShipment(String shipmentId) async {
    final url = Uri.parse("$baseUrl/bookings/sessions/get_session_by_shipment/${shipmentId.trim()}/");
    
    // Auto-extract the secure access token from the session state manager
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        if (decodedBody is Map) {
          return SessionModel.fromJson(Map<String, dynamic>.from(decodedBody));
        }
        throw const FormatException('Expected a JSON object payload representation for the target session.');
      } else {
        if (kDebugMode) {
          print("❌ Session API query rejected [${response.statusCode}]: ${response.body}");
        }
        throw Exception("Server rejected session query with status: [${response.statusCode}].");
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ SessionApi Error: $e");
        print("📌 STACKTRACE: $stack");
      }
      rethrow;
    }
  }
}