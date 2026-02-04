import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/views/scheduled_services_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ScheduledOrdersScreen extends StatefulWidget {
  final String email;
  const ScheduledOrdersScreen({super.key, required this.email});

  @override
  State<ScheduledOrdersScreen> createState() => _ScheduledOrdersScreenState();
}

class _ScheduledOrdersScreenState extends State<ScheduledOrdersScreen> {
  late final ShipmentController _controller;

  // Track header visibility
  bool _showHeader = true;

  @override
  void initState() {
    super.initState();
    _controller = ShipmentController();
    _controller.fetchShipments(widget.email);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatDateTime(DateTime? dt) {
    if (dt == null) return "N/A";
    return DateFormat("dd MMM yyyy, HH:mm").format(dt);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "pending":
        return Colors.orange.shade700;
      case "confirmed":
        return Colors.green.shade700;
      case "cancelled":
        return Colors.red.shade700;
      case "in progress":
        return Colors.blue.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _refresh() async {
    await _controller.fetchShipments(widget.email);
  }

  // Scroll listener
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
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Kolors.kPrimary,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Kolors.kPrimary, Kolors.kSecondaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Consumer<ShipmentController>(
            builder: (context, ctrl, _) {
              if (ctrl.isLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
              }

              if (ctrl.errorMessage != null) {
                return Center(
                  child: Text(
                    ctrl.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              }

              if (ctrl.shipments.isEmpty) {
                return const Center(
                  child: Text(
                    "No scheduled orders found.",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                );
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  _onScroll(notification);
                  return false;
                },
                child: Column(
                  children: [
                    // Animated header
                    // Animated header
// ✅ Always reserve system inset space
SafeArea(
  bottom: false,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 220),
    height: _showHeader ? 56 : 0, // fixed header height
    curve: Curves.easeOut,
    child: SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Scheduled Orders",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
    ),
  ),
),



                    // Orders list
                    Expanded(
                      child: RefreshIndicator(
                        color: Kolors.kPrimary,
                        onRefresh: _refresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: ctrl.shipments.length,
                          itemBuilder: (context, index) {
                            final shipment = ctrl.shipments[index];
                            final order = shipment.serviceOrdered;
                            final statusColor = _getStatusColor(shipment.shipmentStatus);
                            final displayStatus = (shipment.shipmentStatus ?? "UNKNOWN")
                                .replaceAll('_', ' ')
                                .toUpperCase();

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 3,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () async {
                                    final shouldRefresh = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ScheduledOrderDetails(shipment: shipment),
                                      ),
                                    );

                                    if (shouldRefresh == true && mounted) {
                                      await _refresh();
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(18),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: statusColor.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: statusColor.withOpacity(0.5),
                                                    width: 0.5),
                                              ),
                                              child: Text(
                                                displayStatus,
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
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 16, color: Kolors.kDark),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Scheduled Date: ${formatDateTime(shipment.shipmentScheduleDate)}",
                                                style: const TextStyle(
                                                  color: Kolors.kDark,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.local_offer,
                                                size: 16, color: Kolors.kDark),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Price: R${order?.order?.proposalPrice?.toStringAsFixed(2) ?? '0.00'}",
                                                style: const TextStyle(
                                                  color: Kolors.kDark,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
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
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
