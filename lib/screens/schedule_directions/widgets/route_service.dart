import 'package:flutter/foundation.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/directions_service.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_map_controller.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_route_conversion.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



typedef RouteUpdateCallback = void Function(
  double? distanceKm,
  int? durationMinutes,
);

class RouteService {
  final GoogleMapControllerHelper mapHelper;
  final DirectionsService directionsService;

  AppRoute? _activeRoute;
  bool _isRecalculating = false;

  RouteService(this.mapHelper, {DirectionsService? directionsService})
      : directionsService = directionsService ?? DirectionsService();

  AppRoute? get activeRoute => _activeRoute;
  bool get hasRoute => _activeRoute != null;

  // ------------------------------------------------------------
  // INITIAL ROUTE
  // ------------------------------------------------------------
  Future<void> calculateAndShowRoute({
    required LatLng origin,
    required LatLng destination,
    required TravelMode mode,
    required RouteUpdateCallback onRouteUpdated,
  }) async {
    try {
      final route = await directionsService.getRoute(
        origin: origin,
        destination: destination,
        mode: mode,
      );

      if (route == null) {
        debugPrint("❌ No route returned");
        onRouteUpdated(null, null);
        return;
      }

      _setActiveRoute(route, onRouteUpdated);
    } catch (e) {
      debugPrint("❌ Routing exception: $e");
      onRouteUpdated(null, null);
    }
  }

  // ------------------------------------------------------------
  // AUTO RE-ROUTING (OFF-ROUTE ONLY)
  // ------------------------------------------------------------
  void startAutoUpdate({
    required LatLng destination,
    required TravelMode mode,
    required RouteUpdateCallback onRouteUpdated,
  }) {
    if (_activeRoute == null) return;

    mapHelper.startNavigationTracking(
      route: _activeRoute!,
      onUpdate: (geo, bearing, route) async {
        if (_isRecalculating) return;

        final offRoute = mapHelper.isOffRoute(geo, route.polylinePoints);
        if (!offRoute) return;

        _isRecalculating = true;

        await calculateAndShowRoute(
          origin: geo,
          destination: destination,
          mode: mode,
          onRouteUpdated: onRouteUpdated,
        );

        _isRecalculating = false;
      },
    );
  }

  // ------------------------------------------------------------
  // INTERNAL
  // ------------------------------------------------------------
  void _setActiveRoute(AppRoute route, RouteUpdateCallback onRouteUpdated) {
    _activeRoute = route;

    mapHelper.drawRoute(route);
    mapHelper.zoomToBounds(route.bounds);

    onRouteUpdated(
      route.distanceMeters / 1000,
      (route.durationSeconds / 60).round(),
    );
  }

  // ------------------------------------------------------------
  // CLEANUP
  // ------------------------------------------------------------
  void dispose() {
    mapHelper.dispose();
    _activeRoute = null;
  }
}