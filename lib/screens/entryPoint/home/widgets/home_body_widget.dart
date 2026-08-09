import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/auth/auth_session_controller.dart';

import 'package:flutter_application_2/common/controller/bookings/bookings_by_email_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/remove_invitation_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/app_bottom_sheet.dart';
import 'package:flutter_application_2/common/widgets/app_confirmation_dialog.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/screens/view_requested_service_info/views/booking_detail_screen.dart';
import 'package:go_router/go_router.dart';
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
  final actualStatus = (status ?? "Pending").toLowerCase();

  switch (actualStatus) {
    case "completed":
      return {
        'color': Colors.green,
        'status': 'Completed',
      };

    case "in-negotiation":
      return {
        'color': Colors.blue,
        'status': 'In Negotiation',
      };

    case "rescheduled":
      return {
        'color': Colors.deepPurple,
        'status': 'Rescheduled',
      };

    case "overdue":
      return {
        'color': Colors.red,
        'status': 'Overdue',
      };

    case "pending":
      return {
        'color': Colors.orange,
        'status': 'Pending',
      };

    default:
      return {
        'color': Colors.grey,
        'status': status ?? 'Unknown',
      };
  }
}

  Future<void> _showBookingOptions(
    BuildContext context,
    OrderService booking,
  ) async {
    final removeController = context.read<RemoveInvitationController>();
    final bookingsController = context.read<SPBookingController>();

    await showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => AppBottomSheet(
    title: "Invitation",
    children: [
      ListTile(
        leading: const Icon(
          Icons.delete_outline,
          color: Colors.redAccent,
        ),
        title: const Text(
          "Decline invitation",
          style: TextStyle(color: Colors.white),
        ),
        subtitle: const Text(
          "Remove yourself from this booking invitation.",
          style: TextStyle(color: Colors.white54),
        ),
        onTap: () async {
          Navigator.pop(context);

          final confirm = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const AppConfirmationDialog(
              icon: Icons.cancel_schedule_send_outlined,
              iconColor: Colors.redAccent,
              title: "Decline Invitation",
              message:
                  "Are you sure you want to decline this booking invitation?\n\n"
                  "You will no longer receive updates or be able to accept this booking.",
              confirmText: "Decline",
              confirmColor: Colors.red,
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

            final providerId = AuthSessionController.instance.id;

            await bookingsController.fetchActiveBookings(
              providerId!,
            );
          } else {
            FlushbarService.error(
              context,
              removeController.errorMessage ??
                  "Unable to remove invitation.",
            );
          }
        },
      ),
    ],
  ),
);
  }

  @override
  Widget build(BuildContext context) {
    const Color cardBackgroundColor = Colors.white;
    final Color primaryTextColor = Colors.black87;
    final Color secondaryTextColor = Colors.black54;
    

    return Consumer<SPBookingController>(
      builder: (context, controller, child) {
        final hasBookings = controller.activeBookings.isNotEmpty;
        final connectionStatus = controller.connectionStatus;

final showConnectionBanner =
    controller.hasConnectedOnce &&
    connectionStatus != BookingConnectionStatus.live;

        // Only take over the whole screen with an error when there's
        // nothing cached to fall back on. A transient socket drop or
        // failed poll with an existing list should never wipe it —
        // that's strictly worse than showing slightly stale data with
        // a small "reconnecting" indicator.
        if (controller.errorMessage != null && !hasBookings) {
          return _buildErrorState(context, controller);
        }

        if (!hasBookings) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
             if (showConnectionBanner)
      _buildConnectionBanner(controller),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView.builder(
                  itemCount: controller.activeBookings.length,
                  itemBuilder: (context, index) {
                    OrderService booking = controller.activeBookings[index];

                    String formattedDateTime = booking.requestedDateTime != null
                        ? DateFormat("dd MMM yyyy, HH:mm")
                            .format(booking.requestedDateTime!)
                        : "No date/time requested";

                    final statusInfo = getStatusInfo(booking.status);
                    final statusColor = statusInfo['color'] as Color;
                    final displayStatus = statusInfo['status'] as String;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Card(
                        color: cardBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: statusColor.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        elevation: 5,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            if (booking.orderId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BookingDetailScreen(booking: booking),
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
                                        borderRadius: BorderRadius.circular(20),
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
                                  value: booking.serviceRequired?.serviceName ??
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
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConnectionBanner(SPBookingController controller) {

    
    
    final isReconnecting =
        controller.connectionStatus == BookingConnectionStatus.reconnecting;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isReconnecting
          ? Colors.orange.withOpacity(0.15)
          : Colors.red.withOpacity(0.15),
      child: Row(
        children: [
          Icon(
            isReconnecting ? Icons.sync : Icons.wifi_off,
            size: 16,
            color: isReconnecting ? Colors.orange : Colors.redAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isReconnecting
                  ? "Reconnecting… showing your last known bookings."
                  : "Connection lost. Showing your last known bookings.",
              style: TextStyle(
                fontSize: 12,
                color: isReconnecting ? Colors.orange.shade800 : Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, SPBookingController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              controller.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white24,
    foregroundColor: Colors.white70,
  ),
  onPressed: () {
    final providerId = controller.currentProviderId;
    if (providerId != null) {
      controller.fetchActiveBookings(
        providerId,
        replace: true,
      );
    }
  },
  child: const Text(
    "Retry",
    style: TextStyle(
      color: Colors.white,
    ),
  ),
),
          ],
        ),
      ),
    );
  }
}
Widget _buildEmptyState(BuildContext context) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.work_outline_rounded,
            size: 64,
            color: Colors.white24,
          ),
          const SizedBox(height: 16),
          const Text(
            "No active bookings",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You don't have any booking invitations or active negotiations at the moment.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white38,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              context.push('/provider_linked_services');
            },
            icon: const Icon(
              Icons.build_circle_outlined,
              size: 18,
              color: Kolors.kPrimary,
            ),
            label: const Text("Manage Linked Services", style: TextStyle(color: Kolors.kPrimary),
          ),
          )
        ],
      ),
    ),
  );
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
