import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProviderQualificationApi {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<Map<String, dynamic>> uploadQualification({
    required int providerServiceId,
    required File document,
    required String documentType,
    required String title,
    String issuingBody = "",
    DateTime? issueDate,
    DateTime? expiryDate,
  }) async {
    final url = Uri.parse(
      "$baseUrl/provider-services/$providerServiceId/qualifications/",
    );

    try {
      final response = await ApiClient.instance.multipartRequest(
        (token) async {
          final request = http.MultipartRequest("POST", url);

          if (token != null) {
            request.headers["Authorization"] = "Bearer $token";
          }

          request.fields["document_type"] = documentType;
          request.fields["title"] = title;
          request.fields["issuing_body"] = issuingBody;

          if (issueDate != null) {
            request.fields["issue_date"] =
                issueDate.toIso8601String().split("T").first;
          }

          if (expiryDate != null) {
            request.fields["expiry_date"] =
                expiryDate.toIso8601String().split("T").first;
          }

          request.files.add(
            await http.MultipartFile.fromPath(
              "document",
              document.path,
            ),
          );

          return request;
        },
      );

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        return data;
      }

      throw Exception(
        data["message"] ?? "Failed to upload qualification.",
      );
    } on ApiException {
      rethrow;
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ ProviderQualificationApi Error: $e");
        print("📌 STACKTRACE: $stack");
      }

      rethrow;
    }
  }
}