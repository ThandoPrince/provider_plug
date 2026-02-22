import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/session_by_shipment_ctrl.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/views/session_initiation_qr_screen.dart';
import 'package:flutter_application_2/screens/schedule_directions/views/here_directions_schedule.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_route_conversion.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/navigate_screen.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/shipment_reroute_helper.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/client_info_tile.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_flushbar_widget.dart';
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
                            colors: [  Kolors.kPrimary, Color(0xFF1A1A1A)],
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
      final lat = shipment.serviceOrdered?.order?.deliveryAddress?.latitude ?? 0.0;
      final lng = shipment.serviceOrdered?.order?.deliveryAddress?.longitude ?? 0.0;

      if (lat == 0.0 || lng == 0.0) {
        ScheduleFlushbar.error(context, "Invalid destination coordinates");
        return;
      }

      final shipmentId = shipment.shipmentId ?? 0;
      final status = _status; 

 
      if (status == "pending") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HereDestinationScreen(
              destinationLat: lat,
              destinationLng: lng,
              shipmentId: shipmentId,
              providerEmail: shipment.serviceOrdered?.order?.providerForService?.provider?.spProfile?.emailAddress,
            ),
          ),
        );
        return;
      }

     
      if (status == "in_transit" || status == "arrived" || status == "delivered" || status == "in_session") {
        final sessionController = SessionByShipmentController();
        await sessionController.fetchSession(shipmentId.toString());
        final session = sessionController.session;

        if (session != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: sessionController,
                child: SessionScreen(
                  session: session,
                  providerEmail: shipment.serviceOrdered?.order?.providerForService?.provider?.spProfile?.emailAddress,
                ),
              ),
            ),
          );
          return;
        }

        // If no session, open QR (only for arrived/delivered)
        if (status == "arrived" || status == "delivered") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SessionInitiationQrScreen(
                shipmentId: shipmentId,
                providerEmail: shipment.serviceOrdered?.order?.providerForService?.provider?.spProfile?.emailAddress,
              ),
            ),
          );
          return;
        }

        ScheduleFlushbar.error(context, "Session not found for shipment");
        return;
      }

      ScheduleFlushbar.error(context, "Cannot start navigation for status: $status"); 
    },

    icon: const Icon(Icons.navigation),
    label: Text(
      _status == "pending" ? "Start" : "Resume", // ✅ Dynamic label
      style: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
),



      ],
    );
  }
}
