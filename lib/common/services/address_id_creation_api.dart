import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SPAddressDocumentApiHelper {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  /// POST address and optional document for SP by email
  Future<Map<String, dynamic>> addAddressDocument({
  required String email,
  required Map<String, dynamic> address,
  File? documentFile,
  String? documentName,
}) async {
  final url = Uri.parse('$baseUrl/sp/upload/address_document/');

  try {
    final request = http.MultipartRequest('POST', url);

    request.fields['email'] = email;

    // 🔥 ROUND LAT/LONG TO 6 DECIMAL PLACES
    if (address['latitude'] != null) {
      address['latitude'] =
          double.parse(address['latitude'].toString())
              .toStringAsFixed(6);
    }

    if (address['longitude'] != null) {
      address['longitude'] =
          double.parse(address['longitude'].toString())
              .toStringAsFixed(6);
    }

    request.fields['address'] = jsonEncode(address);

    if (documentFile != null && documentName != null) {
      final mimeType = documentFile.path.split('.').last;
      request.files.add(await http.MultipartFile.fromPath(
        'document_file',
        documentFile.path,
        filename: documentName,
        contentType: MediaType('application', mimeType),
      ));
      request.fields['document_name'] = documentName;
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return {"success": true, "data": decoded};
    } else {
      return {
        "success": false,
        "message": decoded["error"] ?? "Failed to add address/document",
        "errors": decoded,
      };
    }
  } catch (e) {
    return {"success": false, "message": e.toString()};
  }
}
}