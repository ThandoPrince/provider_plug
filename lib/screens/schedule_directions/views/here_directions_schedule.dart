import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_map_controller.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/marker_loader.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/navigate_screen.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/travel_mode_buttons.dart'
    as travelBtn;
import 'package:flutter_application_2/screens/schedule_directions/widgets/shipment_stauts_helper.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_flushbar_widget.dart';

import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';
import 'package:here_sdk/routing.dart' as here;

class HereDestinationScreen extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;
  final int shipmentId;

  const HereDestinationScreen({
    super.key,
    required this.destinationLat,
    required this.shipmentId,
    required this.destinationLng,
  });

  @override
  State<HereDestinationScreen> createState() => _HereDestinationScreenState();
}

class _HereDestinationScreenState extends State<HereDestinationScreen> {
  HereMapController? _mapController;
  HereMapControllerHelper? _helper;

  TravelMode _selectedMode = TravelMode.car;
  MapMarker? _userMarker;

  double? _distanceKm;
  int? _durationMin;
  bool _isLoading = true;

  here.Route? _currentRoute;
  MapImage? _originImage;
  MapImage? _destinationImage;

  @override
  void dispose() {
    _helper?.dispose();
    super.dispose();
  }

  void _onMapCreated(HereMapController controller) async {
    _mapController = controller;
    _helper = HereMapControllerHelper(
      controller,
      shipmentId: widget.shipmentId, // ✅ pass the required argument
    );

    // Load map scene
    controller.mapScene.loadSceneForMapScheme(MapScheme.normalDay, (
      error,
    ) async {
      if (error != null) {
        if (kDebugMode) {
          print("Map scene load error: $error");
        }
        return;
      }
      if (kDebugMode) {
        print("Map scene loaded!");
      }

      // Load marker images
      _originImage ??= await MarkerLoader.loadMarker(
        "assets/icons/map_icons/sp_marker.png",
        96,
      );
      _destinationImage ??= await MarkerLoader.loadMarker(
        "assets/icons/map_icons/client_marker.png",
        96,
      );

      await _calculateRoute();
    });
  }


void _zoomToRouteWithPadding(here.Route route) {
  if (_mapController == null) return;

  final bbox = route.boundingBox;
  if (bbox == null) return;

  // Choose how much padding you want around the route
  const double padPixels = 150.0; // increase for more padding

  final viewportSize = _mapController!.viewportSize;

  // Starting point for padded area
  final origin = Point2D(padPixels, padPixels);

  // Calculate size so that padding applies all around
  final sizeWithPadding = Size2D(
    math.max(1, viewportSize.width - padPixels * 2),
    math.max(1, viewportSize.height - padPixels * 2),
  );

  final viewRect = Rectangle2D(origin, sizeWithPadding);

  // Use map update that accepts orientation + view rectangle for padding
  final update = MapCameraUpdateFactory.lookAtAreaWithGeoOrientationAndViewRectangle(
    bbox,
    GeoOrientationUpdate(0, 0), // keep map upright
    viewRect,
  );

  _mapController!.camera.applyUpdate(update);
}



  Future<void> _calculateRoute() async {
    if (_helper == null) return;
    setState(() => _isLoading = true);

    final pos = await _helper!.getCurrentPosition();
    final start = GeoCoordinates(pos.latitude, pos.longitude);
    final dest = GeoCoordinates(widget.destinationLat, widget.destinationLng);

    // Add or update markers
    await _helper!.addOriginMarker(start, _originImage!);
    await _helper!.addDestinationMarker(dest, _destinationImage!);

    // Route calculation
    final waypoints = [here.Waypoint(start), here.Waypoint(dest)];
    final routes = await _helper!.calculateRouteAsync(waypoints, _selectedMode);

    if (routes.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    _currentRoute = routes.first;
    _helper!.drawRoute(_currentRoute!);
    
    _zoomToRouteWithPadding(_currentRoute!);

    final distance = _currentRoute!.lengthInMeters / 1000;
    final duration = _currentRoute!.duration.inSeconds ~/ 60;

    setState(() {
      _distanceKm = distance;
      _durationMin = duration;
      _isLoading = false;
    });
  }

  

  void _beginNavigation() async {
    if (_currentRoute == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final started = await ShipmentStatusApi.updateStatus(
      widget.shipmentId,
      "in_transit",
    );

    Navigator.pop(context);

    if (!started) {
            ScheduleFlushbar.error(context, "Failed to start navigation. Please try again later.");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigationScreen(
          shipmentId: widget.shipmentId,
          route: _currentRoute!,
          travelMode: _selectedMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth == 0 || constraints.maxHeight == 0) {
                    return const SizedBox.shrink();
                  }

                  return HereMap(
                    onMapCreated: (controller) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _onMapCreated(controller);
                      });
                    },
                  );
                },
              ),
            ),

            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // Top card with distance and travel mode selector
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.blue,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            if (_distanceKm != null && _durationMin != null)
                              Text(
                                "${_distanceKm!.toStringAsFixed(1)} km • $_durationMin min",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            const SizedBox(height: 8),
                            travelBtn.TravelModeSelector(
                              selectedMode: _mapModeToUIToggle(_selectedMode),
                              onModeSelected: (uiMode) {
                                setState(() {
                                  _selectedMode = _uiModeToMapMode(uiMode);
                                });
                                _calculateRoute();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom buttons
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FloatingActionButton.extended(
                    heroTag: "begin_route",
                    onPressed: _beginNavigation,
                    label: const Text("Begin"),
                    icon: const Icon(Icons.navigation),
                    backgroundColor: Colors.blue,
                  ),
                  FloatingActionButton(
                    heroTag: "my_location",
                   onPressed: () async {
  if (_helper == null) return;
  final pos = await _helper!.getCurrentPosition();

  // Only move camera
  final geo = GeoCoordinates(pos.latitude, pos.longitude);

  _helper!.mapController.camera.lookAtPointWithGeoOrientationAndMeasure(
    geo,
    GeoOrientationUpdate(0, 50),
    MapMeasure(MapMeasureKind.distanceInMeters, 700),
  );
},

                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- TravelMode mapping helpers -----
  travelBtn.TravelMode _mapModeToUIToggle(TravelMode mode) {
    switch (mode) {
      case TravelMode.car:
        return travelBtn.TravelMode.car;
      case TravelMode.pedestrian:
        return travelBtn.TravelMode.pedestrian;
      case TravelMode.bicycle:
        return travelBtn.TravelMode.bicycle;
      case TravelMode.scooter:
        return travelBtn.TravelMode.scooter;
    }
  }

  TravelMode _uiModeToMapMode(travelBtn.TravelMode uiMode) {
    switch (uiMode) {
      case travelBtn.TravelMode.car:
        return TravelMode.car;
      case travelBtn.TravelMode.pedestrian:
        return TravelMode.pedestrian;
      case travelBtn.TravelMode.bicycle:
        return TravelMode.bicycle;
      case travelBtn.TravelMode.scooter:
        return TravelMode.scooter;
    }
  }
}
