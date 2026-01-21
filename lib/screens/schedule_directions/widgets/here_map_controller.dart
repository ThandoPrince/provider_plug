import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as here;

import 'package:flutter_application_2/common/models/models/order_service_models/shipment_route_model.dart';
import 'package:flutter_application_2/common/services/shipment_route_api.dart';

/// Nullable helper
extension Nullable<T> on T? {
  void let(void Function(T it) fn) {
    final v = this;
    if (v != null) fn(v);
  }
}

enum TravelMode { car, pedestrian, bicycle, scooter }

class HereMapControllerHelper {
  final HereMapController mapController;
  final here.RoutingEngine _routingEngine = here.RoutingEngine();

  MapPolyline? _routePolyline;
  MapMarker? _originMarker;
  MapMarker? _destinationMarker;
  MapMarker? _userMarker;
  MapImage? _userArrowImage;

  StreamSubscription<Position>? _positionSubscription;
  GeoCoordinates? get userCoordinates => _userMarker?.coordinates;

  final int shipmentId;
  GeoCoordinates? _lastPostedCoordinates;

   final double _minPostDistanceMeters;

  HereMapControllerHelper(this.mapController, {required this.shipmentId, double minPostDistanceMeters = 10.0, }): _minPostDistanceMeters = minPostDistanceMeters;

  // ---------------------------
  // SERIALIZE ROUTE GEOMETRY
  // ---------------------------
  Map<String, dynamic> _serializeGeometry(here.Route route) {
    return {
      'vertices': route.geometry.vertices
          .map((v) => {'lat': v.latitude, 'lng': v.longitude})
          .toList(),
    };
  }

  // ---------------------------
  // MARKERS
  // ---------------------------
  Future<void> _ensureUserMarker() async {
    if (_userArrowImage != null) return;

    _userArrowImage = await MapImage.withFilePathAndWidthAndHeight(
      "assets/icons/map_icons/sp_marker.png",
      96,
      96,
    );
  }

  Future<void> updateUserMarker(GeoCoordinates geo) async {
    await _ensureUserMarker();

    if (_userMarker == null) {
      _userMarker = MapMarker(geo, _userArrowImage!)
        ..anchor = Anchor2D.withHorizontalAndVertical(0.5, 0.5);
      mapController.mapScene.addMapMarker(_userMarker!);
    }

    _userMarker!.coordinates = geo;
  }

  Future<void> addOriginMarker(GeoCoordinates origin, MapImage originImage) async {
    _originMarker?.let(mapController.mapScene.removeMapMarker);

    _originMarker = MapMarker(origin, originImage)
      ..anchor = Anchor2D.withHorizontalAndVertical(0.5, 1);

    mapController.mapScene.addMapMarker(_originMarker!);
  }

  Future<void> addDestinationMarker(GeoCoordinates destination, MapImage destinationImage) async {
    _destinationMarker?.let(mapController.mapScene.removeMapMarker);

    _destinationMarker = MapMarker(destination, destinationImage)
      ..anchor = Anchor2D.withHorizontalAndVertical(0.5, 1);

    mapController.mapScene.addMapMarker(_destinationMarker!);
  }

  // ---------------------------
  // DRAW & ZOOM ROUTE
  // ---------------------------
  void drawRoute(here.Route route) {
    _routePolyline?.let(mapController.mapScene.removeMapPolyline);

    final width = MapMeasureDependentRenderSize.withSingleSize(RenderSizeUnit.pixels, 7);
    final rep = MapPolylineSolidRepresentation(width, const Color(0xFF007AFF), LineCap.round);

    _routePolyline = MapPolyline.withRepresentation(route.geometry, rep);
    mapController.mapScene.addMapPolyline(_routePolyline!);
  }

  void zoomToRoute(here.Route route) {
    mapController.camera.applyUpdate(MapCameraUpdateFactory.lookAtArea(route.boundingBox));
  }

