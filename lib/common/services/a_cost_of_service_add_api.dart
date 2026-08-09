import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;


class ACostOfServiceApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// PATCH: Updates base price and descriptive notes for an explicit service profile mapping.
 static Future<Map<String, dynamic>> updateServiceCost({
  required String notes,
  
  required int serviceId,
  required double cost,
}) async {
  final url = Uri.parse("$baseUrl/a_sp_service/cost/$serviceId/");

  try {
    final response = await ApiClient.instance.request(
      (token) => http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "base_price": cost,
          "notes": notes.trim(),
        }),
      ),
    );

    final dynamic decoded = jsonDecode(response.body);
    final Map<String, dynamic> data =
        decoded is Map ? Map<String, dynamic>.from(decoded) : {};

    if (response.statusCode == 200) {
      return data;
    } else {
      if (kDebugMode) {
        print(
          '❌ SERVICE COST UPDATE REJECTED [${response.statusCode}]: ${response.body}',
        );
      }

      throw Exception(
        data["error"] ??
            data["message"] ??
            "Failed to update service cost [${response.statusCode}]",
      );
    }
  } on ApiException {
    rethrow;
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Exception in updateServiceCost: $e');
    }
    rethrow;
  }
}

  /// POST: Streams portfolio images or verification media attachments via multipart encoding.
  static Future<Map<String, dynamic>> uploadServiceImages({
  required int costId,
  required List<File> images,
}) async {
  final url = Uri.parse(
    "$baseUrl/serviceProvider/cost/$costId/images/",
  );

  try {
    final response = await ApiClient.instance.multipartRequest(
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
                "images",
                image.path,
              ),
            );
          }
        }

        return request;
      },
    );

    final dynamic decoded = jsonDecode(response.body);

    final Map<String, dynamic> data =
        decoded is Map
            ? Map<String, dynamic>.from(decoded)
            : {};

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return data;
    } else {
      if (kDebugMode) {
        print(
          '❌ IMAGE MULTIPART UPLOAD FAILED [${response.statusCode}]: ${response.body}',
        );
      }

      throw Exception(
        data["error"] ??
            data["message"] ??
            "Image upload failed [${response.statusCode}]",
      );
    }
  } on ApiException {
    rethrow;
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Exception in uploadServiceImages: $e');
    }
    rethrow;
  }
}

 
}