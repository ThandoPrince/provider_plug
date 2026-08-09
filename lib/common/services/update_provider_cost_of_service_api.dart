
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CostOfServiceApi {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  /// Update service pricing/details
  static Future<Map<String, dynamic>> updateServiceCost({
    required int costId,
    required double cost,
    required String notes,
  }) async {
    final url = Uri.parse(
      "$baseUrl/cost-of-service/$costId/update/",
    );

    try {
      final response = await ApiClient.instance.request(
        (token) => http.patch(
          url,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
            if (token != null)
              "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "base_price": cost,
            "notes": notes.trim(),
          }),
        ),
      );

      final dynamic decoded =
          jsonDecode(response.body);

      final Map<String, dynamic> data =
          decoded is Map
              ? Map<String, dynamic>.from(decoded)
              : {};

      if (response.statusCode == 200) {
        return data;
      }

      if (kDebugMode) {
        print(
          "❌ UPDATE COST FAILED [${response.statusCode}] ${response.body}",
        );
      }

      throw Exception(
        data["message"] ??
            data["error"] ??
            "Unable to update service.",
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ updateServiceCost: $e");
      }
      rethrow;
    }
  }

  /// Upload gallery images
  static Future<Map<String, dynamic>> uploadServiceImages({
    required int costId,
    required List<File> images,
  }) async {
    final url = Uri.parse(
      "$baseUrl/serviceProvider/cost/$costId/images/",
    );

    try {
      final response =
          await ApiClient.instance.multipartRequest(
        (token) async {
          final request = http.MultipartRequest(
            "POST",
            url,
          );

          request.headers["Accept"] =
              "application/json";

          if (token != null) {
            request.headers["Authorization"] =
                "Bearer $token";
          }

          for (final image in images) {
            if (await image.exists()) {
              request.files.add(
                await http.MultipartFile.fromPath(
                  "images",
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
            "Image upload failed.",
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ uploadServiceImages: $e");
      }
      rethrow;
    }
  }
}