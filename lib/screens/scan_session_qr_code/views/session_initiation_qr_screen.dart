import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/session_location_ping_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/services/confirm_session_api.dart';
import 'package:flutter_application_2/common/services/session_by_shipment_api.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/widgets/session_live_location_helper.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/widgets/header_widget.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/widgets/laser_overlay_widget.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_flushbar_widget.dart';
import 'package:flutter_application_2/screens/session/views/session_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class SessionInitiationQrScreen extends StatefulWidget {
  final int shipmentId;
  final String? providerEmail;
  const SessionInitiationQrScreen({super.key, required this.shipmentId, required this.providerEmail});
  

  @override
  State<SessionInitiationQrScreen> createState() => _SessionInitiationQrScreenState();
}

class _SessionInitiationQrScreenState extends State<SessionInitiationQrScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              final barcode = capture.barcodes.first;
              final rawValue = barcode.rawValue;
              if (rawValue == null) return;

              cameraController.stop();
              await _confirmCheckin(context, rawValue);
            },
          ),

          // Overlay
          QrOverlay(animation: _animationController),

          // Header
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: QrHeader(controller: cameraController),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCheckin(BuildContext context, String token) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Kolors.kPrimary),
      ),
    );

    try {
      // 📍 Get current location
      final location = await CheckinLocationService.getCurrentLocation();

      final locationPayload = {
        "latitude": location.latitude,
        "longitude": location.longitude,
        "accuracy": location.accuracy,
      };

      // ✅ Confirm session token
      final response = await ConfirmSessionApi.post(
        "/bookings/sessions/confirm_checkin/",
        body: {
          "checkin_token": token,
          "checkin_location": locationPayload,
        },
      );

      if (response.statusCode != 200) {
        throw response.data["detail"] ?? "Invalid QR code";
      }

      // ✅ Fetch session
      final shipmentId = response.data['shipment']['shipment_id'].toString();
      final session = await SessionApi.getSessionByShipment(shipmentId);

      Navigator.pop(context); // close loader

      try {
  final shipmentCtrl = context.read<ShipmentController>();
  if (shipmentCtrl.shipments.isNotEmpty) {
    await shipmentCtrl.fetchShipments(widget.providerEmail ?? "" );
  }
} catch (e) {
  debugPrint("⚠️ Shipment refresh failed after check-in: $e");
}

      // ⚡ Provide controller via Provider
      final controller = context.read<SessionLocationPingController>();

Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (_) => SessionScreen(
      session: session,
      initialLocation: location,
      providerEmail: widget.providerEmail,
    ),
  ),
  (route) => route.isFirst,
);

    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      cameraController.start();
      ScheduleFlushbar.error(context, "Check-in failed: ${e.toString()}");
    }
  }
}
