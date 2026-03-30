import 'dart:convert';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShipmentByIdApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Shipment> fetchShipmentById(int shipmentId) async {
    final url = Uri.parse(
      '$baseUrl/bookings/get_shipment/by_shipment_id/$shipmentId/',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Shipment.fromJson(data);
    } else {
      throw Exception(
        'Failed to fetch shipment by ID: ${response.statusCode} ${response.body}',
      );
    }
  }
}