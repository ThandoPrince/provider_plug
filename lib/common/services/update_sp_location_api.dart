import 'dart:convert';
import 'package:http/http.dart' as http;

class UpdateSpLocationApi {
  final String baseUrl;

  UpdateSpLocationApi({required this.baseUrl});

  Future<bool> updateServiceProviderLocation({
    required String spEmail,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/service_providersDB/update_sp_live_location/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sp_email': spEmail,
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update location: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error in API call: $e');
      return false;
    }
  }
}
