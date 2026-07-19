import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/common/controller/registration/api_client.dart';
import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class UploadProviderServiceAffidavitApi {
  static final String baseUrl = dotenv.env['MEDIA_BASE_URL'] ?? '';

  static Future<Map<String, dynamic>> uploadAffidavit({
    required int providerServiceId,
    required File affidavit,
  }) async {
    try {

       String mimeTypeFor(String path) {
  final ext = path.split('.').last.toLowerCase();
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
      final response = await ApiClient.instance.request(
        (token) async {
          final request = http.MultipartRequest(
            "POST",
            Uri.parse(
              "$baseUrl/provider-services/$providerServiceId/affidavit/",
            ),
          );

          if (token != null && token.isNotEmpty) {
            request.headers["Authorization"] = "Bearer $token";
          }

          request.headers["Accept"] = "application/json";

          request.files.add(
  await http.MultipartFile.fromPath(
    "affidavit",
    affidavit.path,
    contentType: MediaType.parse(mimeTypeFor(affidavit.path)),
  ),
);

          return await http.Response.fromStream(
            await request.send(),
          );
        },
      );

      final Map<String, dynamic> data =
          response.body.isNotEmpty
              ? jsonDecode(response.body)
              : <String, dynamic>{};

      if (response.statusCode == 201) {
        return data;
      }

      throw ApiException(
        data["message"] ??
            "Failed to upload affidavit [${response.statusCode}]",
      );
    } on ApiException {
      rethrow;
    } on FormatException {
      throw const ApiException(
        "Invalid response received from the server.",
      );
    } catch (e) {
      if (kDebugMode) {
        print("Upload Affidavit Error: $e");
      }

      throw const ApiException(
        "Unable to upload affidavit.",
      );
    }
  }

 


}