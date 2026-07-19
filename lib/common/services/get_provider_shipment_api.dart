import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';

class ShipmentApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches shipments for a service provider by email with secure headers.
  static Future<List<Shipment>> getShipmentsByProvider(
    
  ) async {
    final url = Uri.parse(
      "$baseUrl/bookings/get_shipment/by_sp_email/",
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
        final dynamic body = jsonDecode(response.body);

        if (body is List) {
          return body
              .map(
                (item) => Shipment.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList();
        }

        throw const FormatException(
          "Unexpected API format: expected a list of shipments.",
        );
      } else {
        if (kDebugMode) {
          print(
            "❌ Shipment API query rejected [${response.statusCode}]: ${response.body}",
          );
        }

        throw Exception(
          "Server rejected shipments query with status: [${response.statusCode}].",
        );
      }
    } on ApiException {
      rethrow;
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ ShipmentApi Error: $e");
        print("📌 STACKTRACE: $stack");
      }

      rethrow;
    }
  }
}