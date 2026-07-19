import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/session_by_shipment_ctrl.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_route_model.dart';
import 'package:flutter_application_2/common/services/session_socket_service.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/views/session_initiation_qr_screen.dart';
import 'package:flutter_application_2/screens/schedule_directions/views/here_directions_schedule.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/here_map_controller.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/navigate_screen.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/client_info_tile.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_flushbar_widget.dart';
import 'package:flutter_application_2/screens/session/views/session_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/routing.dart' as here;
import 'package:provider/provider.dart';
import 'package:flutter_application_2/common/services/shipment_route_api.dart';
class ScheduleActionButtons extends StatefulWidget {
  final Shipment shipment;
final SessionSocketService sessionSocket;
  const ScheduleActionButtons({super.key, required this.shipment, required this.sessionSocket});

  @override
  State<ScheduleActionButtons> createState() => _ScheduleActionButtonsState();
}

class _ScheduleActionButtonsState extends State<ScheduleActionButtons> {
  String get _status => widget.shipment.shipmentStatus?.toLowerCase() ?? "";

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
                            client: widget.shipment.serviceOrdered?.order?.client,
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
      final lat = widget.shipment.serviceOrdered?.order?.deliveryAddress?.latitude ?? 0.0;
      final lng = widget.shipment.serviceOrdered?.order?.deliveryAddress?.longitude ?? 0.0;

      if (lat == 0.0 || lng == 0.0) {
        ScheduleFlushbar.error(context, "Invalid destination coordinates");
        return;
      }

      final shipmentId = widget.shipment.shipmentId ?? 0;
      final status = _status; 

 
      if (status == "pending") {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HereDestinationScreen(
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
  try {
    final routes = await ShipmentRouteApi.getShipmentRoutes(
      shipmentId,
    );

    if (routes.isEmpty) {
      ScheduleFlushbar.error(
        context,
        "No navigation route found.",
      );
      return;
    }

    final latestRoute = routes.last;

    final travelMode =
        travelModeFromString(latestRoute.travelMode);

    final currentPosition =
        await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    final routingEngine = here.RoutingEngine();

    final waypoints = [
      here.Waypoint(
        GeoCoordinates(
          currentPosition.latitude,
          currentPosition.longitude,
        ),
      ),
      here.Waypoint(
        GeoCoordinates(
          latestRoute.destinationLat,
          latestRoute.destinationLng,
        ),
      ),
    ];

    void navigate(List<here.Route>? calculatedRoutes) {
      if (calculatedRoutes == null || calculatedRoutes.isEmpty) {
        ScheduleFlushbar.error(
          context,
          "Failed to resume navigation.",
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NavigationScreen(
            shipmentId: shipmentId,
            route: calculatedRoutes.first,
            travelMode: travelMode,
            destinationLat: latestRoute.destinationLat,
            destinationLng: latestRoute.destinationLng,
            sessionSocket: widget.sessionSocket,
          ),
        ),
      );
    }

    switch (travelMode) {
      case TravelMode.car:
        routingEngine.calculateCarRoute(
          waypoints,
          here.CarOptions(),
          (error, calculatedRoutes) {
            if (error != null) {
              ScheduleFlushbar.error(
                context,
                "Failed to resume navigation.",
              );
              return;
            }

            navigate(calculatedRoutes);
          },
        );
        break;

      case TravelMode.pedestrian:
        routingEngine.calculatePedestrianRoute(
          waypoints,
          here.PedestrianOptions(),
          (error, calculatedRoutes) {
            if (error != null) {
              ScheduleFlushbar.error(
                context,
                "Failed to resume navigation.",
              );
              return;
            }

            navigate(calculatedRoutes);
          },
        );
        break;

      case TravelMode.bicycle:
      case TravelMode.scooter:
        routingEngine.calculateBicycleRoute(
          waypoints,
          here.BicycleOptions(),
          (error, calculatedRoutes) {
            if (error != null) {
              ScheduleFlushbar.error(
                context,
                "Failed to resume navigation.",
              );
              return;
            }

            navigate(calculatedRoutes);
          },
        );
        break;
    }
  } catch (e) {
    ScheduleFlushbar.error(
      context,
      "Failed to load navigation route.",
    );
  }

  return;
}

     
      if ( status == "arrived" || status == "delivered" || status == "in_session") {
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
                  sessionSocket: widget.sessionSocket,
                  
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
                sessionSocket: widget.sessionSocket,
                
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
