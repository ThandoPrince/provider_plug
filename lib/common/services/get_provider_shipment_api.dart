import 'dart:convert';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShipmentApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch shipments for a service provider by email
  static Future<List<Shipment>> getShipmentsByProvider(String providerEmail) async {
    final url = Uri.parse("$baseUrl/bookings/get_shipment/by_sp_email/$providerEmail/");

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch shipments: ${response.statusCode}");
      }

      final body = jsonDecode(response.body);

      // ✅ Your API returns a LIST at the top level
      if (body is List) {
        return body.map((item) => Shipment.fromJson(item)).toList();
      }

      throw Exception("Unexpected API format: expected a list of shipments");
    } catch (e, stack) {
      print("❌ ShipmentApi Error: $e");
      print("📌 STACKTRACE: $stack");
      rethrow;
    }
  }
}
