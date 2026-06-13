import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/services_model.dart';

class FetchApprovedServicesApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches a list of globally approved services with secure session headers.
  static Future<List<ServiceModel>> fetchApprovedServices() async {
    final url = Uri.parse("$baseUrl/approved_services/");
    
    // Auto-extract the active access token from the session state manager
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      switch (response.statusCode) {
        case 200:
          final dynamic decodedData = jsonDecode(response.body);
          if (decodedData is List) {
            return decodedData
                .map((service) => ServiceModel.fromJson(Map<String, dynamic>.from(service as Map)))
                .toList();
          }
          throw const FormatException("Server did not yield an array schema layout.");
        
        case 401:
          throw Exception("Unauthorized: Please log in again.");
        case 404:
          throw Exception("Services not found (404).");
        case 500:
          throw Exception("Server error: Please try again later.");
        default:
          throw Exception("Unexpected error: ${response.statusCode}");
      }
    } on SocketException {
      throw Exception("No internet connection. Please check your settings.");
    } on TimeoutException {
      throw Exception("Connection timed out. The server is taking too long.");
    } on FormatException catch (e) {
      if (kDebugMode) print('❌ JSON Deserialization Fault: $e');
      throw Exception("Invalid data format received from server.");
    } catch (e) {
      if (kDebugMode) print('⚠️ Generic API Pipeline Exception: $e');
      throw Exception("An unexpected error occurred: $e");
    }
  }
}