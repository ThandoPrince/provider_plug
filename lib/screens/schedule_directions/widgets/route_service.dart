import 'package:flutter/foundation.dart';
import 'package:here_sdk/routing.dart' as here;

import 'here_map_controller.dart';

typedef RouteUpdateCallback = void Function(
  double? distanceKm,
  int? durationMinutes,
);

class RouteService {
  final HereMapControllerHelper mapHelper;

  here.Route? _activeRoute;
  bool _isRecalculating = false;

  RouteService(this.mapHelper);

  // ------------------------------------------------------------
  // GETTERS
  // ------------------------------------------------------------
  here.Route? get activeRoute => _activeRoute;
  bool get hasRoute => _activeRoute != null;

  // ------------------------------------------------------------
  // INITIAL ROUTE
  // ------------------------------------------------------------
  Future<void> calculateAndShowRoute({
    required List<here.Waypoint> waypoints,
    required TravelMode mode,
    required RouteUpdateCallback onRouteUpdated,
  }) async {
    try {
      final routes =
          await mapHelper.calculateRouteAsync(waypoints, mode);

      if (routes.isEmpty) {
        debugPrint("❌ No routes returned");
        onRouteUpdated(null, null);
        return;
      }

      _setActiveRoute(routes.first, onRouteUpdated);
    } catch (e) {
      debugPrint("❌ Routing exception: $e");
      onRouteUpdated(null, null);
    }
  }

  // ------------------------------------------------------------
  // AUTO RE-ROUTING (OFF-ROUTE ONLY)
  // ------------------------------------------------------------
  void startAutoUpdate({
    required List<here.Waypoint> originalWaypoints,
    required TravelMode mode,
    required RouteUpdateCallback onRouteUpdated,
  }) {
    if (_activeRoute == null) return;

    mapHelper.startNavigationTracking(
      route: _activeRoute!,
      mode: mode,
      onUpdate: (geo, bearing, _) async {
        if (_isRecalculating || _activeRoute == null) return;

        final offRoute =
            mapHelper.isOffRoute(geo, _activeRoute!);

        if (!offRoute) return;

        _isRecalculating = true;

        final updatedWaypoints = [
          here.Waypoint(geo),
          originalWaypoints.last,
        ];

        await calculateAndShowRoute(
          waypoints: updatedWaypoints,
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
  void _setActiveRoute(
    here.Route route,
    RouteUpdateCallback onRouteUpdated,
  ) {
    _activeRoute = route;

    mapHelper
      ..drawRoute(route)
      ..zoomToRoute(route);

    onRouteUpdated(
      route.lengthInMeters / 1000,
      (route.duration.inSeconds / 60).round(),
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
