import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/client_models/sp_live_location_post_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SpLiveLocationService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<bool> sendLiveLocation(SpLiveLocationPostModel location) async {
    final url = Uri.parse('$baseUrl/service_providers/sp/update-live-location/');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(location.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Failed to send location: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Error sending live location: $e");
      return false;
    }
  }
}
