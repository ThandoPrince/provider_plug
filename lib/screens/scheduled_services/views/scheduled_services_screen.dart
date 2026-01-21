import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/scheduled_services/scheduled_services_details/views/scheduled_services_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ScheduledOrdersScreen extends StatelessWidget {
  final String email;

  const ScheduledOrdersScreen({required this.email});

  String formatDateTime(DateTime? dt) {
    if (dt == null) return "N/A";
    // Using a concise format for better fit
    return DateFormat("dd MMM yyyy, HH:mm").format(dt);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "pending":
        return Colors.orange.shade700; // Adjusted for better contrast on white
      case "confirmed":
        return Colors.green.shade700; // Adjusted for better contrast on white
      case "cancelled":
        return Colors.red.shade700; // Adjusted for better contrast on white
      case "in progress":
        return Colors.blue.shade700; // Adjusted for better contrast on white
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the color scheme for clarity
    const Color primaryColor = Kolors.kPrimary;
    const Color cardTextColor = Kolors.kDark;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Scheduled Orders",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // NOTE: Using kSecondaryLight based on your previous style
            colors: [Kolors.kPrimary, Kolors.kSecondaryLight], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ChangeNotifierProvider(
          create: (_) => ShipmentController()..fetchShipments(email),
          child: Consumer<ShipmentController>(
            builder: (context, ctrl, child) {
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

              if (ctrl.shipments == null || ctrl.shipments!.isEmpty) {
                return const Center(
                  child: Text(
                    "No scheduled orders found.",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ctrl.shipments!.length,
                itemBuilder: (context, index) {
                  final shipment = ctrl.shipments![index];
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
                        onTap: ()  {
    if (shipment != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScheduledOrderDetails(shipment: shipment),
        ),
      );
    }
  },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- 1. TITLE & STATUS BADGE (In a Row) ---
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      order?.order?.title?.toUpperCase() ?? "SERVICE DETAIL N/A",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: cardTextColor,
                                      ),
                                      maxLines: 2, // Allow title to wrap
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
                                      border: Border.all(color: statusColor.withOpacity(0.5), width: 0.5),
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
                              
                              const Divider(height: 24, color: Kolors.kOffWhite), // Separator

                              // --- 2. SCHEDULED DATE (Full Width Row) ---
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Kolors.kDark),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Scheduled Date: ${formatDateTime(shipment.shipmentScheduleDate)}",
                                      style: const TextStyle(
                                        color: cardTextColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // --- 3. PRICE (Full Width Row) ---
                              Row(
                                children: [
                                  const Icon(Icons.local_offer, size: 16, color: Kolors.kDark),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Price: R${order?.order?.proposalPrice?.toStringAsFixed(2) ?? '0.00'}",
                                      style: const TextStyle(
                                        color: Kolors.kPrimary, // Highlight price
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
              );
            },
          ),
        ),
      ),
    );
  }
}