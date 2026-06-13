import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';

class BookingByOrderidApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches a single booking service order instance by its unique database ID.
  static Future<OrderService> fetchBookingByOrderID(int orderID) async {
    // Appended trailing slash to maintain standard REST routing alignment
    final url = Uri.parse('$baseUrl/bookings/provider_service_orders/$orderID/');
    
    // Auto-extract the secure access token from the session state manager
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('String 📡 [BookingByOrderidApi] Status: ${response.statusCode}');
        print('String 📨 [BookingByOrderidApi] Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);
        if (decodedBody is Map) {
          return OrderService.fromJson(Map<String, dynamic>.from(decodedBody));
        }
        throw const FormatException('Expected a JSON object container representation for the booking model.');
      } else {
        throw Exception('Server rejected booking order query with status: [${response.statusCode}]');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception caught inside fetchBookingByOrderID: $e');
      }
      throw Exception('Network or mapping error processing booking record ID $orderID: $e');
    }
  }
}