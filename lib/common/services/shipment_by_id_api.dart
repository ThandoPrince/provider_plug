import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';

class ShipmentByIdApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches a single shipment record matching the provided ID.
  static Future<Shipment> fetchShipmentById(int shipmentId) async {
    final url = Uri.parse(
      '$baseUrl/bookings/get_shipment/by_shipment_id/$shipmentId/',
    );

    try {
      final response = await ApiClient.instance.request(
        (token) => http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);

        if (decodedBody is Map) {
          return Shipment.fromJson(
            Map<String, dynamic>.from(decodedBody),
          );
        }

        throw const FormatException(
          'Expected a JSON object representation for the shipment payload.',
        );
      }

      if (kDebugMode) {
        print(
          '❌ Shipment query failed [${response.statusCode}]: ${response.body}',
        );
      }

      throw Exception(
        'Server rejected shipment query with status: [${response.statusCode}]',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught inside fetchShipmentById: $e');
      }

      throw Exception(
        'Network or formatting error parsing shipment ID $shipmentId: $e',
      );
    }
  }
}