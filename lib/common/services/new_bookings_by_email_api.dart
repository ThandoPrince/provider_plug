import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';

class NewBookingsByEmailApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches a collection of active service bookings tied to a specific provider email.
  static Future<List<OrderService>> fetchNewBookingByEmail(String email) async {
    final url = Uri.parse('$baseUrl/bookings/sp_active_orders/${email.trim().toLowerCase()}/');
    
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

      switch (response.statusCode) {
        case 200:
          final dynamic decodedData = json.decode(response.body);
          if (decodedData is List) {
            return decodedData
                .map((item) => OrderService.fromJson(Map<String, dynamic>.from(item as Map)))
                .toList();
          }
          throw const FormatException('Server payload did not return an array schema structure.');
          
        case 401:
          throw Exception('Unauthorized access. Please re-authenticate.');
          
        case 404:
          throw Exception('Endpoint not found (404). Check backend routing.');
          
        case 500:
          throw Exception('Server error (500). Please try again later.');
          
        default:
          throw Exception('Unexpected network error: [${response.statusCode}]');
      }
    } on SocketException {
      throw Exception('No Internet connection. Check your network.');
    } on TimeoutException {
      throw Exception('Connection timed out. Server is taking too long to respond.');
    } on FormatException catch (e) {
      if (kDebugMode) print('❌ JSON Deserialization Fault: $e');
      throw Exception('Bad response data format configuration.');
    } catch (e) {
      if (kDebugMode) print('⚠️ Generic API Pipeline Exception: $e');
      throw Exception('An unknown error occurred matching transaction index: $e');
    }
  }
}