import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/scheduled_services/widgets/scheduled_orders_helpers.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/views/scheduled_services_details_screen.dart';


class ScheduledOrderCard extends StatelessWidget {
  final dynamic shipment;
  final VoidCallback onRefresh;

  const ScheduledOrderCard({
    super.key,
    required this.shipment,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final order = shipment.serviceOrdered;
    final statusColor = getStatusColor(shipment.shipmentStatus);
    final display = displayStatus(shipment.shipmentStatus);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(16),
  side: BorderSide(
    color: statusColor.withOpacity(0.6),
    width: 1.5,
  ),
),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final shouldRefresh = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => ScheduledOrderDetails(shipment: shipment),
              ),
            );

            if (shouldRefresh == true) {
              onRefresh();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order?.order?.title?.toUpperCase() ??
                            "SERVICE DETAIL N/A",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Kolors.kDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        display,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, color: Kolors.kOffWhite),
                Text(
                  "Scheduled Date: ${formatDateTime(shipment.shipmentScheduleDate)}",
                  style: const TextStyle(
                      color: Kolors.kDark, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  "Price: R${order?.order?.proposalPrice?.toStringAsFixed(2) ?? '0.00'}",
                  style: const TextStyle(
                    color: Kolors.kDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
