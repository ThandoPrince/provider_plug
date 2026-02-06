import 'dart:async';

import 'package:here_sdk/core.dart';
import 'package:here_sdk/routing.dart' as here;
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_route_model.dart';
import 'here_map_controller.dart';

/// Map backend travel_mode string to TravelMode enum
TravelMode mapTravelMode(String mode) {
  switch (mode.toLowerCase()) {
    case "car":
      return TravelMode.car;
    case "pedestrian":
      return TravelMode.pedestrian;
    case "bicycle":
      return TravelMode.bicycle;
    case "scooter":
      return TravelMode.scooter;
    default:
      return TravelMode.car;
  }
}

/// Standalone converter: converts a backend ShipmentRoute to a HERE SDK Route
Future<here.Route> convertShipmentRouteToHereRoute(ShipmentRoute route) async {
  final routingEngine = here.RoutingEngine();

  final waypoints = [
    here.Waypoint(GeoCoordinates(route.originLat, route.originLng)),
    here.Waypoint(GeoCoordinates(route.destinationLat, route.destinationLng)),
  ];

  // Determine transport mode
  final travelMode = mapTravelMode(route.travelMode ?? "car");

  final completer = Completer<List<here.Route>>();

  void callback(here.RoutingError? error, List<here.Route>? routes) {
    if (error != null) {
      completer.completeError("Routing failed: ${error.toString()}");
    } else {
      completer.complete(routes ?? []);
    }
  }

  switch (travelMode) {
    case TravelMode.car:
      routingEngine.calculateCarRoute(waypoints, here.CarOptions(), callback);
      break;
    case TravelMode.pedestrian:
      routingEngine.calculatePedestrianRoute(
          waypoints, here.PedestrianOptions(), callback);
      break;
    case TravelMode.bicycle:
    case TravelMode.scooter:
      routingEngine.calculateBicycleRoute(
          waypoints, here.BicycleOptions(), callback);
      break;
  }

  final routes = await completer.future;
  if (routes.isEmpty) {
    throw Exception("Failed to convert ShipmentRoute ${route.routeId}");
  }

  return routes.first;
}
