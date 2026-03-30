import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CostOfServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> updateServiceCost({
    required String notes,
    required String email,
    required int serviceId,
    required double cost,
    String? token,
  }) async {
    final url = Uri.parse(
      "$baseUrl/sp_service/$email/cost/$serviceId/",
    );

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "base_price": cost,
        "notes": notes,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data["error"] ?? "Failed to update service cost");
    }
  }

  Future<Map<String, dynamic>> uploadServiceImages({
    required int costId,
    required List<File> images,
    String? token,
  }) async {
    final url = Uri.parse(
      "$baseUrl/serviceProvider/cost/$costId/images/",
    );

    final request = http.MultipartRequest("POST", url);

    if (token != null) {
      request.headers["Authorization"] = "Bearer $token";
    }

    for (final image in images) {
      request.files.add(
        await http.MultipartFile.fromPath("images", image.path),
      );
    }

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);
    final data = jsonDecode(responseBody.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data["error"] ?? "Image upload failed");
    }
  }

  Future<Map<String, dynamic>> updatePushToken({
    required String email,
    required String token,
    required String provider,
    String? deviceType,
    String? deviceName,
    String? osVersion,
    String? appVersion,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/sp/register/device-token/',
    );

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email.toLowerCase(),
          "push_token": token,
          "device_type": deviceType,
          "device_name": deviceName,
          "os_version": osVersion,
          "app_version": appVersion,
          "provider": provider,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        "statusCode": response.statusCode,
        "data": data,
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {
          "error": "Failed to update push token: $e",
        },
      };
    }
  }
}