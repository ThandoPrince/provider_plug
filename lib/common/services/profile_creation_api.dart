import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class SPProfileCreationApiHelper {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> patchSPProfile({
    required String email,
    Map<String, dynamic>? data,
    File? profileImage,
  }) async {
    final url = Uri.parse('$baseUrl/sp_details/upload/$email/'); 

    try {
      final request = http.MultipartRequest('PATCH', url);

      // Add text fields
      data?.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add file if exists
      if (profileImage != null) {
        final mimeType = lookupMimeType(profileImage.path)?.split('/') ?? ['image', 'jpeg'];
        request.files.add(await http.MultipartFile.fromPath(
          'profile_image',
          profileImage.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {"success": true, "data": decoded};
      } else {
        // --- PRO ERROR PARSING ---
        String message = "Update failed";
        if (decoded is Map) {
          if (decoded.containsKey('errors')) {
            // Get the first specific error message (e.g., ID mismatch)
            var errorMap = decoded['errors'] as Map;
            message = errorMap.values.first[0].toString();
          } else if (decoded.containsKey('message')) {
            message = decoded['message'];
          }
        }
        return {
          "success": false,
          "message": message,
          "errors": decoded['errors'] // Pass the full map for field-level highlighting
        };
      }
    } catch (e) {
      return {"success": false, "message": "Connection error: ${e.toString()}"};
    }
  }
}