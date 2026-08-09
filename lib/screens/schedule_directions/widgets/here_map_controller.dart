import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/directions_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_application_2/common/services/session_socket_service.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_route_model.dart';

/// Replaces `HereMapControllerHelper`.
///
/// google_maps_flutter doesn't expose an imperative "scene" you mutate like
/// HERE's MapScene did — markers/polylines are just props passed into the
/// `GoogleMap` widget. To keep the same call style you had before
/// (`_helper.drawRoute(route)`, `_helper.addOriginMarker(...)`), this class
/// extends ChangeNotifier and holds the marker/polyline sets itself. Screens
/// wrap `GoogleMap` in a `ListenableBuilder` listening to this helper, so a
/// call to e.g. `drawRoute()` triggers a rebuild automatically.
///
/// This version also owns the "chase cam" following behaviour used during
/// active navigation: instead of snapping the marker/camera to each raw GPS
/// fix, it glides between fixes, derives bearing from the actual movement
/// vector (device compass heading is noisy at low speed), zooms based on
/// speed, and tilts + looks ahead of the driver the way Uber/MrD-style
/// delivery-navigation UIs do.
class GoogleMapControllerHelper extends ChangeNotifier {
  GoogleMapController? controller;
  final SessionSocketService sessionSocket;
  final int shipmentId;
  final double _minPostDistanceMeters;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  /// Mirrors the old `userCoordinates` getter on HereMapControllerHelper.
  LatLng? userCoordinates;

  StreamSubscription<Position>? _positionSubscription;
  LatLng? _lastPostedCoordinates;
  BitmapDescriptor? _userMarkerIcon;

  // ---------------------------
  // FOLLOW-CAM STATE
  // ---------------------------
  Timer? _followTicker;
  double _lastBearing = 0;
  double _currentZoom;
  bool _hasFixedFirstPosition = false;
  bool _following = true;
  bool _programmaticMove = false;

  /// How long each marker/camera glide takes between GPS fixes. Roughly
  /// matching your expected fix interval keeps motion from ever looking
  /// like it's "waiting" (too long) or "rushing" (too short).
  final Duration followDuration;

  /// Camera tilt while following. 0 = straight top-down, ~45-60 = the
  /// tilted chase-cam look nav apps use.
  final double followTilt;

  /// How far ahead of the driver (in meters) the camera looks, in the
  /// direction of travel. This is what makes the road ahead visible instead
  /// of centering the driver dead-center of the screen.
  final double lookAheadMeters;

  GoogleMapControllerHelper({
    required this.sessionSocket,
    required this.shipmentId,
    double minPostDistanceMeters = 10.0,
    this.followDuration = const Duration(milliseconds: 900),
    this.followTilt = 55,
    this.lookAheadMeters = 40,
    double initialZoom = 17.5,
  })  : _minPostDistanceMeters = minPostDistanceMeters,
        _currentZoom = initialZoom;

  /// Call from `GoogleMap(onMapCreated: ...)`.
  void attachController(GoogleMapController controller) {
    this.controller = controller;
  }

  void setUserMarkerIcon(BitmapDescriptor icon) {
    _userMarkerIcon = icon;
  }

  // ---------------------------
  // FOLLOW / RECENTER
  // ---------------------------
  bool get isFollowing => _following;

  /// Stop the camera auto-following the user — call this when the driver
  /// drags the map to look ahead/around.
  void stopFollowing() {
    if (!_following) return;
    _following = false;
    notifyListeners();
  }

  /// Re-lock the camera onto the driver and glide back. Wire this to a
  /// "recenter" button, shown whenever `isFollowing` is false.
  void resumeFollowing() {
    _following = true;
    if (userCoordinates != null) {
      _moveCameraTo(
        _lookAheadTarget(userCoordinates!, _lastBearing),
        _lastBearing,
        animated: true,
        zoomOverride: _currentZoom,
      );
    }
    notifyListeners();
  }

