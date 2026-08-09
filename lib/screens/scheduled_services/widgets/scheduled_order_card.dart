import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/cancel_shipment_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_bottom_sheet.dart';
import 'package:flutter_application_2/common/widgets/app_confirmation_dialog.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/screens/scheduled_services/widgets/scheduled_orders_helpers.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/views/scheduled_services_details_screen.dart';
import 'package:provider/provider.dart';


class ScheduledOrderCard extends StatefulWidget {
  final dynamic shipment;
  final VoidCallback onRefresh;

  const ScheduledOrderCard({
    super.key,
    required this.shipment,
    required this.onRefresh,
  });

  @override
  State<ScheduledOrderCard> createState() => _ScheduledOrderCardState();
}

class _ScheduledOrderCardState extends State<ScheduledOrderCard> {
  final CancelShipmentController _cancelController =
      CancelShipmentController();
  

  Future<void> _showShipmentOptions(BuildContext context) async {
  await showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => AppBottomSheet(
    title: "Scheduled Order",
    children: [
      ListTile(
        leading: const Icon(
          Icons.cancel_outlined,
          color: Colors.redAccent,
        ),
        title: const Text(
          "Cancel scheduled order",
          style: TextStyle(color: Colors.white),
        ),
        subtitle: const Text(
          "This action cannot be undone.",
          style: TextStyle(color: Colors.white54),
        ),
        onTap: () async {
          Navigator.pop(context);

          final confirm = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const AppConfirmationDialog(
              icon: Icons.event_busy_rounded,
              iconColor: Colors.redAccent,
              title: "Cancel Scheduled Order",
              message:
                  "Are you sure you want to cancel this scheduled order?\n\n"
                  "This action cannot be undone.",
              confirmText: "Cancel Order",
              cancelText: "Keep Order",
              confirmColor: Colors.red,
            ),
          );

          if (confirm != true) return;

          final success = await _cancelController.cancelShipment(
            shipmentId: widget.shipment.shipmentId!,
          );

          if (!mounted) return;

          if (success) {
            await context.read<ShipmentController>().fetchShipments();

            if (!mounted) return;

            FlushbarService.success(
              context,
              "Scheduled order cancelled successfully.",
            );

            widget.onRefresh();
          } else {
            FlushbarService.error(
              context,
              _cancelController.errorMessage ??
                  "Unable to cancel scheduled order.",
            );
          }
        },
      ),
    ],
  ),
);
}
  Widget build(BuildContext context) {
    final order = widget.shipment.serviceOrdered;
    final statusColor = getStatusColor(widget.shipment.shipmentStatus);
    final display = displayStatus(widget.shipment.shipmentStatus);

    return Padding(
  padding: const EdgeInsets.only(bottom: 14),
  child: Card(
    color: Colors.white,
    elevation: 6,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(
        color: statusColor.withOpacity(0.45),
        width: 1.5,
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onLongPress: () {
  _showShipmentOptions(context);
},
      onTap: () async {
        final shouldRefresh = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => ScheduledOrderDetails(shipment: widget.shipment),
          ),
        );

        if (shouldRefresh == true) {
          widget.onRefresh();
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title + Status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.assignment_outlined,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    order?.order?.title?.toUpperCase() ??
                        "SERVICE DETAIL N/A",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Kolors.kDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    display,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1),
            ),

            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    formatDateTime(widget.shipment.shipmentScheduleDate),
                    style: const TextStyle(
                      color: Kolors.kDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.payments_outlined,
                  size: 18,
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  "R${order?.order?.proposalPrice?.toStringAsFixed(2) ?? '0.00'}",
                  style: const TextStyle(
                    color: Kolors.kDark,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
