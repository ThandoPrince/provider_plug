import 'package:flutter/material.dart';
import 'package:flutter_application_2/screens/view_requested_service_info/widgets/booking_detail_content.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/common/controller/bookings/booking_by_orderID_controller.dart';

import 'package:flutter_application_2/common/utils/kcolors.dart';

class BookingDetailScreen extends StatefulWidget {
  final int orderId;
  const BookingDetailScreen({super.key, required this.orderId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
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
    const Color primaryColor = Kolors.kPrimary;
    const Color secondaryColor = Kolors.kSecondaryLight;

    return ChangeNotifierProvider(
      create: (_) =>
          BookingByOrderIDController()..fetchBookingByOrderID(widget.orderId),
      child: Scaffold(
        backgroundColor: primaryColor,
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            _onScroll(notification);
            return false;
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // ✅ COLLAPSING HEADER
                SafeArea(
                  bottom: false,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: _showHeader ? 56 : 0,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      "Order Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),

                // ✅ CONTENT
                Expanded(
                  child: Consumer<BookingByOrderIDController>(
                    builder: (context, controller, _) {
                      if (controller.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      if (controller.errorMessage != null) {
                        return Center(
                          child: Text(
                            controller.errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 16),
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

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: BookingDetailContent(
                          booking: controller.booking!,
                        ),
                      );
                    },
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
