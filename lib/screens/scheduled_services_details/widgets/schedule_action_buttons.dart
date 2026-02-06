import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/session_by_shipment_ctrl.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/views/session_initiation_qr_screen.dart';
import 'package:flutter_application_2/screens/schedule_directions/views/here_directions_schedule.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_map_controller.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_route_conversion.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/navigate_screen.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/shipment_reroute_helper.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/client_info_tile.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/shipment_stauts_helper.dart';
import 'package:flutter_application_2/screens/session/views/session_screen.dart';
import 'package:provider/provider.dart';

class ScheduleActionButtons extends StatelessWidget {
  final Shipment shipment;

  String get _status => shipment.shipmentStatus?.toLowerCase() ?? "";

  const ScheduleActionButtons({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    if (shipment.serviceOrdered?.order?.client == null) {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) {
                  return DraggableScrollableSheet(
                    initialChildSize: 0.262,
                    minChildSize: 0.2,
                    maxChildSize: 0.27,
                    builder: (_, controller) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Kolors.kPrimary, Kolors.kSecondaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: SingleChildScrollView(
                          controller: controller,
                          child: ClientInfoTile(
                            client: shipment.serviceOrdered?.order?.client,
                          ),
                        ),
                      );
                    },
                  );
                },
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
    onPressed: () async {
      final lat =
          shipment.serviceOrdered?.order?.deliveryAddress?.latitude ?? 0.0;
      final lng =
          shipment.serviceOrdered?.order?.deliveryAddress?.longitude ?? 0.0;

      if (lat == 0.0 || lng == 0.0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location not available for this job")),
        );
        return;
      }

      final shipmentId = shipment.shipmentId ?? 0;
      final status = shipment.shipmentStatus?.toLowerCase() ?? "";

      // ----------------- CASES -----------------
      if (status == "pending") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HereDestinationScreen(
              destinationLat: lat,
              destinationLng: lng,
              shipmentId: shipmentId,
            ),
          ),
        );
        return;
      }

      if (status == "in_transit") {
        final routeHelper = ShipmentRouteHelper();
        final latestRoute = await routeHelper.getLatestRoute(shipmentId);

        if (latestRoute == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No active route available")),
          );
          return;
        }

        try {
          final hereRoute =
              await convertShipmentRouteToHereRoute(latestRoute);
          final travelMode = mapTravelMode(latestRoute.travelMode ?? "car");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NavigationScreen(
                route: hereRoute,
                travelMode: travelMode,
                shipmentId: shipmentId,
                destinationLat: latestRoute.destinationLat,
                destinationLng: latestRoute.destinationLng,
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to start navigation: $e")),
          );
        }
        return;
      }

      if (status == "arrived") {
        // Arrived → check if session exists
        final sessionController = SessionByShipmentController();
        await sessionController.fetchSession(shipmentId.toString());
        final session = sessionController.session;

        if (session == null) {
          // Session doesn't exist → go to QR check-in
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  SessionInitiationQrScreen(shipmentId: shipmentId),
            ),
          );
        }
        return;
      }

      if (status == "delivered") {
        // Delivered → session must exist
        final sessionController = SessionByShipmentController();
        await sessionController.fetchSession(shipmentId.toString());
        final session = sessionController.session;

        if (session != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: sessionController,
                child: SessionScreen(session: session),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No session found for this delivery")),
          );
        }
        return;
      }

      // Everything else
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Cannot start navigation (status: $status)")),
      );
    },

    icon: const Icon(Icons.navigation),
    label: const Text(
      "Start",
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
),


      ],
    );
  }
}
