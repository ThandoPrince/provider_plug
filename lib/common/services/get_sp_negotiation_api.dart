import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_model.dart';

class GetSpNegotiationApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches negotiation records by order ID and provider email with secure headers.
  static Future<List<NegotiationModel>> fetchNegotiations({
    required int orderId,
   
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/negotiations/order/$orderId/provider/',
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
        final dynamic decodedData = jsonDecode(response.body);

        if (decodedData is List) {
          return decodedData
              .map(
                (json) => NegotiationModel.fromJson(
                  Map<String, dynamic>.from(json as Map),
                ),
              )
              .toList();
        }

        throw const FormatException(
          'Expected a JSON list payload representation for negotiations.',
        );
      } else if (response.statusCode == 404) {
        return [];
      } else {
        if (kDebugMode) {
          print(
            '❌ Negotiations query failure [${response.statusCode}]: ${response.body}',
          );
        }

        throw Exception(
          'Failed to load negotiations [${response.statusCode}].',
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught in GetSpNegotiationApi: $e');
      }

      throw Exception(
        'Network or formatting error parsing negotiations history: $e',
      );
    }
  }
}