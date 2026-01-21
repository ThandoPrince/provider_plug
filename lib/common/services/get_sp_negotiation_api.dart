import 'dart:convert';
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class GetSpNegotiationApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch negotiations by order ID and provider email
  static Future<List<NegotiationModel>> fetchNegotiations({
    required int orderId,
    required String email,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/negotiations/order/$orderId/provider/$email/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) ?? [];
        return data.map((json) => NegotiationModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load negotiations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching negotiations: $e');
    }
  }
}
