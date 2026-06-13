import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

class SPAddressDocumentApiHelper {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST: Uploads address data alongside identity documents (e.g., Greenbook/Smart Card) via multipart encoding.
  static Future<Map<String, dynamic>> addAddressDocument({
    required String email,
    required Map<String, dynamic> address,
    required String idType, // "greenbook" or "card"
    File? frontFile,
    File? backFile,
  }) async {
    final url = Uri.parse('$baseUrl/sp/upload/address_document/');
    final String? token = AuthSessionController.instance.accessToken;

    try {
      final request = http.MultipartRequest('POST', url);
      
      // Inject global authorization headers into the multipart request
      request.headers['Accept'] = 'application/json';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Populate form data text parameters
      request.fields['email'] = email.trim().toLowerCase();
      request.fields['id_type'] = idType.trim().toLowerCase();

      // Deep copy and sanitize spatial coordinates to exactly 6 decimal places (~10cm precision)
      final Map<String, dynamic> sanitizedAddress = Map<String, dynamic>.from(address);
      if (sanitizedAddress['latitude'] != null) {
        sanitizedAddress['latitude'] = double.parse(sanitizedAddress['latitude'].toString()).toStringAsFixed(6);
      }
      if (sanitizedAddress['longitude'] != null) {
        sanitizedAddress['longitude'] = double.parse(sanitizedAddress['longitude'].toString()).toStringAsFixed(6);
      }
      request.fields['address'] = jsonEncode(sanitizedAddress);

      // Attach identity media files safely
      if (frontFile != null && await frontFile.exists()) {
        request.files.add(await _createMultipartFile('front_file', frontFile));
      }
      if (backFile != null && await backFile.exists()) {
        request.files.add(await _createMultipartFile('back_file', backFile));
      }

      // Dispatch request with a prolonged 30-second multi-part network timeout guard
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      
      final dynamic decodedBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      final Map<String, dynamic> dataMap = decodedBody is Map ? Map<String, dynamic>.from(decodedBody) : {};

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "data": dataMap};
      } else {
        if (kDebugMode) {
          print('❌ KYC DOCUMENT UPLOAD REJECTED [${response.statusCode}]: ${response.body}');
        }
        return {
          "success": false,
          "statusCode": response.statusCode,
          "message": dataMap["message"] ?? "Check your ID and Address details.",
          "errors": dataMap["errors"] ?? dataMap,
        };
      }
    } on SocketException {
      return {"success": false, "message": "No internet connection. Please check your network."};
    } on TimeoutException {
      return {"success": false, "message": "The server took too long to respond. Try smaller photos or compress them."};
    } catch (e) {
      if (kDebugMode) print('⚠️ Exception caught in SPAddressDocumentApiHelper: $e');
      return {"success": false, "message": "An unexpected error occurred during KYC verification."};
    }
  }

  /// Helper utility to dynamically resolve multi-part file payloads and resolve mime-types cleanly
  static Future<http.MultipartFile> _createMultipartFile(String fieldName, File file) async {
    final String extension = file.path.split('.').last.toLowerCase();
    
    // Explicitly target PDF structures vs standard compressed images
    final MediaType contentType = extension == 'pdf' 
        ? MediaType('application', 'pdf') 
        : MediaType('image', 'jpeg');

    return http.MultipartFile.fromPath(
      fieldName,
      file.path,
      contentType: contentType,
    );
  }
}