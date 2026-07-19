import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_2/common/models/models/order_service_models/session_model.dart';

class SessionApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches a single session record by its associated shipment ID.
  static Future<SessionModel> getSessionByShipment(String shipmentId) async {
    final url = Uri.parse(
      "$baseUrl/bookings/sessions/get_session_by_shipment/${shipmentId.trim()}/",
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
          return SessionModel.fromJson(
            Map<String, dynamic>.from(decodedBody),
          );
        }

        throw const FormatException(
          'Expected a JSON object payload representation for the target session.',
        );
      }

      if (kDebugMode) {
        print(
          "❌ Session API query rejected [${response.statusCode}]: ${response.body}",
        );
      }

      throw Exception(
        "Server rejected session query with status: [${response.statusCode}].",
      );
    } on ApiException {
      rethrow;
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ SessionApi Error: $e");
        print("📌 STACKTRACE: $stack");
      }

      rethrow;
    }
  }
}