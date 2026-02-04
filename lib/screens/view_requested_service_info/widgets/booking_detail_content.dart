import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/common/controller/bookings/booking_by_orderID_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/sp_negotiations_by_id_email_ctrl.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_2/common/widgets/negotiation_bottom_sheet.dart';
import 'package:flutter_application_2/screens/view_requested_service_info/widgets/detail_widgets.dart';

class BookingDetailContent extends StatelessWidget {
  final OrderService booking;
  const BookingDetailContent({super.key, required this.booking});

  String formatDateTime(DateTime? dt) {
    if (dt == null) return "N/A";
    return DateFormat("dd MMM yyyy, HH:mm").format(dt);
  }

  Future<void> showNegotiationBottomSheet(
    BuildContext context,
    int orderId,
    String providerEmail,
  ) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Kolors.kPrimary, Kolors.kSecondaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: FractionallySizedBox(
          heightFactor: 0.85,
          child: ChangeNotifierProvider(
            create: (_) =>
                SpNegotiationsByIdEmailCtrl()
                  ..loadNegotiations(orderId: orderId, email: providerEmail),
            child: NegotiationBottomSheetContent(
              orderId: orderId,
              providerEmail: providerEmail,
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      Provider.of<BookingByOrderIDController>(
        context,
        listen: false,
      ).fetchBookingByOrderID(orderId);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryText = Colors.black87;
    const Color secondaryText = Colors.black54;
    const double kCardSpacing = 16;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(title: booking.title ?? "General Service"),
          const SizedBox(height: 20),

          // CLIENT CARD
          DetailCard(
            title: "Client Information",
            primaryTextColor: primaryText,
            children: [
              DetailRow(
                label: "Name",
                value:
                    "${booking.client?.firstName ?? ""} ${booking.client?.lastName ?? ""}",
                color: secondaryText,
              ),
              DetailRow(
                label: "Rating",
                value: booking.client?.rating ?? "N/A",
                color: secondaryText,
              ),
            ],
          ),
          const SizedBox(height: kCardSpacing),
          // BOOKING INFO & NEGOTIATION
          DetailCard(
            title: "Booking Details",
            primaryTextColor: primaryText,
            children: [
              DetailRow(
                label: "Required On",
                value: formatDateTime(booking.requestedDateTime),
                color: secondaryText,
              ),
              DetailRow(
                label: "Proposed Price",
                value:
                    "R ${booking.proposalPrice?.toStringAsFixed(2) ?? "0.00"}",
                color: secondaryText,
              ),
              DetailRow(
                label: "Service Category",
                value: booking.serviceRequired?.serviceName ?? "N/A",
                color: secondaryText,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(thickness: 0.5),
              ),

              Material(
                color: Colors.blueAccent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    if (booking.orderId != null) {
                      const hardCodedEmail = 'nomfundomabunda748@gmail.com';
                      showNegotiationBottomSheet(
                        context,
                        booking.orderId!,
                        hardCodedEmail,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.handshake_outlined,
                          color: Colors.blueAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "VIEW NEGOTIATION",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.blueAccent.withOpacity(0.5),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: kCardSpacing),

          if (booking.notes != null && booking.notes!.isNotEmpty)
            if (booking.notes != null && booking.notes!.isNotEmpty)
              Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    iconColor: Colors.blueAccent,
                    collapsedIconColor: Colors.blueAccent,
                    title: Text(
                      "Client Notes",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Kolors.kDark,
                      ),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.format_quote_rounded,
                              color: Colors.blueAccent.withOpacity(0.25),
                              size: 28,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              booking.notes!,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

          const SizedBox(height: kCardSpacing),
          // LOCATION
          DetailCard(
            title: "Delivery Location",
            primaryTextColor: primaryText,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      booking.deliveryAddress?.formattedAddress ??
                          "No address provided",
                      style: const TextStyle(
                        fontSize: 14,
                        color: secondaryText,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: kCardSpacing),

          // IMAGES
          if (booking.orderPictures != null &&
              booking.orderPictures!.isNotEmpty)
            BookingImagesList(
              images: booking.orderPictures!,
              primaryTextColor: primaryText,
            ),

          const SizedBox(height: 10), // Extra bottom padding
        ],
      ),
    );
  }
}
