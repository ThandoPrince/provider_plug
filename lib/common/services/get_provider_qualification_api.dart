import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/models/models/provider_qualification_model.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GetProviderQualificationApi {
  static final String baseUrl =
      dotenv.env["API_BASE_URL"] ?? "";

  static const Duration _timeout =
      Duration(seconds: 15);

  static Exception _handleError(Object e) {
    if (e is TimeoutException) {
      return Exception(
        "Server timeout. Please try again.",
      );
    }

    if (e is SocketException) {
      return Exception(
        "Server unreachable. Check your internet connection.",
      );
    }

    return Exception(
      "Unexpected error occurred.",
    );
  }

  static Future<T> _withRetry<T>(
    Future<T> Function() request, {
    int retries = 2,
    Duration delay =
        const Duration(milliseconds: 500),
  }) async {
    try {
      return await request();
    } catch (e) {
      if (retries <= 0) rethrow;

      await Future.delayed(delay);

      return _withRetry(
        request,
        retries: retries - 1,
        delay: delay * 2,
      );
    }
  }

  static Future<List<ProviderQualificationModel>>
    fetchQualification(
  int providerServiceId,
) async {
    final url = Uri.parse(
      "$baseUrl/provider-qualifications/$providerServiceId/",
    );

    try {
      final response = await _withRetry(() async {
        return await ApiClient.instance.request(
          (token) async {
            return await http
                .get(
                  url,
                  headers: {
                    "Content-Type":
                        "application/json",
                    if (token != null)
                      "Authorization":
                          "Bearer $token",
                  },
                )
                .timeout(_timeout);
          },
        ).timeout(_timeout);
      });

      print(
          "========== PROVIDER QUALIFICATION ==========");
      print("URL: $url");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      print(
          "===========================================");

      if (response.statusCode != 200) {
        throw Exception(
          "Server error (${response.statusCode}).",
        );
      }

      final decoded = jsonDecode(response.body);

if (decoded is! Map<String, dynamic>) {
  throw Exception("Invalid response format.");
}

return ProviderQualificationModel.listFromJson(
  decoded["data"] as List<dynamic>,
);
    } catch (e) {
      throw _handleError(e);
    }
  }
}