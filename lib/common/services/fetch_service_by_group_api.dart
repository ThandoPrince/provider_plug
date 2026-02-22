import 'dart:convert';
import 'package:flutter_application_2/common/models/models/service_groups.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class FetchServiceByGroupApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';



  /// Fetch all service groups from the backend
  Future<List<ServiceGroupModel>> fetchServiceGroups() async {
    final uri = Uri.parse('$baseUrl/service_groups/');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ServiceGroupModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load service groups');
    }
  }
}