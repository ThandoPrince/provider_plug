import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_route_model.dart';

class ShipmentRouteApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Create or update a shipment route mapping.
  static Future<ShipmentRoute> postShipmentRoute(ShipmentRoute route) async {
    final url = Uri.parse('$baseUrl/bookings/shipment/${route.shipmentId}/route/');
    final String? token = AuthSessionController.instance.accessToken;

    if (kDebugMode) {
      print("📡 POSTing ShipmentRoute to $url");
      print("📦 Payload: ${jsonEncode(route.toJson())}");
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(route.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("📨 Response status: ${response.statusCode}");
        print("📨 Response body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decodedBody = jsonDecode(response.body);
        return ShipmentRoute.fromJson(Map<String, dynamic>.from(decodedBody as Map));
      } else {
        throw Exception('Failed to save shipment route [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception inside postShipmentRoute: $e");
      }
      throw Exception('Network or processing fault saving route data: $e');
    }
  }

  /// GET: Fetch all waypoint routes tied to a target shipment instance.
  static Future<List<ShipmentRoute>> getShipmentRoutes(int shipmentId) async {
    final url = Uri.parse('$baseUrl/bookings/shipment/$shipmentId/route/');
    final String? token = AuthSessionController.instance.accessToken;

    if (kDebugMode) {
      print("📡 GET ShipmentRoutes from $url");
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print("📨 Response status: ${response.statusCode}");
        print("📨 Response body: ${response.body}");
      }

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        if (decodedData is List) {
          return decodedData
              .map((e) => ShipmentRoute.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
        throw const FormatException('Expected a JSON list payload context.');
      } else {
        throw Exception('Failed to fetch shipment routes [${response.statusCode}]: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Exception inside getShipmentRoutes: $e");
      }
      throw Exception('Network or processing fault fetching route lines: $e');
    }
  }
}