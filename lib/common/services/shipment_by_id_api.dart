import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';

class ShipmentByIdApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches a single shipment record matching the provided ID.
  static Future<Shipment> fetchShipmentById(int shipmentId) async {
    final url = Uri.parse('$baseUrl/bookings/get_shipment/by_shipment_id/$shipmentId/');
    
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
          return Shipment.fromJson(Map<String, dynamic>.from(decodedBody));
        }
        throw const FormatException('Expected a JSON object representation for the shipment payload.');
      } else {
        if (kDebugMode) {
          print('❌ Shipment query failed [${response.statusCode}]: ${response.body}');
        }
        throw Exception('Server rejected shipment query with status: [${response.statusCode}]');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught inside fetchShipmentById: $e');
      }
      throw Exception('Network or formatting error parsing shipment ID $shipmentId: $e');
    }
  }
}