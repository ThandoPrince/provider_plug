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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize controllers from providers
      _bookingController = Provider.of<SPBookingController>(context, listen: false);
      _locationController = Provider.of<SpLiveLocationPostController>(context, listen: false);

      // Start polling bookings
      _bookingController.startPolling(widget.email);

      // Start sending live location
      _locationController.startTracking(email: widget.email);
    });
  }

  @override
  void dispose() {
    // Stop polling and live tracking safely
    _bookingController.stopPolling();
    _locationController.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Kolors.kPrimary;
    const Color secondaryColor = Kolors.kSecondaryLight;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, secondaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  "Active Bookings",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: HomeBodyWidget(email: widget.email),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
