import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_model.dart';
import 'package:flutter_application_2/common/controller/bookings/session_location_ping_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/session_status_controller.dart';
import 'package:flutter_application_2/common/services/session_by_shipment_api.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_flushbar_widget.dart';
import 'package:flutter_application_2/screens/session/widgets/client_profile_row.dart';
import 'package:flutter_application_2/screens/session/widgets/session_components.dart';
import 'package:flutter_application_2/screens/session/widgets/session_helpers.dart';
import 'package:flutter_application_2/screens/ratings_screen/views/ratings_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class SessionScreen extends StatefulWidget {
  final SessionModel session;
  final String? providerEmail;
  final Position? initialLocation; // First location ping

  const SessionScreen({super.key, required this.session, required this.providerEmail, this.initialLocation});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late Timer _timer;
  Timer? _pingTimer;
  Timer? _pollTimer;
  late Duration _elapsed;

  bool get isCompleted => widget.session.checkoutTime != null;

  @override
  void initState() {
    super.initState();
    _elapsed = Duration(seconds: widget.session.durationSeconds ?? 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
  if (!mounted) return;

  final controller = context.read<SessionLocationPingController>();

  if (widget.initialLocation != null) {
    controller.postPing(
      sessionId: widget.session.sessionId!,
      latitude: widget.initialLocation!.latitude,
      longitude: widget.initialLocation!.longitude,
      accuracy: widget.initialLocation!.accuracy,
      session: widget.session,
      siteLatitude: widget.session.shipment?.serviceOrdered?.order?.deliveryAddress?.latitude ?? 0,
      siteLongitude: widget.session.shipment?.serviceOrdered?.order?.deliveryAddress?.longitude ?? 0,
    );
  }
});


    if (!isCompleted) {
      // Local timer for smooth seconds
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });

      // Ping every 20 seconds
      _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) => _sendPing());

      // Poll backend every 20s
      _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) => _pollSession());
    }
  }

  /// Simple cleanup to stop all timers at once
void _stopAllTimers() {
  _pingTimer?.cancel();
  _timer.cancel();
  _pollTimer?.cancel();
}

/// A professional loading overlay so the user knows the app is "thinking"
void _showLoadingOverlay() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(
      child: CircularProgressIndicator(
        color: Kolors.kPrimary,
        strokeWidth: 3,
      ),
    ),
  );
}






  Future<void> _pollSession() async {
    final shipmentId = widget.session.shipmentId;
    if (shipmentId == null) return;

    try {
      final updatedSession = await SessionApi.getSessionByShipment(shipmentId.toString());
      if (!mounted) return;

      final backendDuration = Duration(seconds: updatedSession.durationSeconds ?? 0);
      if ((backendDuration - _elapsed).inSeconds.abs() > 2) {
        setState(() => _elapsed = backendDuration);
      }
    } catch (e) {
      debugPrint("📡 Polling session failed: $e");
    }
  }

  Future<void> _sendPing() async {
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;

final controller = Provider.of<SessionLocationPingController>(
  context,
  listen: false,
);

      await controller.postPing(
        sessionId: widget.session.sessionId!,
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        session: widget.session,
        siteLatitude: widget.session.shipment?.serviceOrdered?.order?.deliveryAddress?.latitude ?? 0,
        siteLongitude: widget.session.shipment?.serviceOrdered?.order?.deliveryAddress?.longitude ?? 0,
      );
    } catch (e) {
      debugPrint("📍 Ping failed: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pingTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFE),
      appBar: AppBar(
        title: const Text("Current Session",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Kolors.kPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          SessionTimerHeader(elapsed: _elapsed),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SessionInfoCard(
                    title: "Service Details",
                    children: [
                      SessionHelpers.buildDataRow(
                          Icons.fingerprint, "Session ID", "#${widget.session.sessionId}"),
                      const Divider(height: 24, color: Kolors.kOffWhite),
                      SessionHelpers.buildDataRow(
                          Icons.local_shipping_outlined, "Shipment ID", "#${widget.session.shipment?.shipmentId}"),
                          const Divider(height: 24, color: Kolors.kOffWhite),
                          SessionHelpers.buildDataRow(
  Icons.calendar_today_outlined,
  "Check-in Time",
  widget.session.checkinTime != null
      ? DateFormat("dd MMM yyyy-HH:mm").format(
          DateTime.parse(widget.session.checkinTime.toString()).toLocal(),
        )
      : "-",
),
const Divider(height: 24, color: Kolors.kOffWhite),
SessionHelpers.buildDataRow(
  Icons.handyman_outlined,
  "Service Performed",
  widget.session.shipment?.serviceOrdered?.order?.serviceRequired?.serviceName ?? "-",)
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (widget.session.shipment?.serviceOrdered?.order?.client != null)
                    SessionInfoCard(
                      title: "Client Information",
                      children: [
                        ClientProfileRow(
  name:
      "${widget.session.shipment!.serviceOrdered!.order!.client!.firstName} "
      "${widget.session.shipment!.serviceOrdered!.order!.client!.lastName}",
  imageUrl: widget.session.shipment
      ?.serviceOrdered?.order?.client?.profileImageUrl,
  rating: double.tryParse(
  widget.session.shipment
      ?.serviceOrdered?.order?.client?.rating ?? '',
),
),


                        
                      ],
                    ),
                  const SizedBox(height: 40),
                  if (!isCompleted)
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 0,
                        ),
                        onPressed: _handleEndSession,
                        child: const Text("END SESSION",
                            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleEndSession() async {
  // --- STEP 1: Custom Confirmation Dialog ---
  final bool? confirm = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 30),
              ),
              const SizedBox(height: 20),
              const Text(
                "End Session?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Kolors.kDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to finish this session? This will finalize the service and notify the client.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Kolors.kDark.withOpacity(0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        "END NOW",
                        style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (confirm != true) return;

  // --- STEP 2: Logic with Loading State ---
  _showLoadingOverlay(); // Implementation below

  try {
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final success = await context.read<SessionStatusController>().endSession(
          status: 'completed',
          sessionId: widget.session.sessionId!,
          latitude: pos.latitude,
          longitude: pos.longitude,
          accuracy: pos.accuracy,
        );

    if (success && mounted) {
      _stopAllTimers(); // Cleanup helper
      
      // Navigate to ratings
      Navigator.of(context).pop(); // Remove loading overlay
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RatingsScreen(
            providerEmail: widget.session.shipment?.serviceOrdered?.order
                    ?.providerForService?.provider?.spProfile?.emailAddress ?? "",
            sessionId: widget.session.sessionId,
            session: widget.session, 
          ),
        ),
      );
    } else {
       Navigator.of(context).pop(); // Remove loading overlay
       await ScheduleFlushbar.error(
  context,
  "Failed to end session. Please try again.",
);


    }
  } catch (e) {
    Navigator.of(context).pop(); // Remove loading overlay
    debugPrint("❌ End session failed: $e");
  }
}
}
