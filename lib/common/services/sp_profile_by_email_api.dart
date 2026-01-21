import 'dart:convert';
import 'package:flutter_application_2/common/models/models/sp_details_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class SpProfileByEmailApi {
  // Use final instead of const
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<ServiceProviderModel> fetchSpProfileByEmail(String email) async {
    final url = Uri.parse('$baseUrl/service_providers/$email/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return ServiceProviderModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  static Future<List<ServiceProviderModel>> fetchSpProfile() async {
    final url = Uri.parse('$baseUrl/service_providers/');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ServiceProviderModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load profiles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profiles: $e');
    }
  }
}
