// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter_application_2/common/controller/registration/api_client.dart';
// import 'package:flutter_application_2/common/controller/registration/api_exeption.dart';
// import 'package:flutter_application_2/common/models/models/client_models/sp_live_location_post_model.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;

// class SpLiveLocationService {
//   static final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

//   /// POST: Transmits real-time service provider geo-coordinates to the backend gateway.
//   static Future<bool> sendLiveLocation(
//     SpLiveLocationPostModel location,
//   ) async {
//     try {
//       final response = await ApiClient.instance.request(
//         (token) => http.post(
//           Uri.parse(
//             '$baseUrl/service_providers/sp/update-live-location/',
//           ),
//           headers: {
//             'Content-Type': 'application/json',
//             'Accept': 'application/json',
//             if (token != null && token.isNotEmpty)
//               'Authorization': 'Bearer $token',
//           },
//           body: jsonEncode(location.toJson()),
//         ),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return true;
//       }

//       if (kDebugMode) {
//         debugPrint(
//           '❌ Location telemetry failure '
//           '[${response.statusCode}]: ${response.body}',
//         );
//       }

//       String message = 'Failed to send live location.';

//       if (response.body.isNotEmpty) {
//         final decoded = jsonDecode(response.body);

//         if (decoded is Map) {
//           message = decoded['detail'] ??
//               decoded['message'] ??
//               decoded['error'] ??
//               message;
//         }
//       }

//       throw ApiException(message);
//     } on ApiException {
//       rethrow;
//     } on FormatException {
//       throw const ApiException(
//         'Invalid response received from the server.',
//       );
//     } catch (e) {
//       if (kDebugMode) {
//         debugPrint(
//           '⚠️ Exception dispatching service provider telemetry: $e',
//         );
//       }

//       throw const ApiException(
//         'Failed to send live location.',
//       );
//     }
//   }
// }