  /// `GoogleMap.onCameraMoveStarted` fires for *every* camera move,
  /// including the ones we trigger ourselves 30x/second while following.
  /// We flag our own moves right before making them; the screen calls this
  /// from `onCameraMoveStarted` — if it returns false, the move wasn't ours,
  /// i.e. the driver dragged the map, so the screen should stop following.
  bool consumeProgrammaticMoveFlag() {
    final wasProgrammatic = _programmaticMove;
    _programmaticMove = false;
    return wasProgrammatic;
  }

  // ---------------------------
  // LOCATION
  // ---------------------------
  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
  }

  // ---------------------------
  // MARKERS
  // ---------------------------
  void setOriginMarker(LatLng position, BitmapDescriptor icon) {
    markers.removeWhere((m) => m.markerId.value == 'origin');
    markers.add(Marker(
      markerId: const MarkerId('origin'),
      position: position,
      icon: icon,
      anchor: const Offset(0.5, 1),
    ));
    notifyListeners();
  }

  void setDestinationMarker(LatLng position, BitmapDescriptor icon) {
    markers.removeWhere((m) => m.markerId.value == 'destination');
    markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: position,
      icon: icon,
      anchor: const Offset(0.5, 1),
    ));
    notifyListeners();
  }

  /// Direct, non-animated marker placement. Used for one-off calls (e.g. a
  /// "my location" tap outside active navigation). During navigation, the
  /// follow loop drives the marker itself via `_setUserMarkerRaw`.
  void setUserMarker(LatLng position, {double bearing = 0, BitmapDescriptor? icon}) {
    if (icon != null) _userMarkerIcon = icon;
    _setUserMarkerRaw(position, bearing);
  }

  void _setUserMarkerRaw(LatLng position, double bearing) {
    userCoordinates = position;
    markers.removeWhere((m) => m.markerId.value == 'user');
    markers.add(Marker(
      markerId: const MarkerId('user'),
      position: position,
      icon: _userMarkerIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      rotation: bearing,
      anchor: const Offset(0.5, 0.5),
      flat: true,
    ));
    notifyListeners();
  }

  void clearUserMarker() {
    userCoordinates = null;
    markers.removeWhere((m) => m.markerId.value == 'user');
    notifyListeners();
  }

  // ---------------------------
  // ROUTE / CAMERA
  // ---------------------------
  void drawRoute(AppRoute route) {
    polylines.removeWhere((p) => p.polylineId.value == 'route');
    polylines.add(Polyline(
      polylineId: const PolylineId('route'),
      points: route.polylinePoints,
      width: 5,
      color: const Color(0xFF007AFF),
    ));
    notifyListeners();
  }

  /// Frames the whole route — used for the initial route preview (before
  /// navigation starts). Deliberately NOT used mid-navigation: bounds-fitting
  /// on every reroute would yank the camera out to an overview shot every
  /// time the driver goes off-route, which is disorienting. During active
  /// navigation the follow-cam handles zoom/tilt/bearing continuously.
  Future<void> zoomToBounds(LatLngBounds bounds, {double padding = 60}) async {
    if (controller == null) return;
    _programmaticMove = true;
    await controller!.animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
  }

  Future<void> focusOnLocation(LatLng position, {double bearing = 0, double zoom = 17}) async {
    if (controller == null) return;
    _programmaticMove = true;
    await controller!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: zoom, bearing: bearing),
    ));
  }

  Future<void> _moveCameraTo(
    LatLng target,
    double bearing, {
    required bool animated,
    double? zoomOverride,
  }) async {
    if (controller == null) return;
    _programmaticMove = true;
    final camPos = CameraPosition(
      target: target,
      zoom: zoomOverride ?? _currentZoom,
      bearing: bearing,
      tilt: followTilt,
    );
    if (animated) {
      await controller!.animateCamera(CameraUpdate.newCameraPosition(camPos));
    } else {
      // Plain moveCamera (no built-in animation) — we're already driving
      // the interpolation ourselves frame-by-frame in `_glideTo`, so an
      // additional native animation here would fight it.
      await controller!.moveCamera(CameraUpdate.newCameraPosition(camPos));
    }
  }

  /// Projects a point `distanceMeters` ahead of `origin` along `bearingDeg`.
  /// This is what puts the road ahead in view instead of centering the
  /// driver dead in the middle of the screen.
  LatLng _lookAheadTarget(LatLng position, double bearing) {
    if (lookAheadMeters <= 0) return position;
    return _projectPoint(position, bearing, lookAheadMeters);
  }

  LatLng _projectPoint(LatLng origin, double bearingDeg, double distanceMeters) {
    const earthRadius = 6378137.0;
    final bearingRad = bearingDeg * math.pi / 180;
    final lat1 = origin.latitude * math.pi / 180;
    final lng1 = origin.longitude * math.pi / 180;
    final angularDistance = distanceMeters / earthRadius;

    final lat2 = math.asin(
      math.sin(lat1) * math.cos(angularDistance) +
          math.cos(lat1) * math.sin(angularDistance) * math.cos(bearingRad),
    );
    final lng2 = lng1 +
        math.atan2(
          math.sin(bearingRad) * math.sin(angularDistance) * math.cos(lat1),
          math.cos(angularDistance) - math.sin(lat1) * math.sin(lat2),
        );

    return LatLng(lat2 * 180 / math.pi, lng2 * 180 / math.pi);
  }

  double _lerpBearing(double from, double to, double t) {
    // Shortest-path interpolation so e.g. 350° -> 10° goes forward through
    // 360°/0° instead of spinning the marker the long way around.
    double delta = (to - from) % 360;
    if (delta > 180) delta -= 360;
    if (delta < -180) delta += 360;
    return (from + delta * t) % 360;
  }

  double _zoomForSpeed(double speedMetersPerSecond) {
    if (speedMetersPerSecond < 2) return 18.5; // stopped / crawling
    if (speedMetersPerSecond < 6) return 17.5; // city driving
    if (speedMetersPerSecond < 12) return 16.5; // arterial roads
    return 15.5; // highway
  }

  // ---------------------------
  // OFF-ROUTE DETECTION
  // ---------------------------
  bool isOffRoute(LatLng user, List<LatLng> routePoints) {
    double minDistance = double.infinity;
    for (final p in routePoints) {
      final d = Geolocator.distanceBetween(
        user.latitude, user.longitude, p.latitude, p.longitude,
      );
      if (d < minDistance) minDistance = d;
    }
    return minDistance > 40; // meters
  }

  Map<String, dynamic> serializeGeometry(List<LatLng> points) {
    return {
      'vertices': points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
    };
  }

  // ---------------------------
  // NAVIGATION + AUTO POST
  // ---------------------------
  /// Tracks position and drives the follow-cam: glides marker + camera
  /// between fixes, derives bearing from movement, adapts zoom to speed,
  /// and posts route updates over the websocket. Does NOT recalculate the
  /// route itself — that's billed API usage, so the calling screen decides
  /// when it's worth it (see NavigationScreen's cooldown-gated recalc).
  void startNavigationTracking({
    required AppRoute route,
    required void Function(LatLng geo, double bearing, AppRoute route) onUpdate,
  }) {
    _positionSubscription?.cancel();
    _hasFixedFirstPosition = false;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 3,
      ),
    ).listen((pos) async {
      final newGeo = LatLng(pos.latitude, pos.longitude);
      final targetZoom = _zoomForSpeed(pos.speed);

      // Prefer bearing derived from the actual movement vector over the
      // device's compass heading — heading sensors are noisy/unreliable at
      // low speed and often just report 0 when a phone is flat on a mount.
      double targetBearing = _lastBearing;
      if (userCoordinates != null) {
        final movedMeters = Geolocator.distanceBetween(
          userCoordinates!.latitude,
          userCoordinates!.longitude,
          newGeo.latitude,
          newGeo.longitude,
        );
        if (movedMeters > 2) {
          targetBearing = Geolocator.bearingBetween(
            userCoordinates!.latitude,
            userCoordinates!.longitude,
            newGeo.latitude,
            newGeo.longitude,
          );
          if (targetBearing < 0) targetBearing += 360;
        }
      } else if (pos.heading >= 0) {
        targetBearing = pos.heading;
      }

      if (!_hasFixedFirstPosition) {
        // First fix: snap the marker straight there, then fly the camera
        // in — no glide, since there's nothing to glide from yet.
        _hasFixedFirstPosition = true;
        _lastBearing = targetBearing;
        _currentZoom = targetZoom;
        _setUserMarkerRaw(newGeo, targetBearing);
        if (_following) {
          await _moveCameraTo(
            _lookAheadTarget(newGeo, targetBearing),
            targetBearing,
            animated: true,
            zoomOverride: targetZoom,
          );
        }
      } else {
        _glideTo(newGeo, targetBearing, targetZoom);
      }

      onUpdate(newGeo, targetBearing, route);
      await _postRouteUpdateIfNeeded(newGeo, route);
    });
  }

  /// Glides the marker + camera from wherever they currently are to
  /// `target` over `followDuration`, instead of snapping on every GPS fix.
  /// Runs at ~30fps — smooth to the eye without spamming the platform
  /// channel the way a 60fps loop would.
  void _glideTo(LatLng target, double targetBearing, double targetZoom) {
    _followTicker?.cancel();

    final startPos = userCoordinates ?? target;
    final startBearing = _lastBearing;
    final startZoom = _currentZoom;
    final startTime = DateTime.now();

    _followTicker = Timer.periodic(const Duration(milliseconds: 33), (timer) async {
      final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;
      final rawT = (elapsedMs / followDuration.inMilliseconds).clamp(0.0, 1.0);
      final t = Curves.easeOut.transform(rawT);

      final lat = startPos.latitude + (target.latitude - startPos.latitude) * t;
      final lng = startPos.longitude + (target.longitude - startPos.longitude) * t;
      final bearing = _lerpBearing(startBearing, targetBearing, t);
      final zoom = startZoom + (targetZoom - startZoom) * t;

      final interpolated = LatLng(lat, lng);
      _setUserMarkerRaw(interpolated, bearing);
      _lastBearing = bearing;
      _currentZoom = zoom;

      if (_following) {
        await _moveCameraTo(
          _lookAheadTarget(interpolated, bearing),
          bearing,
          animated: false,
          zoomOverride: zoom,
        );
      }

      if (rawT >= 1.0) {
        timer.cancel();
      }
    });
  }

  Future<void> _postRouteUpdateIfNeeded(LatLng geo, AppRoute route) async {
    if (_lastPostedCoordinates == null ||
        Geolocator.distanceBetween(
              _lastPostedCoordinates!.latitude,
              _lastPostedCoordinates!.longitude,
              geo.latitude,
              geo.longitude,
            ) >=
            _minPostDistanceMeters) {
      final routeModel = ShipmentRoute(
        routeId: 0,
        shipmentId: shipmentId,
        originLat: geo.latitude,
        originLng: geo.longitude,
        destinationLat: route.destination.latitude,
        destinationLng: route.destination.longitude,
        distanceMeters: route.distanceMeters.round(),
        durationSeconds: route.durationSeconds,
        geometry: serializeGeometry(route.polylinePoints),
        recalculated: false,
      );

      try {
        await sessionSocket.sendRouteUpdate(routeModel);
        if (kDebugMode) print("📡 Route sent via websocket");
        _lastPostedCoordinates = geo;
      } catch (e) {
        if (kDebugMode) print("❌ Failed sending websocket route: $e");
      }
    }
  }

  void stopNavigationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _followTicker?.cancel();
    _followTicker = null;
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _followTicker?.cancel();
    super.dispose();
  }
}