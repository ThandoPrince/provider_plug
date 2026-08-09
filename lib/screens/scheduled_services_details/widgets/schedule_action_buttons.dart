import 'package:flutter/material.dart';

import 'package:flutter_application_2/screens/schedule_directions/views/here_directions_schedule.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/directions_service.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_route_conversion.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_2/common/controller/bookings/session_by_shipment_ctrl.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/services/session_socket_service.dart';

import 'package:flutter_application_2/common/services/shipment_route_api.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/client_details_screen.dart/views/shipment_client_details_screen.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/views/session_initiation_qr_screen.dart';

import 'package:flutter_application_2/screens/schedule_directions/widgets/navigate_screen.dart';

import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_flushbar_widget.dart';
import 'package:flutter_application_2/screens/session/views/session_screen.dart';

class ScheduleActionButtons extends StatefulWidget {
  final Shipment shipment;
  final SessionSocketService sessionSocket;

  const ScheduleActionButtons({
    super.key,
    required this.shipment,
    required this.sessionSocket,
  });

  @override
  State<ScheduleActionButtons> createState() => _ScheduleActionButtonsState();
}

class _ScheduleActionButtonsState extends State<ScheduleActionButtons> {
  String get _status => widget.shipment.shipmentStatus?.toLowerCase() ?? "";
  bool _isStarting = false;

  @override
  Widget build(BuildContext context) {
    if (widget.shipment.serviceOrdered?.order?.client == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        /// ✅ Customer Info Button
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Kolors.kDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onPressed: () {
              final booking = widget.shipment.serviceOrdered?.order;

              if (booking == null) {
                ScheduleFlushbar.error(context, "Booking details not available.");
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientSessionDetailsScreen(booking: booking),
                ),
              );
            },
            icon: const Icon(Icons.person),
            label: const Text(
              "Customer Info",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onPressed: _isStarting ? null : _handlePress,
            icon: _isStarting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.navigation),
            label: Text(
              _isStarting ? "Loading..." : (_status == "pending" ? "Start" : "Resume"),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handlePress() async {
    setState(() => _isStarting = true);

    try {
      final lat = widget.shipment.serviceOrdered?.order?.deliveryAddress?.latitude ?? 0.0;
      final lng = widget.shipment.serviceOrdered?.order?.deliveryAddress?.longitude ?? 0.0;

      if (lat == 0.0 || lng == 0.0) {
        ScheduleFlushbar.error(context, "Invalid destination coordinates");
        return;
      }

      final shipmentId = widget.shipment.shipmentId ?? 0;
      final status = _status;

      if (status == "pending") {
        setState(() => _isStarting = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GoogleDestinationScreen(
              sessionSocket: widget.sessionSocket,
              destinationLat: lat,
              destinationLng: lng,
              shipmentId: shipmentId,
            ),
          ),
        );
        return;
      }

      if (status == "in_transit") {
        await _resumeInTransitNavigation(shipmentId);
        return;
      }

      // Arrived / Delivered → Start QR flow
      if (status == "arrived" || status == "delivered") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SessionInitiationQrScreen(
              shipmentId: shipmentId,
              sessionSocket: widget.sessionSocket,
            ),
          ),
        );
        return;
      }

      if (status == "in_session") {
        final sessionController = SessionByShipmentController();
        await sessionController.fetchSession(shipmentId.toString());
        final session = sessionController.session;

        if (session != null) {
          setState(() => _isStarting = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: sessionController,
                child: SessionScreen(
                  session: session,
                  sessionSocket: widget.sessionSocket,
                ),
              ),
            ),
          );
          return;
        }

        ScheduleFlushbar.error(context, "Session not found for shipment");
        return;
      }

      ScheduleFlushbar.error(context, "Cannot start navigation for status: $status");
    } finally {
      if (mounted) {
        setState(() => _isStarting = false);
      }
    }
  }

  /// Resuming navigation on an in-transit shipment. Replaces the old
  /// per-travel-mode here.RoutingEngine switch statement — the Directions
  /// API takes the mode as a single query param, so one call covers every
  /// TravelMode value.
  Future<void> _resumeInTransitNavigation(int shipmentId) async {
    try {
      final routes = await ShipmentRouteApi.getShipmentRoutes(shipmentId);

      if (routes.isEmpty) {
        ScheduleFlushbar.error(context, "No navigation route found.");
        return;
      }

      final latestRoute = routes.last;
      final travelMode = travelModeFromString(latestRoute.travelMode);

      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      final route = await DirectionsService().getRoute(
        origin: LatLng(currentPosition.latitude, currentPosition.longitude),
        destination: LatLng(latestRoute.destinationLat, latestRoute.destinationLng),
        mode: travelMode,
      );

      if (route == null) {
        ScheduleFlushbar.error(context, "Failed to resume navigation.");
        return;
      }

      setState(() => _isStarting = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NavigationScreen(
            shipmentId: shipmentId,
            route: route,
            travelMode: travelMode,
            destinationLat: latestRoute.destinationLat,
            destinationLng: latestRoute.destinationLng,
            sessionSocket: widget.sessionSocket,
          ),
        ),
      );
    } catch (e) {
      ScheduleFlushbar.error(context, "Failed to load navigation route.");
    }
  }
}