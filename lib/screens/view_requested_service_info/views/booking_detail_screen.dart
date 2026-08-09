import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/remove_invitation_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/order_service_model.dart';
import 'package:flutter_application_2/common/widgets/app_confirmation_dialog.dart';
import 'package:flutter_application_2/common/widgets/flushbar_service.dart';
import 'package:flutter_application_2/screens/client_details_screen.dart/views/client_details_screen.dart';
import 'package:flutter_application_2/screens/view_requested_service_info/widgets/booking_detail_content.dart';
import 'package:provider/provider.dart';


import 'package:flutter_application_2/common/utils/kcolors.dart';

class BookingDetailScreen extends StatefulWidget {
  final OrderService booking;
  const BookingDetailScreen({super.key, required this.booking});

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

  Future<void> _cancelBooking(OrderService booking) async {
  final controller = context.read<RemoveInvitationController>();

  final confirm = await showDialog<bool>(
  context: context,
  barrierDismissible: false,
  builder: (_) => const AppConfirmationDialog(
    icon: Icons.cancel_presentation_rounded,
    iconColor: Colors.redAccent,
    title: "Decline Order",
    message:
        "Are you sure you want to decline this order?\n\n"
        "This action cannot be undone.",
    confirmText: "Decline",
    cancelText: "Keep Order",
    confirmColor: Colors.red,
  ),
);



  if (confirm != true) return;

  final success = await controller.removeInvitation(
    orderId: booking.orderId!,
  );

  if (!mounted) return;

  if (success) {
  FlushbarService.success(
    context,
    "Order declined successfully.",
  );

  Future.delayed(const Duration(milliseconds: 300), () {
    if (mounted) {
      Navigator.of(context).pop();
    }
  });
} else {
    FlushbarService.error(
      context,
      controller.errorMessage ?? "Unable to cancel order.",
    );
  }
}

void _viewClientDetails(OrderService booking) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ClientDetailsScreen(
        booking: booking,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
   

    return Scaffold(
      backgroundColor: primaryColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _onScroll(notification);
          return false;
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Kolors.kPrimary, Color(0xFF1A1A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              
              SafeArea(
                bottom: false,
                child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: _showHeader ? 56 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
    const Expanded(
      child: Text(
        "Order Details",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    ),
    
    AnimatedSlide(
  duration: const Duration(milliseconds: 220),
  offset: _showHeader ? Offset.zero : const Offset(0.3, 0),
  child: AnimatedOpacity(
    duration: const Duration(milliseconds: 220),
    opacity: _showHeader ? 1 : 0,
    child: IgnorePointer(
      ignoring: !_showHeader,
      child: PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_vert,
          color: Colors.white,
        ),
        color: Colors.white,
        onSelected: (value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            switch (value) {
              case 'client':
                _viewClientDetails(widget.booking);
                break;

              case 'cancel':
                _cancelBooking(widget.booking);
                break;
            }
          });
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: 'client',
            child: ListTile(
              leading: Icon(Icons.person_outline),
              title: Text("View Client Details"),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: 'cancel',
            child: ListTile(
              leading: Icon(
                Icons.cancel_outlined,
                color: Colors.red,
              ),
              title: Text("Cancel Order"),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    ),
  ),
),
        ],
      ),
    ),
              ),
    
              
              Expanded(
  child: SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: BookingDetailContent(
      booking: widget.booking,
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
