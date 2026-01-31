import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/schedule_directions/views/here_directions_schedule.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/client_info_tile.dart';
import 'package:flutter_application_2/screens/schedule_directions/widgets/shipment_stauts_helper.dart';

class ScheduleActionButtons extends StatelessWidget {
  final Shipment shipment;

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
              foregroundColor: Kolors.kPrimary,
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
                    initialChildSize: 0.4,
                    minChildSize: 0.2,
                    maxChildSize: 0.9,
                    builder: (_, controller) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
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


 

  // ✅ Navigate ONLY after backend confirms status
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
