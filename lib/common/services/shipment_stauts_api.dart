import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShipmentStatusApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<bool> updateStatus(
    int shipmentId,
    String status,
  ) async {
    try {
      final response = await ApiClient.instance.request(
        (token) => http
            .post(
              Uri.parse(
                '$baseUrl/bookings/shipment/$shipmentId/change_status/',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                if (token != null && token.isNotEmpty)
                  'Authorization': 'Bearer $token',
              },
              body: jsonEncode({
                'status': status,
              }),
            )
            .timeout(ApiClient.timeout),
      );

      if (response.statusCode == 200) {
        return true;
      }

      String message = "Failed to update shipment status.";

      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map) {
          message = decoded["detail"] ??
              decoded["message"] ??
              decoded["error"] ??
              message;
        }
      }

      throw ApiException(message);
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException("Invalid response received from the server.");
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ ShipmentStatusApi.updateStatus: $e");
      }

      throw const ApiException(
        "Failed to update shipment status.",
      );
    }
  }
}