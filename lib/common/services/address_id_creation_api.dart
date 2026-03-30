import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class SPAddressDocumentApiHelper {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<Map<String, dynamic>> addAddressDocument({
    required String email,
    required Map<String, dynamic> address,
    required String idType, // "greenbook" or "card"
    File? frontFile,
    File? backFile,
  }) async {
    final url = Uri.parse('$baseUrl/sp/upload/address_document/');

    try {
      final request = http.MultipartRequest('POST', url);
      

      request.fields['email'] = email;
      request.fields['id_type'] = idType;

      // Handle Lat/Long precision
      if (address['latitude'] != null) {
        address['latitude'] =
            double.parse(address['latitude'].toString()).toStringAsFixed(6);
      }
      if (address['longitude'] != null) {
        address['longitude'] =
            double.parse(address['longitude'].toString()).toStringAsFixed(6);
      }

      request.fields['address'] = jsonEncode(address);

      // Add Front File (Required for both)
      if (frontFile != null) {
        final mimeType = frontFile.path.split('.').last;
        request.files.add(await http.MultipartFile.fromPath(
          'front_file',
          frontFile.path,
          contentType:
              MediaType('image', mimeType == 'pdf' ? 'pdf' : 'jpeg'),
        ));
      }

      // Add Back File (Required for Smart Card only)
      if (backFile != null) {
  final mimeType = backFile.path.split('.').last;
  request.files.add(await http.MultipartFile.fromPath(
    'back_file',
    backFile.path,
    contentType: MediaType('image', mimeType == 'pdf' ? 'pdf' : 'jpeg'),
  ));
}

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 201|| response.statusCode == 200) {
        return {"success": true, "data": decoded};
      } else {
        return {
          "success": false,
          "message": decoded["message"] ?? "Check your ID and Address details.",
          "errors": decoded["errors"] ?? decoded,
        };
      }
    } on SocketException {
    return {"success": false, "message": "No internet connection. Please check your network."};
  } on TimeoutException {
    return {"success": false, "message": "The server took too long to respond. Try smaller photos."};
  } catch (e) {
    return {"success": false, "message": "An unexpected error occurred: $e"};
  }
}
  }
