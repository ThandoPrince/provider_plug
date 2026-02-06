import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_route_model.dart';
 // your API base URL

class ShipmentRouteApi {
   static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  /// Create or update a shipment route
  static Future<ShipmentRoute> postShipmentRoute(ShipmentRoute route) async {
    
    final url = Uri.parse('$baseUrl/bookings/shipment/${route.shipmentId}/route/');

    if (kDebugMode) {
      print("📡 POSTing ShipmentRoute to $url");
      print("📦 Payload: ${jsonEncode(route.toJson())}");
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Add auth headers if needed, e.g.:
        // 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(route.toJson()),
    );

    if (kDebugMode) {
      print("📨 Response status: ${response.statusCode}");
      print("📨 Response body: ${response.body}");
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      // Successful creation or update
      return ShipmentRoute.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to save shipment route. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

    /// Fetch routes for a shipment
  static Future<List<ShipmentRoute>> getShipmentRoutes(int shipmentId) async {
    final url = Uri.parse('$baseUrl/bookings/shipment/$shipmentId/route/');

    if (kDebugMode) {
      print("📡 GET ShipmentRoutes from $url");
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token',
      },
    );

    if (kDebugMode) {
      print("📨 Response status: ${response.statusCode}");
      print("📨 Response body: ${response.body}");
    }

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);

      return decoded
          .map((e) => ShipmentRoute.fromJson(e))
          .toList();
    } else {
      throw Exception(
        'Failed to fetch shipment routes. Status: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

}
