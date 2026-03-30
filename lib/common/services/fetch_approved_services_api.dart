import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter_application_2/common/models/models/services_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FetchApprovedServicesApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<List<ServiceModel>> fetchApprovedServices() async {
    try {
      final response = await http
          .get(
            Uri.parse("$baseUrl/approved_services/"),
          )
          .timeout(const Duration(seconds: 10)); // Prevent infinite waiting

      switch (response.statusCode) {
        case 200:
          final List<dynamic> data = jsonDecode(response.body);
          return data
              .map((service) =>
                  ServiceModel.fromJson(service as Map<String, dynamic>))
              .toList();
        
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
      // Triggered when there is no internet connection
      throw Exception("No internet connection. Please check your settings.");
    } on TimeoutException {
      // Triggered when the server takes too long to respond
      throw Exception("Connection timed out. The server is taking too long.");
    } on FormatException {
      // Triggered if the JSON returned is malformed
      throw Exception("Invalid data format received from server.");
    } catch (e) {
      // Catch-all for any other errors
      throw Exception("An unexpected error occurred: $e");
    }
  }
}