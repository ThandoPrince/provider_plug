import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/ratings_model.dart';

class ProviderCompletedServicesApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// GET: Fetches historical review ratings completed by a service provider email.
  static Future<List<RatingModel>> fetchRatingsByProviderEmail(String email) async {
    final url = Uri.parse('$baseUrl/bookings/get_ratings/by_provider_email/${email.trim().toLowerCase()}/');
    
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

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        if (decodedData is List) {
          return decodedData
              .map((json) => RatingModel.fromJson(Map<String, dynamic>.from(json as Map)))
              .toList();
        }
        throw const FormatException('Expected a JSON array schema payload for historical rating models.');
      } else {
        if (kDebugMode) {
          print('❌ Ratings retrieval failed [${response.statusCode}]: ${response.body}');
        }
        throw Exception('Server rejected ratings history fetch with status: [${response.statusCode}]');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Exception caught inside fetchRatingsByProviderEmail: $e');
      }
      throw Exception('Network or mapping error processing historical rating metrics: $e');
    }
  }
}