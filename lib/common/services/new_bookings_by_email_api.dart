
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;



class NewBookingsByEmailApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<OrderService>> fetchNewBookingByEmail(String email) async {
    final url = Uri.parse('$baseUrl/bookings/sp_active_orders/$email/');
    
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      switch (response.statusCode) {
        case 200:
          final List<dynamic> data = json.decode(response.body);
          return data.map((item) => OrderService.fromJson(item)).toList();
        case 404:
          throw Exception('Endpoint not found (404)');
        case 500:
          throw Exception('Server error (500). Please try again later.');
        default:
          throw Exception('Unexpected error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection. Check your network.');
    } on TimeoutException {
      throw Exception('Connection timed out. Server is taking too long.');
    } on FormatException {
      throw Exception('Bad response format. Contact support.');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
}