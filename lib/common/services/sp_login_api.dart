
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/models/provider_login_response_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SPLoginApi {
  final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/sp_login/');

    try {
      final response = await http
          .post(
            url,
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "identifier": email.toLowerCase(),
              "password": password,
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

          if (kDebugMode) {
            print("LOGIN STATUS: ${response.statusCode}");
          }
if (kDebugMode) {
  print("LOGIN BODY: ${response.body}");
}

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = response.body;
      }

      // ---------------------------------------------
      // SUCCESS
      // ---------------------------------------------
      if (response.statusCode == 200) {
        return {
          "success": true,
          "statusCode": response.statusCode,
          "data": ProviderLoginResponseModel.fromJson(data),
          "error": null,
        };
      }

      // ---------------------------------------------
      // BACKEND ERROR
      // ---------------------------------------------
      return {
        "success": false,
        "statusCode": response.statusCode,
        "data": data,
        "error": _extractErrorMessage(data),
      };
    } on SocketException {
      return {
        "success": false,
        "statusCode": null,
        "data": null,
        "error": "Unable to connect to the server.",
      };
    } on http.ClientException catch (e) {
      return {
        "success": false,
        "statusCode": null,
        "data": null,
        "error": "Network error: ${e.message}",
      };
    } on FormatException {
      return {
        "success": false,
        "statusCode": null,
        "data": null,
        "error": "Invalid response received from the server.",
      };
    } catch (e) {
      return {
        "success": false,
        "statusCode": null,
        "data": null,
        "error": "An unexpected error occurred.",
      };
    }
  }

  // =================================================
  // EXTRACT BACKEND ERROR
  // =================================================

String _extractErrorMessage(dynamic data) {
  if (data == null) {
    return "Login failed. Please try again.";
  }

  if (data is Map) {
    // ---------------------------------------------
    // Your backend structure:
    //
    // {
    //   "success": false,
    //   "errors": {
    //     "non_field_errors": [
    //       "Account temporarily locked. Try again in 8 minute(s)."
    //     ]
    //   }
    // }
    // ---------------------------------------------

    final errors = data['errors'];

    if (errors is Map) {
      // Django REST Framework non-field errors
      final nonFieldErrors =
          errors['non_field_errors'];

      if (nonFieldErrors is List &&
          nonFieldErrors.isNotEmpty) {
        return nonFieldErrors.first.toString();
      }

      if (nonFieldErrors is String &&
          nonFieldErrors.trim().isNotEmpty) {
        return nonFieldErrors.trim();
      }

      // Handle other field errors
      final messages = <String>[];

      errors.forEach((key, value) {
        if (value is List) {
          for (final item in value) {
            messages.add(item.toString());
          }
        } else if (value != null) {
          messages.add(value.toString());
        }
      });

      if (messages.isNotEmpty) {
        return messages.join('\n');
      }
    }

    // ---------------------------------------------
    // Fallback: non_field_errors directly on response
    // ---------------------------------------------

    final nonFieldErrors =
        data['non_field_errors'];

    if (nonFieldErrors is List &&
        nonFieldErrors.isNotEmpty) {
      return nonFieldErrors.first.toString();
    }

    // ---------------------------------------------
    // detail
    // ---------------------------------------------

    final detail = data['detail'];

    if (detail != null) {
      return detail.toString();
    }

    // ---------------------------------------------
    // error
    // ---------------------------------------------

    final error = data['error'];

    if (error != null) {
      return error.toString();
    }

    // ---------------------------------------------
    // message
    // ---------------------------------------------

    final message = data['message'];

    if (message != null) {
      return message.toString();
    }
  }

  // ---------------------------------------------
  // Plain text response
  // ---------------------------------------------

  if (data is String &&
      data.trim().isNotEmpty) {
    return data.trim();
  }

  return "Login failed. Please try again.";
}
  // =================================================
  // UPDATE PUSH TOKEN
  // =================================================

  Future<Map<String, dynamic>> updatePushToken({
    required String email,
    required String token,
    required String provider,
    required String authToken,
    String? deviceType,
    String? deviceName,
    String? osVersion,
    String? appVersion,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/sp/register/device-token/',
    );

    final Map<String, String> requestHeaders = {
      'Content-Type': 'application/json',
    };

    if (authToken.isNotEmpty) {
      requestHeaders['Authorization'] =
          'Bearer $authToken';
    }

    try {
      final response = await http.post(
        uri,
        headers: requestHeaders,
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

      dynamic data;

      try {
        data = jsonDecode(response.body);
      } catch (_) {
        data = response.body;
      }

      return {
        "statusCode": response.statusCode,
        "data": data,
      };
    } catch (e) {
      return {
        "statusCode": 500,
        "data": {
          "error": "Failed to update push token.",
        },
      };
    }
  }
}
