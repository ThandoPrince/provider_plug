import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SessionApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch a single session by shipment ID
  static Future<SessionModel> getSessionByShipment(String shipmentId) async {
    final url = Uri.parse("$baseUrl/bookings/sessions/get_session_by_shipment/$shipmentId/");

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch session: ${response.statusCode}");
      }

      final body = jsonDecode(response.body);
      return SessionModel.fromJson(body); // single session object
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ SessionApi Error: $e");
        print("📌 STACKTRACE: $stack");
      }
      rethrow;
    }
  }
}
