import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProviderProfileApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<Map<String, dynamic>> updateProfile({
    File? profileImage,
    String? description,
  }) async {
    final url = Uri.parse(
      "$baseUrl/provider/profile-image/",
    );

    try {
      final response = await ApiClient.instance.multipartRequest(
        (token) async {
          final request = http.MultipartRequest("POST", url);

          if (token != null) {
            request.headers["Authorization"] = "Bearer $token";
          }

          if (description != null) {
            request.fields["sp_description"] = description;
          }

          if (profileImage != null) {
            request.files.add(
              await http.MultipartFile.fromPath(
                "profile_image",
                profileImage.path,
              ),
            );
          }

          return request;
        },
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return data;
      }

      throw Exception(
        data["message"] ?? "Failed to update profile.",
      );
    } on ApiException {
      rethrow;
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ ProviderProfileApi Error: $e");
        print("📌 STACKTRACE: $stack");
      }

      rethrow;
    }
  }
}