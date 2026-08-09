
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class UploadProviderServiceAffidavitApi {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? '';

  // Affidavit uploads may take longer when the backend
  // or KYC-related services are waking from sleep.
  static const Duration _requestTimeout =
      Duration(seconds: 90);

  // Total attempts, including the initial request.
  static const int _maxAttempts = 4;

  static const List<int> _retryableStatusCodes = [
    408,
    429,
    500,
    502,
    503,
    504,
  ];

  static Future<Map<String, dynamic>> uploadAffidavit({
    required int providerServiceId,
    required File affidavit,
  }) async {
    final url = Uri.parse(
      '$baseUrl/provider-services/'
      '$providerServiceId/affidavit/',
    );

    // Make sure the file still exists before starting.
    if (!await affidavit.exists()) {
      return {
        "success": false,
        "message": "The affidavit file could not be found.",
      };
    }

    int attempt = 0;

    while (attempt < _maxAttempts) {
      attempt++;

      try {
        final response = await ApiClient.instance
            .request(
          (token) async {
            // IMPORTANT:
            // Recreate the MultipartRequest on every attempt.
            final request = http.MultipartRequest(
              "POST",
              url,
            );

            request.headers.addAll({
              "Accept": "application/json",
              if (token != null && token.isNotEmpty)
                "Authorization": "Bearer $token",
            });

            request.files.add(
              await http.MultipartFile.fromPath(
                "affidavit",
                affidavit.path,
                contentType: MediaType.parse(
                  _mimeTypeFor(affidavit.path),
                ),
              ),
            );

            final streamedResponse =
                await request.send();

            return await http.Response.fromStream(
              streamedResponse,
            );
          },
        )
            .timeout(_requestTimeout);

        final data = _decodeResponse(response.body);

        // ----------------------------------------------------------
        // SUCCESS
        // ----------------------------------------------------------
        if (response.statusCode == 200 ||
            response.statusCode == 201) {
          return {
            "success": true,
            "data": data,
          };
        }

        // ----------------------------------------------------------
        // RETRYABLE RESPONSE
        // ----------------------------------------------------------
        if (_retryableStatusCodes
            .contains(response.statusCode)) {
          if (attempt < _maxAttempts) {
            if (kDebugMode) {
              debugPrint(
                "⚠️ Affidavit upload returned "
                "${response.statusCode}. "
                "Retrying attempt "
                "${attempt + 1}/$_maxAttempts...",
              );
            }

            await _waitBeforeRetry(attempt);
            continue;
          }

          return {
            "success": false,
            "statusCode": response.statusCode,
            "message":
                "The server is taking longer than expected. "
                "Please try again in a moment.",
            "retryExhausted": true,
          };
        }

        // ----------------------------------------------------------
        // NON-RETRYABLE RESPONSES
        // ----------------------------------------------------------
        switch (response.statusCode) {
          case 400:
            return {
              "success": false,
              "statusCode": 400,
              "message":
                  data["message"] ??
                  "Invalid affidavit submission.",
              "errors":
                  data["errors"] ?? data,
            };

          case 401:
            return {
              "success": false,
              "statusCode": 401,
              "message":
                  data["message"] ??
                  "Your session has expired. "
                  "Please log in again.",
            };

          case 403:
            return {
              "success": false,
              "statusCode": 403,
              "message":
                  data["message"] ??
                  "You do not have permission to "
                  "upload this affidavit.",
            };

          case 404:
            return {
              "success": false,
              "statusCode": 404,
              "message":
                  data["message"] ??
                  "Provider service not found.",
            };

          case 413:
            return {
              "success": false,
              "statusCode": 413,
              "message":
                  "The affidavit file is too large.",
            };

          default:
            return {
              "success": false,
              "statusCode": response.statusCode,
              "message":
                  data["message"] ??
                  "Unable to upload affidavit.",
              "errors":
                  data["errors"] ?? data,
            };
        }
      } on TimeoutException catch (_) {
        if (kDebugMode) {
          debugPrint(
            "⏱️ Affidavit upload timed out. "
            "Attempt $attempt/$_maxAttempts",
          );
        }

        if (attempt < _maxAttempts) {
          await _waitBeforeRetry(attempt);
          continue;
        }

        return {
          "success": false,
          "message":
              "The verification service is taking longer "
              "than expected. Please try again.",
          "timeout": true,
          "retryExhausted": true,
        };
      } on SocketException catch (e) {
        if (kDebugMode) {
          debugPrint(
            "🌐 Affidavit upload network error: $e",
          );
        }

        if (attempt < _maxAttempts) {
          await _waitBeforeRetry(attempt);
          continue;
        }

        return {
          "success": false,
          "message":
              "Unable to reach the server. "
              "Please check your internet connection "
              "and try again.",
          "networkError": true,
          "retryExhausted": true,
        };
      } on ApiException catch (e) {
        if (kDebugMode) {
          debugPrint(
            "⚠️ Affidavit API exception: ${e.message}",
          );
        }

        final message =
            e.message.toLowerCase();

        final isTemporary =
            message.contains("timeout") ||
            message.contains("timed out") ||
            message.contains("connection") ||
            message.contains("socket") ||
            message.contains("network") ||
            message.contains("502") ||
            message.contains("503") ||
            message.contains("504");

        if (isTemporary &&
            attempt < _maxAttempts) {
          await _waitBeforeRetry(attempt);
          continue;
        }

        return {
          "success": false,
          "message": e.message,
          "retryExhausted": isTemporary,
        };
      } on FormatException catch (_) {
        return {
          "success": false,
          "message":
              "Invalid response received from the server.",
        };
      } catch (e) {
        if (kDebugMode) {
          debugPrint(
            "❌ Upload Affidavit Error: $e",
          );
        }

        return {
          "success": false,
          "message":
              "Unable to upload affidavit.",
        };
      }
    }

    return {
      "success": false,
      "message":
          "Unable to upload affidavit. Please try again.",
      "retryExhausted": true,
    };
  }

  static String _mimeTypeFor(String path) {
    final ext =
        path.split('.').last.toLowerCase();

    switch (ext) {
      case 'pdf':
        return 'application/pdf';

      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      case 'png':
        return 'image/png';

      default:
        return 'application/octet-stream';
    }
  }

  /// Exponential backoff:
  ///
  /// Attempt 1 -> 2 seconds
  /// Attempt 2 -> 5 seconds
  /// Attempt 3 -> 10 seconds
  static Future<void> _waitBeforeRetry(
    int attempt,
  ) async {
    Duration delay;

    switch (attempt) {
      case 1:
        delay = const Duration(seconds: 2);
        break;

      case 2:
        delay = const Duration(seconds: 5);
        break;

      default:
        delay = const Duration(seconds: 10);
    }

    if (kDebugMode) {
      debugPrint(
        "⏳ Waiting ${delay.inSeconds}s before "
        "affidavit upload retry...",
      );
    }

    await Future.delayed(delay);
  }

  static Map<String, dynamic> _decodeResponse(
    String body,
  ) {
    if (body.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (_) {
      return {};
    }
  }
}

