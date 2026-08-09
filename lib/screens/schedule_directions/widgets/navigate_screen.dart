import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/common/widgets/network_sensitivy_container.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/directions_service.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_map_controller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/services/session_socket_service.dart';

import 'package:flutter_application_2/common/services/shipment_stauts_api.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/views/session_initiation_qr_screen.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_flushbar_widget.dart';

import 'here_route_conversion.dart';
import 'marker_loader.dart';

class NavigationScreen extends StatefulWidget {
  final AppRoute route;
  final TravelMode travelMode;
  final int shipmentId;
  final double? destinationLat;
  final double? destinationLng;
  final SessionSocketService sessionSocket;

  const NavigationScreen({
    super.key,
    required this.route,
    required this.travelMode,
    required this.shipmentId,
    required this.sessionSocket,
    this.destinationLat,
    this.destinationLng,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  DateTime? _lastRouteRecalc;
  static const int _recalcCooldownSeconds = 10;
  // "Arrived" enter/exit radii, not a single cutoff. GPS accuracy is
  // typically 5-15m in open areas but degrades to 20-50m near tall
  // buildings/apartment complexes (multipath reflection) — a flat 10m
  // threshold would leave the button stuck hidden in exactly the places
  // deliveries most often go. 40m entry / 80m exit is the same ballpark
  // most delivery-nav apps use. The gap between the two (hysteresis) stops
  // the button flickering on/off as GPS jitters right at the boundary.
  static const double _arrivalEnterRadiusMeters = 40;
  static const double _arrivalExitRadiusMeters = 80;

  late final GoogleMapControllerHelper _helper = GoogleMapControllerHelper(
    sessionSocket: widget.sessionSocket,
    shipmentId: widget.shipmentId,
  );
  final DirectionsService _directionsService = DirectionsService();

  late AppRoute _currentRoute;
  int _currentStep = 0;
  bool _hasArrived = false;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.route;
  }

  @override
  void dispose() {
    _helper.stopNavigationTracking();
    _helper.dispose();
    super.dispose();
  }

  // -------------------- MAP SETUP --------------------
  void _onMapCreated(GoogleMapController controller) async {
    _helper.attachController(controller);
    await _initializeMap();
  }

  Future<void> _initializeMap() async {
    final destinationIcon = await MarkerLoader.loadMarker(
      "assets/icons/map_icons/client_marker.png",
      48,
    );

    final providerIcon = await MarkerLoader.loadMarker(
      "assets/icons/map_icons/sp_marker.png",
      48,
    );

    _helper
      ..setUserMarkerIcon(providerIcon)
      ..drawRoute(_currentRoute)
      ..setDestinationMarker(
        _currentRoute.destination,
        destinationIcon,
      );

    // One-time overview before the chase-cam takes over — gives a brief
    // "here's your route" beat before diving into turn-by-turn, same as
    // most delivery-nav apps do when a trip starts.
    await _helper.zoomToBounds(_currentRoute.bounds);

    _helper.startNavigationTracking(
      route: _currentRoute,
      onUpdate: _handleNavigationUpdate,
    );
  }

  // -------------------- NAVIGATION UPDATE --------------------
  Future<void> _handleNavigationUpdate(
    LatLng userGeo,
    double bearing,
    AppRoute route,
  ) async {
    if (_hasArrived) return;

    // Off-route recalculation, cooldown-gated. The Directions API is billed
    // per call, so we don't fire it on every single GPS update the way an
    // on-device engine could afford to.
    final now = DateTime.now();
    final offRoute = _helper.isOffRoute(userGeo, _currentRoute.polylinePoints);
    final cooldownElapsed = _lastRouteRecalc == null ||
        now.difference(_lastRouteRecalc!).inSeconds > _recalcCooldownSeconds;

    if (offRoute && cooldownElapsed) {
      _lastRouteRecalc = now;

      final newRoute = await _directionsService.getRoute(
        origin: userGeo,
        destination: _currentRoute.destination,
        mode: widget.travelMode,
      );

      if (newRoute != null) {
        _currentRoute = newRoute;
        // Just redraw the line under the driver — do NOT zoomToBounds here.
        // The follow-cam is already tracking the driver continuously; a
        // bounds-fit on every reroute would yank the camera out to an
        // overview shot mid-navigation, which is disorienting rather than
        // reassuring. The new line simply appears under the existing view.
        _helper.drawRoute(_currentRoute);
      }
    }

    setState(() {
      _updateCurrentStep(userGeo);
    });
    _checkArrival(userGeo, _currentRoute);
  }

  void _updateCurrentStep(LatLng userGeo) {
    for (int i = 0; i < _currentRoute.steps.length; i++) {
      final d = Geolocator.distanceBetween(
        userGeo.latitude,
        userGeo.longitude,
        _currentRoute.steps[i].location.latitude,
        _currentRoute.steps[i].location.longitude,
      );
      if (d < 20) {
        _currentStep = i;
        break;
      }
    }
  }

  void _checkArrival(LatLng userGeo, AppRoute route) {
    final distanceRemaining = Geolocator.distanceBetween(
      userGeo.latitude,
      userGeo.longitude,
      route.destination.latitude,
      route.destination.longitude,
    );

    if (!_hasArrived && distanceRemaining <= _arrivalEnterRadiusMeters) {
      setState(() => _hasArrived = true);
      HapticFeedback.mediumImpact();
      ScheduleFlushbar.success(context, "You have arrived at the destination!");
    } else if (_hasArrived && distanceRemaining > _arrivalExitRadiusMeters) {
      // Driver moved back away from the destination (missed it, got
      // rerouted around the block, etc.) — pull the button back until
      // they're genuinely close again, rather than leaving it stuck on.
      setState(() => _hasArrived = false);
    }
  }

  Future<void> _markArrived() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await ShipmentStatusApi.updateStatus(
      widget.shipmentId,
      "arrived",
    );

    _helper.stopNavigationTracking();

    Navigator.pop(context);

    if (!success) {
      FlushbarService.error(context, "Failed to mark as arrived. Please try again.");
      return;
    }

    final shipmentCtrl = context.read<ShipmentController>();
    await shipmentCtrl.fetchShipments();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SessionInitiationQrScreen(
          shipmentId: widget.shipmentId,
          sessionSocket: widget.sessionSocket,
        ),
      ),
    );
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        ScheduleFlushbar.warning(
          context,
          "Navigation is active. Complete the trip first.",
        );
      },
      child: SensitiveContainer(
        child: Scaffold(
          body: ListenableBuilder(
            listenable: _helper,
            builder: (context, _) => Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.route.origin,
                    zoom: 16,
                    tilt: 55,
                  ),
                  onMapCreated: _onMapCreated,
                  markers: _helper.markers,
                  polylines: _helper.polylines,
                  // Off — we have our own recenter button tied to the
                  // follow-cam, so the stock locate button would be a
                  // confusing second "recenter" affordance.
                  myLocationButtonEnabled: false,
                  onCameraMoveStarted: () {
                    // Every camera move we trigger ourselves sets a flag right
                    // before it happens. If this move wasn't flagged, the
                    // driver dragged the map — drop out of follow mode so we
                    // don't fight their gesture.
                    if (!_helper.consumeProgrammaticMoveFlag()) {
                      _helper.stopFollowing();
                    }
                  },
                ),
                _buildManeuverCard(),
                _buildBottomStatusCard(),
                if (!_helper.isFollowing) _buildRecenterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManeuverCard() {
    final maneuverText = _currentRoute.steps.isNotEmpty
        ? _currentRoute.steps[_currentStep].instruction
        : "Continue";

    return Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            maneuverText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _currentStep == _currentRoute.steps.length - 1
                  ? Colors.red
                  : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecenterButton() {
    return Positioned(
      bottom: 100,
      right: 16,
      child: FloatingActionButton(
        heroTag: "recenter",
        backgroundColor: Colors.white,
        onPressed: () => _helper.resumeFollowing(),
        child: const Icon(Icons.navigation, color: Colors.blue),
      ),
    );
  }

  Widget _buildBottomStatusCard() {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDistanceText(),
              _buildTimeText(),
              _hasArrived
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: _markArrived,
                      child: const Text("Arrived"),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceText() {
    final userPos = _helper.userCoordinates;
    final distanceMeters = userPos != null
        ? Geolocator.distanceBetween(
            userPos.latitude,
            userPos.longitude,
            _currentRoute.destination.latitude,
            _currentRoute.destination.longitude,
          )
        : _currentRoute.distanceMeters;

    if (distanceMeters < 950) return Text("${distanceMeters.round()} m");
    return Text("${(distanceMeters / 1000).toStringAsFixed(1)} km");
  }

  Widget _buildTimeText() {
    final remainingSeconds = _currentRoute.durationSeconds;
    if (remainingSeconds < 50) return Text("$remainingSeconds sec");

    final minutes = (remainingSeconds / 60).round();
    return Text("$minutes min");
  }
}