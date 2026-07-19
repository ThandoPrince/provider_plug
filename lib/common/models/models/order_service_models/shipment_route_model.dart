import 'package:flutter_application_2/screens/schedule_directions/widgets/here_map_controller.dart';

class ShipmentRoute {
  final int routeId;
  final int shipmentId;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final int distanceMeters;
  final int durationSeconds;
  final Map<String, dynamic> geometry;
  final bool recalculated;
  final bool? isActive;
  final DateTime? createdAt;
   final String? travelMode; 

  ShipmentRoute({
    required this.routeId,
    required this.shipmentId,
    required this.originLat,
    this.travelMode, 
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.geometry,
    required this.recalculated,
    this.isActive,
    this.createdAt,
  });

  factory ShipmentRoute.fromJson(Map<String, dynamic> json) {
    
    int shipmentIdValue;
    if (json['shipment'] is int) {
      shipmentIdValue = json['shipment'] as int;
    } else if (json['shipment'] is Map<String, dynamic>) {
      shipmentIdValue = json['shipment']['shipment_id'] as int;
    } else {
      throw Exception('Unexpected shipment type in JSON: ${json['shipment']}');
    }

    return ShipmentRoute(
      routeId: json['route_id'] as int,
       travelMode: json['travel_mode'] as String?,
      shipmentId: shipmentIdValue,
      originLat: (json['origin_lat'] as num).toDouble(),
      originLng: (json['origin_lng'] as num).toDouble(),
      destinationLat: (json['destination_lat'] as num).toDouble(),
      destinationLng: (json['destination_lng'] as num).toDouble(),
      distanceMeters: json['distance_meters'] as int,
      durationSeconds: json['duration_seconds'] as int,
      geometry: json['geometry'] as Map<String, dynamic>,
      recalculated: json['recalculated'] as bool,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
            
    );

  }

  Map<String, dynamic> toJson() {
    return {
      "route_id": routeId,
      "shipment": shipmentId,
      "origin_lat": originLat,
      "origin_lng": originLng,
      "destination_lat": destinationLat,
      "destination_lng": destinationLng,
      "distance_meters": distanceMeters,
      "duration_seconds": durationSeconds,
      "geometry": geometry,
      "recalculated": recalculated,
      "is_active": isActive,
      "created_at": createdAt?.toIso8601String(),
      if (travelMode != null) 'travel_mode': travelMode,
    };
  }
}


TravelMode travelModeFromString(String? mode) {
  switch (mode?.toLowerCase()) {
    case "pedestrian":
      return TravelMode.pedestrian;
    case "bicycle":
      return TravelMode.bicycle;
    case "scooter":
      return TravelMode.scooter;
    case "car":
    default:
      return TravelMode.car;
  }
}