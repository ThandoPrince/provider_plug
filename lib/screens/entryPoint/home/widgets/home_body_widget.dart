import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

import 'package:flutter_application_2/common/controller/bookings/bookings_by_email_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/remove_invitation_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/screens/view_requested_service_info/views/booking_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeBodyWidget extends StatefulWidget {
  const HomeBodyWidget({super.key});

  @override
  State<HomeBodyWidget> createState() => _HomeBodyWidgetState();
}

class _HomeBodyWidgetState extends State<HomeBodyWidget> {
  // Helper function to get the status color and a more human-readable status
  Map<String, dynamic> getStatusInfo(String? status) {
    String actualStatus = status ?? "Pending";
    Color statusColor;
    String displayStatus;

    switch (actualStatus.toLowerCase()) {
      case "completed":
        statusColor = Colors.green;
        displayStatus = "Completed";
        break;
      case "in-negotiation":
        statusColor = Colors.blue;
        displayStatus = "In Negotiation";
        break;
      case "rescheduled":
        statusColor = Colors.white;
        displayStatus = "Rescheduled";

      case "overdue":
        statusColor = Colors.red;
        displayStatus = "Overdue";
        break;
      case "pending":
      default:
        statusColor = Colors.orange.shade700;
        displayStatus = "Pending";
    }
    return {'color': statusColor, 'status': displayStatus};
  }

  Future<void> _showBookingOptions(
    BuildContext context,
    OrderService booking,
  ) async {
    final removeController = context.read<RemoveInvitationController>();
    final bookingsController = context.read<SPBookingController>();

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Decline invitation"),
                subtitle: const Text(
                  "Remove yourself from this booking invitation.",
                ),
                onTap: () async {
                  Navigator.pop(context);

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Decline invitation?"),
                      content: const Text(
                        "You will no longer receive updates for this booking.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Decline"),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  final success = await removeController.removeInvitation(
                    orderId: booking.orderId!,
                  );

                  if (!mounted) return;

                  if (success) {
                    FlushbarService.success(
                      context,
                      "Invitation removed successfully.",
                    );
                    final providerID = AuthSessionController.instance.id;
                    // Refresh bookings
                    await bookingsController.fetchActiveBookings(providerID!);
                  } else {
                    FlushbarService.error(
                      context,
                      removeController.errorMessage ??
                          "Unable to remove invitation.",
                    );
                  }
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define a subtle card background color that works with the gradient
    const Color cardBackgroundColor = Colors.white;
    // Define a primary text color
    final Color primaryTextColor = Colors.black87;
    // Define a secondary text color
    final Color secondaryTextColor = Colors.black54;

    return Consumer<SPBookingController>(
      builder: (context, controller, child) {
        if (controller.errorMessage != null) {
          return Center(child: Text(controller.errorMessage!));
        }

        if (controller.activeBookings.isEmpty) {
          return const Center(
            child: Text(
              "No active bookings. \nTime to relax! 😌",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView.builder(
            itemCount: controller.activeBookings.length,
            itemBuilder: (context, index) {
              OrderService booking = controller.activeBookings[index];

              // Format the requested date and time
              String formattedDateTime = booking.requestedDateTime != null
                  ? DateFormat(
                      "dd MMM yyyy, HH:mm",
                    ).format(booking.requestedDateTime!)
                  : "No date/time requested";

              // Get status info
              final statusInfo = getStatusInfo(booking.status);
              final statusColor = statusInfo['color'] as Color;
              final displayStatus = statusInfo['status'] as String;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Card(
                  color: cardBackgroundColor, // Use white for contrast
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    // Add a subtle border for extra definition
                    side: BorderSide(
                      color: statusColor.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  elevation: 5, // Higher elevation for a floating effect
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      if (booking.orderId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookingDetailScreen(orderId: booking.orderId!),
                          ),
                        );
                      }
                    },
                    onLongPress: () {
                      _showBookingOptions(context, booking);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Title and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  (booking.title ?? "Booking Detail")
                                      .toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                    color: primaryTextColor,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ), // Pill shape
                                ),
                                child: Text(
                                  displayStatus,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 18, thickness: 1),

                          // Booking Details Section
                          BookingDetailRow(
                            icon: Icons.person_outline,
                            label: "Client",
                            value:
                                "${booking.client?.firstName ?? "N/A"} ${booking.client?.lastName ?? ""}",
                            color: secondaryTextColor,
                          ),
                          const SizedBox(height: 6),
                          BookingDetailRow(
                            icon: Icons.calendar_today_outlined,
                            label: "Date & Time",
                            value: formattedDateTime,
                            color: secondaryTextColor,
                          ),
                          const SizedBox(height: 6),
                          BookingDetailRow(
                            icon: Icons.build_outlined,
                            label: "Service",
                            value:
                                booking.serviceRequired?.serviceName ??
                                "Not specified",
                            color: secondaryTextColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// A reusable widget for detail rows
class BookingDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const BookingDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
