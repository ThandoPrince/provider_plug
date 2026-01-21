import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/views/session_initiation_qr_screen.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/shipment_stauts_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as here;

import 'here_map_controller.dart';

class NavigationScreen extends StatefulWidget {
  final here.Route route;
  final TravelMode travelMode;
  final int shipmentId;

  const NavigationScreen({
    super.key,
    required this.route,
    required this.travelMode,
    required this.shipmentId,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  static const double _arrivalDistanceMeters = 30; // base
  static const double _arrivalBufferMeters = 50;   // flexible, user-friendly
  static const int _arrivalTimeBufferSeconds = 60; // 1 min threshold

  HereMapControllerHelper? _helper;
  late here.Route _currentRoute;
  late List<here.Maneuver> _maneuvers;

  int _currentStep = 0;
  bool _hasArrived = false;

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.route;
    _maneuvers = _currentRoute.sections.expand((s) => s.maneuvers).toList();
  }

  void _onMapCreated(HereMapController controller) async {
    _helper = HereMapControllerHelper(
  controller,
  shipmentId: widget.shipmentId,
);

    controller.mapScene.loadSceneForMapScheme(
      MapScheme.normalDay,
      (error) async {
        if (error != null) return;

        _helper!
          ..drawRoute(_currentRoute)
          ..zoomToRoute(_currentRoute);

        final destination =
            _currentRoute.sections.last.arrivalPlace.mapMatchedCoordinates;

        await _helper!.addDestinationMarker(
          destination,
          await MapImage.withFilePathAndWidthAndHeight(
            "assets/icons/map_icons/client_marker.png",
            96,
            96,
          ),
        );

        _helper!.startNavigationTracking(
          route: _currentRoute,
          mode: widget.travelMode,
          onUpdate: _onNavigationUpdate,
        );
      },
    );
  }

  void _onNavigationUpdate(GeoCoordinates userGeo, double bearing, here.Route updatedRoute) {
    if (_hasArrived) return;

    setState(() {
      _currentRoute = updatedRoute;
      _maneuvers = updatedRoute.sections.expand((s) => s.maneuvers).toList();
    });

    // Update next maneuver
    for (int i = 0; i < _maneuvers.length; i++) {
      if (userGeo.distanceTo(_maneuvers[i].coordinates) < 20) {
        _currentStep = i;
        break;
      }
    }

    final destination = updatedRoute.sections.last.arrivalPlace.mapMatchedCoordinates;
    final distanceRemaining = userGeo.distanceTo(destination);
    final timeRemaining = updatedRoute.duration.inSeconds;

    // ✅ Arrival detection with buffer
    if (distanceRemaining <= (_arrivalDistanceMeters + _arrivalBufferMeters) ||
        timeRemaining <= _arrivalTimeBufferSeconds) {
      if (!_hasArrived) {
        setState(() => _hasArrived = true);
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You have arrived")),
        );
      }
      return;
    }

    _helper!
      ..drawRoute(updatedRoute)
      ..zoomToRoute(updatedRoute);
  }

  Future<void> _markArrived() async {
  // 1️⃣ Show loader
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  // 2️⃣ Call API
  final success = await ShipmentStatusApi.updateStatus(
    widget.shipmentId,
    "arrived",
  );

  // 3️⃣ Close loader FIRST
  Navigator.pop(context);

  // 4️⃣ Handle failure
  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to update shipment status")),
    );
    return;
  }

  // 5️⃣ Navigate to QR scanner
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => SessionInitiationQrScreen(
        shipmentId: widget.shipmentId,
      ),
    ),
  );
}




  @override
  void dispose() {
    _helper?.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          HereMap(onMapCreated: _onMapCreated),

          /// TOP MANEUVER
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _maneuvers.isNotEmpty ? _maneuvers[_currentStep].text : "Continue",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _currentStep == _maneuvers.length - 1 ? Colors.red : Colors.black,
                  ),
                ),
              ),
            ),
          ),

          /// BOTTOM STATUS
          Positioned(
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
          ),
        ],
      ),
    );
  }



  Widget _buildDistanceText() {
    final destination = _currentRoute.sections.last.arrivalPlace.mapMatchedCoordinates;
    final distanceMeters = _helper?.userCoordinates?.distanceTo(destination) ?? _currentRoute.lengthInMeters;
    if (distanceMeters < 950) return Text("${distanceMeters.round()} m");
    return Text("${(distanceMeters / 1000).toStringAsFixed(1)} km");
  }

  Widget _buildTimeText() {
    final remainingSeconds = _currentRoute.duration.inSeconds;
    if (remainingSeconds < 50) return Text("$remainingSeconds sec");
    final minutes = (remainingSeconds / 60).round();
    return Text("$minutes min");
  }
}
