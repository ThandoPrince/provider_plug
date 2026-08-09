import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/directions_service.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_map_controller.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_route_conversion.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/services/session_socket_service.dart';

import 'package:flutter_application_2/common/services/shipment_stauts_api.dart';

import 'package:flutter_application_2/screens/schedule_directions/widgets/marker_loader.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/navigate_screen.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/travel_mode_buttons.dart'
    as travelBtn;
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_flushbar_widget.dart';

/// Replaces `HereDestinationScreen`.
class GoogleDestinationScreen extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;
  final int shipmentId;
  final SessionSocketService sessionSocket;

  const GoogleDestinationScreen({
    required this.sessionSocket,
    super.key,
    required this.destinationLat,
    required this.shipmentId,
    required this.destinationLng,
  });

  @override
  State<GoogleDestinationScreen> createState() => _GoogleDestinationScreenState();
}

class _GoogleDestinationScreenState extends State<GoogleDestinationScreen> {
  late final GoogleMapControllerHelper _helper = GoogleMapControllerHelper(
    sessionSocket: widget.sessionSocket,
    shipmentId: widget.shipmentId,
  );
  final DirectionsService _directionsService = DirectionsService();

  TravelMode _selectedMode = TravelMode.car;
  BitmapDescriptor? _originIcon;
  BitmapDescriptor? _destinationIcon;

  double? _distanceKm;
  int? _durationMin;
  bool _isLoading = true;

  AppRoute? _currentRoute;

  @override
  void initState() {
    super.initState();
    _loadIconsAndRoute();
  }

  @override
  void dispose() {
    _helper.dispose();
    super.dispose();
  }

  Future<void> _loadIconsAndRoute() async {
    _originIcon = await MarkerLoader.loadMarker(
      "assets/icons/map_icons/sp_marker.png",
      48,
    );
    _destinationIcon = await MarkerLoader.loadMarker(
      "assets/icons/map_icons/client_marker.png",
      48,
    );
    await _calculateRoute();
  }

  void _onMapCreated(GoogleMapController controller) {
    _helper.attachController(controller);
    if (_currentRoute != null) {
      _helper.zoomToBounds(_currentRoute!.bounds);
    }
  }

  Future<void> _calculateRoute() async {
    setState(() => _isLoading = true);

    final pos = await _helper.getCurrentPosition();
    final start = LatLng(pos.latitude, pos.longitude);
    final dest = LatLng(widget.destinationLat, widget.destinationLng);

    _helper.setOriginMarker(start, _originIcon!);
    _helper.setDestinationMarker(dest, _destinationIcon!);

    final route = await _directionsService.getRoute(
      origin: start,
      destination: dest,
      mode: _selectedMode,
    );

    if (route == null) {
      setState(() => _isLoading = false);
      return;
    }

    _currentRoute = route;
    _helper.drawRoute(route);
    await _helper.zoomToBounds(route.bounds);

    setState(() {
      _distanceKm = route.distanceMeters / 1000;
      _durationMin = route.durationSeconds ~/ 60;
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
      ScheduleFlushbar.error(
        context,
        "Failed to start navigation. Please try again later.",
      );
      return;
    }

    final shipmentCtrl = context.read<ShipmentController>();
    await shipmentCtrl.fetchShipments();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => NavigationScreen(
          sessionSocket: widget.sessionSocket,
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
              child: ListenableBuilder(
                listenable: _helper,
                builder: (context, _) => GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.destinationLat, widget.destinationLng),
                    zoom: 14,
                  ),
                  onMapCreated: _onMapCreated,
                  markers: _helper.markers,
                  polylines: _helper.polylines,
                  myLocationButtonEnabled: false,
                ),
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
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
                      final pos = await _helper.getCurrentPosition();
                      final geo = LatLng(pos.latitude, pos.longitude);
                      await _helper.focusOnLocation(geo);
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