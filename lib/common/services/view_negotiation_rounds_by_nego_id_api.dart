import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';

class ViewNegotiationRoundsByNegoIdApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Fetch all rounds for a given negotiation ID
  static Future<List<NegotiationRound>> fetchRoundsByNegotiationId(int negotiationId) async {
    final url = Uri.parse('$baseUrl/bookings/service_orders/negotiation/rounds/$negotiationId/');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NegotiationRound.fromJson(json)).toList();
      } else {
        throw Exception('❌ Failed to fetch negotiation rounds. [${response.statusCode}] ${response.body}');
      }
    } catch (e) {
      throw Exception('⚠️ Network or parsing error while fetching negotiation rounds: $e');
    }
  }
}
