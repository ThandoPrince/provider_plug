import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';

class BookingByOrderidApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<OrderService> fetchBookingByOrderID(int orderID) async {
    final url = Uri.parse('$baseUrl/bookings/service_orders/$orderID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
          if (kDebugMode) {
      print('Response body: ${response.body}');}
    
      final Map<String, dynamic> data = json.decode(response.body);
      return OrderService.fromJson(data);
    } else {
      throw Exception('Booking Info: ${response.statusCode}');
    }
  }
}
