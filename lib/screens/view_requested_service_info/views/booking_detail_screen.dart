import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiations_by_id_email_ctrl.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/common/widgets/negotiation_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/common/controller/bookings/booking_by_orderID_controller.dart';
import 'package:intl/intl.dart';

class BookingDetailScreen extends StatelessWidget {
  final int orderId;
  const BookingDetailScreen({super.key, required this.orderId});

  String formatDateTime(DateTime? dt) {
    if (dt == null) return "N/A";
    return DateFormat("dd MMM yyyy, HH:mm").format(dt);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "in-negotiation":
        return Colors.blue;
      case "pending":
        return Colors.amber.shade700;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color secondaryColor = Kolors.kSecondaryLight;
    const Color cardBackgroundColor = Colors.white;
    final Color primaryTextColor = Colors.black87;
    final Color secondaryTextColor = Colors.black54;

    return ChangeNotifierProvider(
      create: (_) =>
          BookingByOrderIDController()..fetchBookingByOrderID(orderId),
      child: Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Order Details",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Consumer<BookingByOrderIDController>(
            builder: (context, controller, child) {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (controller.errorMessage != null) {
                return Center(
                  child: Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              }

              if (controller.booking == null) {
                return const Center(
                  child: Text(
                    "No booking details available.",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              final booking = controller.booking!;
              final statusColor = _getStatusColor(booking.status);
              final displayStatus = (booking.status ?? "Pending")
                  .replaceAll('_', ' ')
                  .toUpperCase();

              // ✅ Improved showNegotiationBottomSheet with refresh logic
              Future<void> showNegotiationBottomSheet(
                BuildContext context,
                int orderId,
                String providerEmail,
              ) async {
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) {
                    return FractionallySizedBox(
                      heightFactor: 0.8,
                      child: ChangeNotifierProvider(
                        create: (_) => SpNegotiationsByIdEmailCtrl()
                          ..loadNegotiations(
                            orderId: orderId,
                            email: providerEmail,
                          ),
                        child: NegotiationBottomSheetContent(
                          orderId: orderId,
                          providerEmail: providerEmail,
                        ),
                      ),
                    );
                  },
                );

                // ✅ Auto-refresh booking after negotiation closes
                if (result == true) {
                  controller.fetchBookingByOrderID(orderId);
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: cardBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                (booking.title ?? "Service Booking")
                                    .toUpperCase(),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
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
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Client Info
                    DetailCard(
                      title: "Client Info",
                      primaryTextColor: primaryTextColor,
                      children: [
                        DetailRow(
                          label: "Name",
                          value:
                              "${booking.client?.firstName ?? ""} ${booking.client?.lastName ?? ""}",
                          color: secondaryTextColor,
                        ),
                        DetailRow(
                          label: "Email",
                          value: booking.client?.clientProfile?.emailAddress ??
                              "N/A",
                          color: secondaryTextColor,
                        ),
                        DetailRow(
                          label: "Rating",
                          value: booking.client?.rating ?? "N/A",
                          color: secondaryTextColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Booking Info
                    DetailCard(
                      title: "Booking Info",
                      primaryTextColor: primaryTextColor,
                      children: [
                        DetailRow(
                          label: "Requested Date",
                          value: formatDateTime(booking.requestedDateTime),
                          color: secondaryTextColor,
                        ),
                        DetailRow(
                          label: "Proposal Price",
                          value:
                              "R ${booking.proposalPrice?.toStringAsFixed(2) ?? "N/A"}",
                          color: secondaryTextColor,
                        ),
                        DetailRow(
                          label: "Service",
                          value: booking.serviceRequired?.serviceName ?? "N/A",
                          color: secondaryTextColor,
                        ),
                        DetailRow(
                          label: "Negotiation",
                          value: "View Negotiation",
                          color: Colors.blue,
                          onTap: () {
                            if (booking.orderId != null) {
                              const hardCodedEmail =
                                  'nomfundomabunda748@gmail.com';
                              showNegotiationBottomSheet(
                                context,
                                booking.orderId!,
                                hardCodedEmail,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (booking.notes != null && booking.notes!.isNotEmpty)
                      DetailCard(
                        title: "Notes",
                        primaryTextColor: primaryTextColor,
                        children: [
                          Text(
                            booking.notes!,
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    if (booking.notes != null && booking.notes!.isNotEmpty)
                      const SizedBox(height: 16),

                    DetailCard(
                      title: "Delivery Address",
                      primaryTextColor: primaryTextColor,
                      children: [
                        Text(
                          booking.deliveryAddress?.formattedAddress ?? "N/A",
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (booking.orderPictures != null &&
                        booking.orderPictures!.isNotEmpty)
                      Card(
                        color: cardBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Service Required Images (${booking.orderPictures!.length})",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor,
                                ),
                              ),
                              const Divider(height: 18),
                              SizedBox(
                                height: 120,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: booking.orderPictures!.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    final imgUrl =
                                        booking.orderPictures![index].imageUrl;
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imgUrl,
                                        width: 120,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) =>
                                            Container(
                                              width: 120,
                                              height: 100,
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.broken_image,
                                                color: Colors.grey,
                                              ),
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
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

// --------------------------
// DetailCard and DetailRow
// --------------------------

class DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color primaryTextColor;

  const DetailCard({
    super.key,
    required this.title,
    required this.children,
    required this.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const Divider(height: 18),
            ...children.map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              decoration: onTap != null ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );

    return onTap != null ? InkWell(onTap: onTap, child: content) : content;
  }
}
