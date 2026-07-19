import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class SPProfileCreationApiHelper {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> patchSPProfile({
    Map<String, dynamic>? data,
    File? profileImage,
  }) async {
    try {
      final response = await ApiClient.instance.multipartRequest(
        (token) async {
          final request = http.MultipartRequest(
            'PATCH',
            Uri.parse('$baseUrl/sp_details/upload/'),
          );

          request.headers['Accept'] = 'application/json';

          if (token != null) {
            request.headers['Authorization'] = 'Bearer $token';
          }

          data?.forEach((key, value) {
            request.fields[key] = value.toString();
          });

          if (profileImage != null && await profileImage.exists()) {
            final mimeType =
                    lookupMimeType(profileImage.path)?.split('/') ??
                ['image', 'jpeg'];

            request.files.add(
              await http.MultipartFile.fromPath(
                'profile_image',
                profileImage.path,
                contentType: MediaType(
                  mimeType[0],
                  mimeType[1],
                ),
              ),
            );
          }

          return request;
        },
      );

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 200) {
        return {
          "success": true,
          "statusCode": response.statusCode,
          "data": decoded,
        };
      }

      String message = "Update failed";

      if (decoded is Map) {
        if (decoded.containsKey('errors')) {
          final errorMap = decoded['errors'];

          if (errorMap is Map && errorMap.isNotEmpty) {
            final firstValue = errorMap.values.first;

            if (firstValue is List && firstValue.isNotEmpty) {
              message = firstValue.first.toString();
            }
          }
        } else if (decoded.containsKey('message')) {
          message = decoded['message'].toString();
        }
      }

      return {
        "success": false,
        "statusCode": response.statusCode,
        "message": message,
        "errors": decoded is Map ? decoded['errors'] : null,
      };
    } on ApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        print("⚠️ Exception in SPProfileCreationApiHelper: $e");
      }

      return {
        "success": false,
        "message": "Connection error: $e",
      };
    }
  }
}