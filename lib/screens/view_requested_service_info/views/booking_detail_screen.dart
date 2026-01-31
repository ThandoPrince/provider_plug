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
  late final ScrollController _scrollController;
  bool _showHeader = true;
  double _lastOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        final offset = _scrollController.offset;

        if (offset > _lastOffset && _showHeader) {
          // scrolling down → hide header
          setState(() => _showHeader = false);
        } else if (offset < _lastOffset && !_showHeader) {
          // scrolling up → show header
          setState(() => _showHeader = true);
        }

        _lastOffset = offset;
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              // ✅ Animated header instead of AppBar
              ClipRect(
                child: AnimatedAlign(
                  alignment: Alignment.centerLeft,
                  duration: const Duration(milliseconds: 200),
                  heightFactor: _showHeader ? 1 : 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Text(
                        "Order Details",
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

              // Expanded content
              Expanded(
                child: Consumer<BookingByOrderIDController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Colors.white));
                    }

                    if (controller.errorMessage != null) {
                      return Center(
                        child: Text(
                          controller.errorMessage!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
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
                      controller: _scrollController,
                      
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
    );
  }
}
