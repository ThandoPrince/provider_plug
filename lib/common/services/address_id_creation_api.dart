import 'dart:convert';
import 'dart:io';

import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SPAddressDocumentApiHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  static Future<Map<String, dynamic>> addAddressDocument({
  
  required Map<String, dynamic> address,
  required String idType,
  File? frontFile,
  File? backFile,

  // 🔥 NEW
  File? livenessVideo,
}) async {
    final url = Uri.parse(
      '$baseUrl/sp/upload/address_document/',
    );

    try {
      final response = await ApiClient.instance.multipartRequest(
        (token) async {
          final request = http.MultipartRequest(
            'POST',
            url,
          );

          request.headers.addAll({
            'Accept': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
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
if (livenessVideo != null && await livenessVideo.exists()) {
  request.files.add(
    await _createMultipartFile(
      'liveness_video',
      livenessVideo,
    ),
  );
}
          return request;
        },
      );

      final Map<String, dynamic> body =
          response.body.isNotEmpty
              ? Map<String, dynamic>.from(
                  jsonDecode(response.body),
                )
              : {};

      switch (response.statusCode) {
        case 200:
        case 201:
          return {
            "success": true,
            "data": body,
          };

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
                "Endpoint not found.",
          };

        case 413:
          return {
            "success": false,
            "statusCode": 413,
            "message":
                "Uploaded file is too large.",
          };

        case 429:
          return {
            "success": false,
            "statusCode": 429,
            "message":
                "Too many requests. Please try again later.",
          };

        case 500:
        case 502:
        case 503:
          return {
            "success": false,
            "statusCode": response.statusCode,
            "message":
                "Server temporarily unavailable.",
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
    } on ApiException catch (e) {
      return {
        "success": false,
        "message": e.message,
      };
    } catch (_) {
      return {
        "success": false,
        "message":
            "An unexpected error occurred.",
      };
    }
  }

static Future<http.MultipartFile> _createMultipartFile(
  String fieldName,
  File file,
) async {
  final extension = file.path.split('.').last.toLowerCase();

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
      type = MediaType('application', 'octet-stream');
  }

  return http.MultipartFile.fromPath(
    fieldName,
    file.path,
    contentType: type,
  );
}
}