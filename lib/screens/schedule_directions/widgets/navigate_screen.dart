import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/views/session_initiation_qr_screen.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/geo_coordinates_to_position.dart';
import 'package:flutter_application_2/common/services/shipment_stauts_api.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_flushbar_widget.dart';

import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as here;
import 'package:provider/provider.dart';

import 'here_map_controller.dart';

class NavigationScreen extends StatefulWidget {
  final here.Route route;
  final TravelMode travelMode;
  final int shipmentId;
  final double? destinationLat;
  final double? destinationLng;
  final String? providerEmail;

  const NavigationScreen({
    super.key,
    required this.route,
    required this.travelMode,
    required this.shipmentId,
    required this.providerEmail,
    this.destinationLat,
    this.destinationLng,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  DateTime? _lastRouteRecalc;
  static const int _recalcCooldownSeconds = 10;
  static const double _arrivalDistanceMeters = 30;
  static const double _arrivalBufferMeters = 50;
  static const int _arrivalTimeBufferSeconds = 60;

  HereMapControllerHelper? _helper;
  late here.Route _currentRoute;
  late List<here.Maneuver> _maneuvers;

  int _currentStep = 0;
  bool _hasArrived = false;

  here.Route _getRemainingRoute(GeoCoordinates userGeo, here.Route fullRoute) {
    final remainingSections = <here.Section>[];
    bool passedUser = false;

    for (var section in fullRoute.sections) {
      final newManeuvers = <here.Maneuver>[];

      for (var m in section.maneuvers) {
        final distanceToUser = userGeo.distanceTo(m.coordinates);
        if (!passedUser && distanceToUser < 20) {
          passedUser = true; // start collecting maneuvers after user
          continue;
        }
        if (passedUser) newManeuvers.add(m);
      }

      if (newManeuvers.isNotEmpty) {
        // we cannot instantiate here.Section or here.Route directly (abstract),
        // so reuse the original section instances that remain after the user.
        remainingSections.add(section);
      }
    }

    // Return the original fullRoute if we cannot construct a new concrete Route.
    // Keep using fullRoute so we avoid instantiating abstract here.Route.
    return fullRoute;
  }

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.route;
    _maneuvers = _currentRoute.sections.expand((s) => s.maneuvers).toList();
  }

  // -------------------- MAP SETUP --------------------
  void _onMapCreated(HereMapController controller) async {
    _helper = HereMapControllerHelper(
      controller,
      shipmentId: widget.shipmentId,
    );

    controller.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (
      error,
    ) async {
      if (error != null) return;

      await _initializeMap();
    });
  }

  Future<void> _initializeMap() async {
    if (_helper == null) return;

    final destination =
        _currentRoute.sections.last.arrivalPlace.mapMatchedCoordinates;

    await _helper!
      ..drawRoute(_currentRoute)
      ..zoomToRoute(_currentRoute)
      ..addDestinationMarker(
        destination,
        await MapImage.withFilePathAndWidthAndHeight(
          "assets/icons/map_icons/client_marker.png",
          96,
          96,
        ),
      )
      ..startNavigationTracking(
        route: _currentRoute,
        mode: widget.travelMode,
        onUpdate: _handleNavigationUpdate,
      );
  }

  Future<void> _handleNavigationUpdate(
    GeoCoordinates userGeo,
    double bearing,
    here.Route currentRoute,
  ) async {
    if (_hasArrived) return;

    // Check off-route with cooldown
    final now = DateTime.now();
    if (_helper!.isOffRoute(userGeo, _currentRoute) &&
        (_lastRouteRecalc == null ||
            now.difference(_lastRouteRecalc!).inSeconds >
                _recalcCooldownSeconds)) {
      _lastRouteRecalc = now;

      final destination =
          _currentRoute.sections.last.arrivalPlace.mapMatchedCoordinates;

      final newRoutes = await _helper!.calculateRouteAsync([
        here.Waypoint(userGeo),
        here.Waypoint(destination),
      ], widget.travelMode);

      if (newRoutes.isNotEmpty) {
        _currentRoute = newRoutes.first;

        // Center and zoom to the new route using helper
        _helper!.zoomToRoute(_currentRoute);
      }
    }

    // Continue normal update
    _onNavigationUpdate(userGeo, bearing, _currentRoute);
  }

