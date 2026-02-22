import 'dart:convert';
import 'package:flutter_application_2/common/models/models/services_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class FetchApprovedServicesApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
  // use 10.0.2.2 for Android emulator

  static Future<List<ServiceModel>> fetchApprovedServices() async {
  final response = await http.get(
    Uri.parse("$baseUrl/approved_services/"),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((service) =>
            ServiceModel.fromJson(service as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception("Failed to fetch services");
  }
}
}