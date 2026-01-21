// service_provider_api.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;



class NewBookingsByEmailApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<OrderService>> fetchNewBookingByEmail(String email) async {
    final url = Uri.parse('$baseUrl/bookings/sp_active_orders/$email/');
    final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    if (kDebugMode) {
      // print('Response body: ${response.body}');
    }
    return data.map((item) => OrderService.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load New Bookings: ${response.statusCode}');
  }
}
  }



