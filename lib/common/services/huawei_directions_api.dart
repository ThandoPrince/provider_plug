// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:huawei_map/huawei_map.dart';
// import 'package:http/http.dart' as http;
// import 'package:flexible_polyline/flexible_polyline.dart';

// class HereDirectionsService {
//   static const String _apiKey = "ZR5d-d45ioRC8OENZcOH4sdUmvsvVpowTdMxQepJ85Q";
//   static const String _baseUrl = "https://router.hereapi.com/v8/routes";

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
//       debugPrint("📡 HERE Directions request");
//       final response = await http.get(uri);

//       if (response.statusCode != 200) {
//         debugPrint("❌ HERE HTTP ${response.statusCode}");
//         return [];
//       }

//       final data = jsonDecode(response.body);

//       final polyline =
//           data["routes"]?[0]?["sections"]?[0]?["polyline"];

//       if (polyline == null) {
//         debugPrint("❌ HERE polyline missing");
//         return [];
//       }

//       final decoded = FlexiblePolyline.decode(polyline);

//       return decoded
//           .map((p) => LatLng(p.lat, p.lng))
//           .toList();
//     } catch (e, stack) {
//       debugPrint("❌ HERE exception: $e");
//       debugPrint(stack.toString());
//       return [];
//     }
//   }
// }
