import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/models/models/order_service_models/negotiation/negotiation_round_model.dart';

class StartSpProviderNegotiationApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// Starts a negotiation round for a provider
  static Future<NegotiationRound?> startProviderRound({
    required int negotiationId,
    required String providerEmail,
    String? message,
    double? offeredPrice,
  }) async {
    final url = Uri.parse(
      '$baseUrl/bookings/service_orders/negotiation/$negotiationId/provider_start_round/',
    );

    final Map<String, dynamic> body = {
      'provider_email': providerEmail,
      if (message != null && message.isNotEmpty) 'message': message,
      if (offeredPrice != null) 'offered_price': offeredPrice,
    };

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return NegotiationRound.fromJson(data);
    } else {
      print('❌ Failed to start negotiation round: ${response.body}');
      throw Exception('Failed to start negotiation round');
    }
  }
}
