import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';

class ShipmentApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches shipments for a service provider by email with secure headers.
  static Future<List<Shipment>> getShipmentsByProvider(String providerEmail) async {
    final url = Uri.parse("$baseUrl/bookings/get_shipment/by_sp_email/${providerEmail.trim().toLowerCase()}/");
    
    // Auto-extract token from session state manager
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
        final dynamic body = jsonDecode(response.body);

        if (body is List) {
          return body
              .map((item) => Shipment.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
        throw const FormatException("Unexpected API format: expected a list of shipments.");
      } else {
        if (kDebugMode) {
          print("❌ Shipment API query rejected [${response.statusCode}]: ${response.body}");
        }
        throw Exception("Server rejected shipments query with status: [${response.statusCode}].");
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ ShipmentApi Error: $e");
        print("📌 STACKTRACE: $stack");
      }
      rethrow;
    }
  }
}