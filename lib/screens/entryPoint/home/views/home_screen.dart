import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/bookings_by_email_controller.dart';
import 'package:flutter_application_2/common/controller/sp_live_location_controller.dart';
import 'package:flutter_application_2/screens/entryPoint/home/widgets/home_body_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class HomeScreen extends StatefulWidget {
  final String email; // Provider email
  const HomeScreen({super.key, required this.email});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SPBookingController _bookingController;
  late SpLiveLocationPostController _locationController;

  // Track whether header is visible
  bool _showHeader = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bookingController = Provider.of<SPBookingController>(context, listen: false);
      _locationController = Provider.of<SpLiveLocationPostController>(context, listen: false);

      _bookingController.startPolling(widget.email);
      _locationController.startTracking(email: widget.email);
    });
  }

  @override
  void dispose() {
    _bookingController.stopPolling();
    _locationController.stopTracking();
    super.dispose();
  }

  // Called on scroll
  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      // Hide header if user scrolls down, show if scroll up
      if (notification.scrollDelta! > 0 && _showHeader) {
        setState(() => _showHeader = false);
      } else if (notification.scrollDelta! < 0 && !_showHeader) {
        setState(() => _showHeader = true);
      }
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Let the EntryPoint gradient show through
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Animated Header ---
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showHeader ? 80 : 0,
              curve: Curves.easeInOut,
              child: SingleChildScrollView( // Prevents overflow during animation
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Active Bookings",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: Colors.white,
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),

            // --- Main Body ---
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  _onScroll(notification);
                  return false;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Kolors.kOffWhite.withOpacity(0.05), // Subtle floor
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: HomeBodyWidget(email: widget.email),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}   