  // ---------------------------
  // OFF-ROUTE DETECTION
  // ---------------------------
  bool isOffRoute(GeoCoordinates user, here.Route route) {
    double minDistance = double.infinity;

    for (final v in route.geometry.vertices) {
      final d = user.distanceTo(v);
      if (d < minDistance) minDistance = d;
    }

    return minDistance > 40; // meters
  }

  // ---------------------------
  // LOCATION HELPERS
  // ---------------------------
  /// Get current device position
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  /// Move map camera to a given position, updating user marker
  Future<void> focusOnLocation(Position pos) async {
    final geo = GeoCoordinates(pos.latitude, pos.longitude);
    await updateUserMarker(geo);

    mapController.camera.lookAtPointWithGeoOrientationAndMeasure(
      geo,
      GeoOrientationUpdate(0, 50),
      MapMeasure(MapMeasureKind.distanceInMeters, 700),
    );
  }

  // ---------------------------
  // ROUTE CALCULATION
  // ---------------------------
  Future<List<here.Route>> calculateRouteAsync(List<here.Waypoint> waypoints, TravelMode mode) async {
    final completer = Completer<List<here.Route>>();
    calculateRoute(waypoints, mode, (error, routes) {
      completer.complete(routes ?? []);
    });
    return completer.future;
  }

  void calculateRoute(List<here.Waypoint> waypoints, TravelMode mode,
      void Function(here.RoutingError?, List<here.Route>?) callback) {
    switch (mode) {
      case TravelMode.car:
        _routingEngine.calculateCarRoute(waypoints, here.CarOptions(), callback);
        break;
      case TravelMode.pedestrian:
        _routingEngine.calculatePedestrianRoute(waypoints, here.PedestrianOptions(), callback);
        break;
      case TravelMode.bicycle:
      case TravelMode.scooter:
        _routingEngine.calculateBicycleRoute(waypoints, here.BicycleOptions(), callback);
        break;
    }
  }

  // ---------------------------
  // NAVIGATION + AUTO POST
  // ---------------------------
  void startNavigationTracking({
    required here.Route route,
    required TravelMode mode,
    required void Function(GeoCoordinates geo, double bearing, here.Route updatedRoute) onUpdate,
  }) {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((pos) async {
      final geo = GeoCoordinates(pos.latitude, pos.longitude);
      final bearing = pos.heading;

      await updateUserMarker(geo);

      // Move camera to follow user
      mapController.camera.lookAtPointWithGeoOrientationAndMeasure(
        geo,
        GeoOrientationUpdate(bearing, 50),
        MapMeasure(MapMeasureKind.distanceInMeters, 700),
      );

      // Off-route recalculation
      if (isOffRoute(geo, route)) {
        final routes = await calculateRouteAsync([
          here.Waypoint(geo),
          here.Waypoint(route.sections.last.arrivalPlace.mapMatchedCoordinates),
        ], mode);

        if (routes.isNotEmpty) route = routes.first;
      }

      // Notify UI
      onUpdate(geo, bearing, route);

      
      if (_lastPostedCoordinates == null ||
          _lastPostedCoordinates!.distanceTo(geo) >= _minPostDistanceMeters) {

        final routeModel = ShipmentRoute(
          routeId: 0,
          shipmentId: shipmentId,
          originLat: geo.latitude,
          originLng: geo.longitude,
          destinationLat: route.sections.last.arrivalPlace.mapMatchedCoordinates.latitude,
          destinationLng: route.sections.last.arrivalPlace.mapMatchedCoordinates.longitude,
          distanceMeters: route.lengthInMeters.round(),
          durationSeconds: route.duration.inSeconds,
          geometry: _serializeGeometry(route),
          recalculated: false,
        );

        try {
          await ShipmentRouteApi.postShipmentRoute(routeModel);
          if (kDebugMode) print("✅ ShipmentRoute posted for shipment $shipmentId");
          _lastPostedCoordinates = geo; // update last posted position
        } catch (e) {
          if (kDebugMode) print("❌ Failed to post ShipmentRoute: $e");
        }
      }
    });
  }

  void dispose() {
    _positionSubscription?.cancel();
  }
}
