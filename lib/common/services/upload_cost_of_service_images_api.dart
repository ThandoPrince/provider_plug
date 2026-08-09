import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UploadCostOfServiceImagesApi {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  static Future<Map<String, dynamic>> uploadImages({
    required int costId,
    required List<File> images,
  }) async {
    final url = Uri.parse(
      "$baseUrl/sp/cost-of-service/$costId/images/",
    );

    try {
      final response =
          await ApiClient.instance.multipartRequest(
        (token) async {
          final request = http.MultipartRequest(
            "POST",
            url,
          );

          request.headers["Accept"] = "application/json";

          if (token != null) {
            request.headers["Authorization"] =
                "Bearer $token";
          }

          for (final image in images) {
            if (await image.exists()) {
              request.files.add(
                await http.MultipartFile.fromPath(
                  "image",
                  image.path,
                ),
              );
            }
          }

          return request;
        },
      );

      final dynamic decoded =
          jsonDecode(response.body);

      final Map<String, dynamic> data =
          decoded is Map
              ? Map<String, dynamic>.from(decoded)
              : {};

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        return data;
      }

      if (kDebugMode) {
        print(
          "❌ IMAGE UPLOAD FAILED [${response.statusCode}] ${response.body}",
        );
      }

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Failed to upload images.",
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ uploadImages: $e");
      }
      rethrow;
    }
  }
}