  // -------------------- NAVIGATION UPDATE --------------------
void _onNavigationUpdate(
  GeoCoordinates userGeo,
  double bearing,
  here.Route updatedRoute,
) async {
  if (_hasArrived) return;

  setState(() {
    _currentRoute = updatedRoute;
    _maneuvers = updatedRoute.sections.expand((s) => s.maneuvers).toList();
  });

  _updateCurrentStep(userGeo);
  _checkArrival(userGeo, updatedRoute);

  final destination =
      updatedRoute.sections.last.arrivalPlace.mapMatchedCoordinates;

  final routes = await _helper!.calculateRouteAsync(
    [here.Waypoint(userGeo), here.Waypoint(destination)],
    widget.travelMode,
  );

  if (routes.isNotEmpty) {
    _currentRoute = routes.first;
    _helper!
      ..drawRoute(_currentRoute!)
      ..focusOnLocation(positionFromGeo(userGeo));
  }
}


  void _updateCurrentStep(GeoCoordinates userGeo) {
    for (int i = 0; i < _maneuvers.length; i++) {
      if (userGeo.distanceTo(_maneuvers[i].coordinates) < 20) {
        _currentStep = i;
        break;
      }
    }
  }

  void _checkArrival(GeoCoordinates userGeo, here.Route route) {
    final destination = route.sections.last.arrivalPlace.mapMatchedCoordinates;
    final distanceRemaining = userGeo.distanceTo(destination);
    final timeRemaining = route.duration.inSeconds;

    if (distanceRemaining <= (_arrivalDistanceMeters + _arrivalBufferMeters) ||
        timeRemaining <= _arrivalTimeBufferSeconds) {
      if (!_hasArrived) {
        setState(() => _hasArrived = true);
        HapticFeedback.mediumImpact();
        ScheduleFlushbar.success(context, "You have arrived at the destination!");
      }
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

  Navigator.pop(context); // close loader

  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to update shipment status")),
    );
    return;
  }

  /// ✅ REFRESH ShipmentController BEFORE NAVIGATION
 

  /// ✅ THEN NAVIGATE
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) =>
          SessionInitiationQrScreen(shipmentId: widget.shipmentId, providerEmail: widget.providerEmail ?? ''),
    ),
  );
}


  // -------------------- UI --------------------
  @override
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
    child: Scaffold(
      body: Stack(
        children: [
          HereMap(onMapCreated: _onMapCreated),
          _buildManeuverCard(),
          _buildBottomStatusCard(),
        ],
      ),
    ),
  );
}


  Widget _buildManeuverCard() {
    final maneuverText = _maneuvers.isNotEmpty
        ? _maneuvers[_currentStep].text
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
              color: _currentStep == _maneuvers.length - 1
                  ? Colors.red
                  : Colors.black,
            ),
          ),
        ),
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
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
    final destination =
        _currentRoute.sections.last.arrivalPlace.mapMatchedCoordinates;
    final distanceMeters =
        _helper?.userCoordinates?.distanceTo(destination) ??
        _currentRoute.lengthInMeters;

    if (distanceMeters < 950) return Text("${distanceMeters.round()} m");
    return Text("${(distanceMeters / 1000).toStringAsFixed(1)} km");
  }

  Widget _buildTimeText() {
    final remainingSeconds = _currentRoute.duration.inSeconds;
    if (remainingSeconds < 50) return Text("$remainingSeconds sec");

    final minutes = (remainingSeconds / 60).round();
    return Text("$minutes min");
  }

  @override
  void dispose() {
    _helper?.dispose();
    super.dispose();
  }
}
