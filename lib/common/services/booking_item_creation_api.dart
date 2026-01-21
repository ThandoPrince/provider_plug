import 'dart:convert';
import 'package:flutter_application_2/common/models/models/order_service_models/booking_item_model.dart';
import 'package:http/http.dart' as http;



class BookingItemCreationApi {
  final String baseUrl;

  BookingItemCreationApi({required this.baseUrl});

  /// Call provider accept negotiation endpoint
  Future<AcceptNegotiationResponse> acceptNegotiation({
    required int negotiationId,
    required String token, // if using auth
  }) async {
    final url = Uri.parse('$baseUrl/api/bookings/service_orders/negotiation/provider_accepts_negotiation/$negotiationId/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // optional
        },
        // body: jsonEncode({}), // include if endpoint expects any payload
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AcceptNegotiationResponse.fromJson(data);
      } else {
        // Handle non-200 responses
        throw Exception(
          'Failed to accept negotiation. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      // Handle network or parsing errors
      throw Exception('Error calling accept negotiation API: $e');
    }
  }
}
