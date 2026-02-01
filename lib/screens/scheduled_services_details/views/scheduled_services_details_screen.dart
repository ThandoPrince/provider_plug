import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_action_buttons.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/scheduled_address_tile.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/scheduled_notes_section.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/scheduled_order_details_helpers.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/scheduled_service_images.dart';

class ScheduledOrderDetails extends StatefulWidget {
  final Shipment shipment;

  const ScheduledOrderDetails({super.key, required this.shipment});

  @override
  State<ScheduledOrderDetails> createState() => _ScheduledOrderDetailsState();
}

class _ScheduledOrderDetailsState extends State<ScheduledOrderDetails> {
  bool _showHeader = true;

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.scrollDelta! > 0 && _showHeader) {
        setState(() => _showHeader = false);
      } else if (notification.scrollDelta! < 0 && !_showHeader) {
        setState(() => _showHeader = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipment = widget.shipment;
    final order = shipment.serviceOrdered;

    return Scaffold(
      backgroundColor: Kolors.kPrimary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kSecondaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _onScroll(notification);
            return false;
          },
          child: Column(
            children: [
              // ✅ FIXED SAFE HEADER (never collapses system inset)
              SafeArea(
                bottom: false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: _showHeader ? 56 : 0,
                  curve: Curves.easeOut,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
  children: [
    if (_showHeader) ...[
      const BackButton(color: Colors.white),
      const SizedBox(width: 8),
    ],
    const Text(
      "Order Details",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  ],
),

                  ),
                ),
              ),

              // ✅ CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              order?.order?.title?.toUpperCase() ??
                                  "SERVICE DETAIL N/A",
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                         
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Buttons row
                      ScheduleActionButtons(shipment: shipment),
                      const SizedBox(height: 16),

                      // Service & Schedule
                      ScheduledOrderDetailsHelpers.buildSectionCard(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Service & Schedule",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            ScheduledOrderDetailsHelpers.buildDetailRow(
                              "Scheduled Date",
                              ScheduledOrderDetailsHelpers.formatDateTime(
                                shipment.shipmentScheduleDate,
                              ),
                              icon: Icons.calendar_today,
                            ),
                            ScheduledOrderDetailsHelpers.buildDetailRow(
                              "Service Requested",
                              order?.order?.serviceRequired?.serviceName ?? "N/A",
                              icon: Icons.build,
                            ),
                          ],
                        ),
                      ),

                      // Pricing
                      ScheduledOrderDetailsHelpers.buildSectionCard(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Pricing Summary",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            ScheduledOrderDetailsHelpers.buildDetailRow(
                              "Final Price",
                              "R${order?.order?.proposalPrice?.toStringAsFixed(2) ?? '0.00'}",
                              icon: Icons.money,
                              isPrimary: true,
                            ),
                          ],
                        ),
                      ),

                      // Service Images
                      if (shipment.serviceOrdered?.order?.orderPictures
                              ?.isNotEmpty ??
                          false)
                        ScheduledOrderDetailsHelpers.buildSectionCard(
                          ScheduledServiceImages(shipment: shipment),
                        ),

                      // Address
                      ScheduledOrderDetailsHelpers.buildSectionCard(
                        ScheduledAddressTile(
                          address:
                              shipment.serviceOrdered?.order?.deliveryAddress,
                        ),
                      ),

                      // Notes
                      ScheduledOrderDetailsHelpers.buildSectionCard(
                        ScheduledNotesSection(notes: order?.order?.notes),
                      ),

                      // Reference IDs
                      ScheduledOrderDetailsHelpers.buildSectionCard(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Reference IDs",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            ScheduledOrderDetailsHelpers.buildDetailRow(
                              "Order ID",
                              order?.order?.orderId.toString() ?? "N/A",
                              icon: Icons.tag,
                            ),
                            ScheduledOrderDetailsHelpers.buildDetailRow(
                              "Shipment ID",
                              shipment.shipmentId.toString(),
                              icon: Icons.local_shipping,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
