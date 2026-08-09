
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SPAddressDocumentApiHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  // KYC can take longer when the service is waking from sleep.
  static const Duration _requestTimeout = Duration(seconds: 90);

  // Maximum number of attempts INCLUDING the first request.
  static const int _maxAttempts = 4;

  static const List<int> _retryableStatusCodes = [
    408,
    429,
    500,
    502,
    503,
    504,
  ];

  static Future<Map<String, dynamic>> addAddressDocument({
    required Map<String, dynamic> address,
    required String idType,
    File? frontFile,
    File? backFile,
    File? livenessVideo,
  }) async {
    final url = Uri.parse(
      '$baseUrl/sp/upload/address_document/',
    );

    int attempt = 0;

    while (attempt < _maxAttempts) {
      attempt++;

      try {
        final response = await ApiClient.instance
            .multipartRequest(
          (token) async {
            final request = http.MultipartRequest(
              'POST',
              url,
            );

            request.headers.addAll({
              'Accept': 'application/json',
              if (token != null)
                'Authorization': 'Bearer $token',
            });

            request.fields['id_type'] =
                idType.trim().toLowerCase();

            final sanitized =
                Map<String, dynamic>.from(address);

            if (sanitized['latitude'] != null) {
              sanitized['latitude'] = double.parse(
                sanitized['latitude'].toString(),
              ).toStringAsFixed(6);
            }

            if (sanitized['longitude'] != null) {
              sanitized['longitude'] = double.parse(
                sanitized['longitude'].toString(),
              ).toStringAsFixed(6);
            }

            request.fields['address'] =
                jsonEncode(sanitized);

            // Rebuild the multipart files on EVERY attempt.
            //
            // MultipartRequest bodies are streams, so we should
            // never attempt to reuse the previous request.
            if (frontFile != null &&
                await frontFile.exists()) {
              request.files.add(
                await _createMultipartFile(
                  'front_file',
                  frontFile,
                ),
              );
            }

            if (backFile != null &&
                await backFile.exists()) {
              request.files.add(
                await _createMultipartFile(
                  'back_file',
                  backFile,
                ),
              );
            }

            if (livenessVideo != null &&
                await livenessVideo.exists()) {
              request.files.add(
                await _createMultipartFile(
                  'liveness_video',
                  livenessVideo,
                ),
              );
            }

            return request;
          },
        )
            .timeout(_requestTimeout);

        final Map<String, dynamic> body =
            _decodeResponse(response.body);

        // ----------------------------------------------------------
        // SUCCESS
        // ----------------------------------------------------------
        if (response.statusCode == 200 ||
            response.statusCode == 201) {
          return {
            "success": true,
            "data": body,
          };
        }

        // ----------------------------------------------------------
        // RETRYABLE SERVER / NETWORK CONDITIONS
        // ----------------------------------------------------------
        if (_retryableStatusCodes
            .contains(response.statusCode)) {
          if (attempt < _maxAttempts) {
            await _waitBeforeRetry(attempt);
            continue;
          }

          return {
            "success": false,
            "statusCode": response.statusCode,
            "message":
                "The verification service is taking longer than expected. "
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
                  body["message"] ??
                  "Invalid request.",
              "errors":
                  body["errors"] ?? body,
            };

          case 401:
            return {
              "success": false,
              "statusCode": 401,
              "message":
                  body["message"] ??
                  "Your session has expired. Please log in again.",
            };

          case 403:
            return {
              "success": false,
              "statusCode": 403,
              "message":
                  body["message"] ??
                  "Permission denied.",
            };

          case 404:
            return {
              "success": false,
              "statusCode": 404,
              "message":
                  body["message"] ??
                  "Verification endpoint not found.",
            };

          case 413:
            return {
              "success": false,
              "statusCode": 413,
              "message":
                  "Uploaded file is too large.",
            };

          default:
            return {
              "success": false,
              "statusCode": response.statusCode,
              "message":
                  body["message"] ??
                  "An unexpected server error occurred.",
              "errors":
                  body["errors"] ?? body,
            };
        }
      } on TimeoutException catch (_) {
        // The KYC service may be waking up.
        if (attempt < _maxAttempts) {
          await _waitBeforeRetry(attempt);
          continue;
        }

        return {
          "success": false,
          "message":
              "The verification service is taking longer than expected. "
              "Please check your connection and try again.",
          "timeout": true,
          "retryExhausted": true,
        };
      } on SocketException catch (_) {
        // Network temporarily unavailable.
        if (attempt < _maxAttempts) {
          await _waitBeforeRetry(attempt);
          continue;
        }

        return {
          "success": false,
          "message":
              "Unable to reach the verification service. "
              "Please check your internet connection and try again.",
          "networkError": true,
          "retryExhausted": true,
        };
      } on ApiException catch (e) {
        // Don't blindly retry API-layer errors unless they indicate
        // a temporary/network problem.
        final message = e.message.toLowerCase();

        final isTemporary =
            message.contains('timeout') ||
            message.contains('timed out') ||
            message.contains('connection') ||
            message.contains('socket') ||
            message.contains('network') ||
            message.contains('503') ||
            message.contains('502') ||
            message.contains('504');

        if (isTemporary && attempt < _maxAttempts) {
          await _waitBeforeRetry(attempt);
          continue;
        }

        return {
          "success": false,
          "message": e.message,
          "retryExhausted": isTemporary,
        };
      } catch (e) {
        // Unexpected application/client error.
        return {
          "success": false,
          "message":
              "An unexpected error occurred. Please try again.",
        };
      }
    }

    return {
      "success": false,
      "message":
          "Unable to complete verification. Please try again.",
      "retryExhausted": true,
    };
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

    await Future.delayed(delay);
  }

  static Map<String, dynamic> _decodeResponse(
    String responseBody,
  ) {
    if (responseBody.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return {};
    } catch (_) {
      return {};
    }
  }

  static Future<http.MultipartFile> _createMultipartFile(
    String fieldName,
    File file,
  ) async {
    final extension =
        file.path.split('.').last.toLowerCase();

    late final MediaType type;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        type = MediaType('image', 'jpeg');
        break;

      case 'png':
        type = MediaType('image', 'png');
        break;

      case 'pdf':
        type = MediaType('application', 'pdf');
        break;

      case 'mp4':
        type = MediaType('video', 'mp4');
        break;

      case 'mov':
        type = MediaType('video', 'quicktime');
        break;

      case 'avi':
        type = MediaType('video', 'x-msvideo');
        break;

      default:
        type = MediaType(
          'application',
          'octet-stream',
        );
    }

    return http.MultipartFile.fromPath(
      fieldName,
      file.path,
      contentType: type,
    );
  }
}
