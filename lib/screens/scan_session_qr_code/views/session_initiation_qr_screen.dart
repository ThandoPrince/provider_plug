import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/session_location_ping_controller.dart';
import 'package:flutter_application_2/common/services/confirm_session_api.dart';
import 'package:flutter_application_2/common/services/session_by_shipment_api.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/session_confirmation/views/session_confirmation_screen.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/widgets/session_live_location_helper.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/widgets/header_widget.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/widgets/laser_overlay_widget.dart';
import 'package:flutter_application_2/screens/session/views/session_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';


class SessionInitiationQrScreen extends StatefulWidget {
  final int shipmentId;

  const SessionInitiationQrScreen({super.key, required this.shipmentId});

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

    // ✅ Confirm the session token
    final response = await ConfirmSessionApi.post(
      "/bookings/sessions/confirm_checkin/",
      body: {
        "checkin_token": token,
        "checkin_location": location,
      },
    );

    if (response.statusCode != 200) {
      throw response.data["detail"] ?? "Invalid QR code";
    }

    // ✅ Fetch the session after confirmation
    final shipmentId = response.data['shipment']['shipment_id'].toString();
    final session = await SessionApi.getSessionByShipment(shipmentId);

    Navigator.pop(context); // close loader

    
    final confirmed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
    builder: (_) => ChangeNotifierProvider(
      create: (_) => SessionLocationPingController(),
      child: SessionScreen(session: session),
    ),
  ),
    );

    if (confirmed == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text("Session confirmed successfully"),
        ),
      );
      Navigator.pop(context, true);
    } else {
      cameraController.start(); 
    }
  } catch (e) {
    if (Navigator.canPop(context)) Navigator.pop(context);

    cameraController.start();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text("Check-in failed: $e"),
      ),
    );
  }
}




}
