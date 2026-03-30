import 'dart:convert';
import 'package:flutter_application_2/common/models/models/order_service_models/ratings_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProviderCompletedServicesApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<List<RatingModel>> fetchRatingsByProviderEmail(String email) async {
    final url = Uri.parse(
      '$baseUrl/bookings/get_ratings/by_provider_email/$email/',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => RatingModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch provider ratings: ${response.body}');
    }
  }
}