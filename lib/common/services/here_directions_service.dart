// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:huawei_map/huawei_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:flexible_polyline/flexible_polyline.dart';

// class HereDirectionsService {
//   static const String _apiKey =
//       "2BTA08Eye_B0Qf3tpwudm2IaGvFTIuPK8ux1VIOYROg";

//   static const String _baseUrl =
//       "https://router.hereapi.com/v8/routes";

//   Future<List<LatLng>> getRoute({
//     required LatLng origin,
//     required LatLng destination,
//   }) async {
//     final uri = Uri.parse(
//       "$_baseUrl"
//       "?transportMode=car"
//       "&origin=${origin.lat},${origin.lng}"
//       "&destination=${destination.lat},${destination.lng}"
//       "&return=polyline"
//       "&apiKey=$_apiKey",
//     );

//     try {
//       debugPrint("📡 HERE request → $uri");

//       final response = await http.get(uri);

//       if (response.statusCode != 200) {
//         debugPrint("❌ HERE HTTP ${response.statusCode}");
//         debugPrint(response.body);
//         return [];
//       }

//       final data = jsonDecode(response.body);

//       final String? encodedPolyline =
//           data["routes"]?[0]?["sections"]?[0]?["polyline"];

//       if (encodedPolyline == null) {
//         debugPrint("❌ HERE polyline missing");
//         return [];
//       }

//       final decoded = FlexiblePolyline.decode(encodedPolyline);

//       final points = decoded
//           .map((p) => LatLng(p.lat, p.lng))
//           .toList();

//       debugPrint("✅ HERE route decoded: ${points.length} points");
//       return points;
//     } catch (e, stack) {
//       debugPrint("❌ HERE exception: $e");
//       debugPrint(stack.toString());
//       return [];
//     }
//   }
// }
