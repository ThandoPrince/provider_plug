import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/session_location_ping_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_by_id_controller.dart';
import 'package:flutter_application_2/common/controller/bookings/shipment_controller.dart';
import 'package:flutter_application_2/common/services/confirm_session_api.dart';
import 'package:flutter_application_2/common/services/session_by_shipment_api.dart';
import 'package:flutter_application_2/common/services/session_socket_service.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/widgets/session_live_location_helper.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/widgets/header_widget.dart';
import 'package:flutter_application_2/screens/scan_session_qr_code/widgets/laser_overlay_widget.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_flushbar_widget.dart';
import 'package:flutter_application_2/screens/session/views/session_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

class SessionInitiationQrScreen extends StatefulWidget {
  final int shipmentId;
  final SessionSocketService sessionSocket;
 

  const SessionInitiationQrScreen({
    super.key,
    required this.shipmentId,
    required this.sessionSocket,
   
  });

  @override
  State<SessionInitiationQrScreen> createState() =>
      _SessionInitiationQrScreenState();
}

class _SessionInitiationQrScreenState extends State<SessionInitiationQrScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final MobileScannerController cameraController = MobileScannerController();

  bool _isProcessingScan = false;

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
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (_isProcessingScan) return;

              final barcode = capture.barcodes.first;
              final rawValue = barcode.rawValue;
              if (rawValue == null || rawValue.trim().isEmpty) return;

              _isProcessingScan = true;
              await cameraController.stop();

              final bool confirmed = await _showScanConfirmationDialog(context);

              if (!mounted) return;

              if (!confirmed) {
                _isProcessingScan = false;
                await cameraController.start();
                return;
              }

              await _confirmCheckin(context, rawValue);
              _isProcessingScan = false;
            },
          ),
          QrOverlay(animation: _animationController),
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

  Future<bool> _showScanConfirmationDialog(BuildContext context) async {
    final shipmentByIdCtrl = context.read<ShipmentByIdController>();
    final shipment = await shipmentByIdCtrl.fetchShipmentById(widget.shipmentId);

    final order = shipment?.serviceOrdered?.order;
    final String amount = order?.finalPrice?.toString() ??
        order?.proposalPrice?.toString() ??
        order?.basePrice?.toString() ??
        '0.00';

    if (!mounted) return false;

    final bool? result = await showDialog(
  context: context,
  builder: (dialogContext) => BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Blurs the background for a premium feel
    child: AlertDialog(
      backgroundColor: const Color(0xFF1A1A1A), // Deep charcoal surface
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28.r),
        side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1), // Subtle border
      ),
      title: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Kolors.kPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.qr_code_scanner_rounded, color: Kolors.kPrimary, size: 28.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            "Confirm QR Scan",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(color: Colors.white70, fontSize: 13.sp, height: 1.5),
              children: [
                const TextSpan(
                  text: "Are you sure you want to scan this QR code?\n\n",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const TextSpan(
                  text: "By continuing, you agree to the terms and conditions for starting this session.",
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          // --- THE ACCENT AMOUNT CARD ---
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Kolors.kPrimary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Booking Amount: ",
                  style: TextStyle(color: Colors.white54, fontSize: 12.sp),
                ),
                Text(
                  "R$amount",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Kolors.kPrimary,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Kolors.kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  "Proceed",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);

    return result ?? false;
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
    final location = await CheckinLocationService.getCurrentLocation();

    final locationPayload = {
      "latitude": location.latitude,
      "longitude": location.longitude,
      "accuracy": location.accuracy,
    };

    final response = await ConfirmSessionApi.post(
      Uri.parse(
        "${dotenv.env['API_BASE_URL']}/bookings/sessions/confirm_checkin/",
      ),
      body: jsonEncode({
        "checkin_token": token,
        "checkin_location": locationPayload,
      }),
    );

    final Map<String, dynamic> data =
        response.body.isNotEmpty
            ? Map<String, dynamic>.from(jsonDecode(response.body))
            : {};

    if (response.statusCode != 200) {
      throw data["detail"] ?? "Invalid QR code";
    }

    final shipmentId =
        data["shipment"]["shipment_id"].toString();

    final session =
        await SessionApi.getSessionByShipment(shipmentId);

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    try {
      final shipmentCtrl =
          context.read<ShipmentController>();

      await shipmentCtrl.fetchShipments(
        
      );
    } catch (e) {
      debugPrint(
        "⚠️ Shipment refresh failed after check-in: $e",
      );
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => SessionScreen(
          session: session,
          initialLocation: location,
          sessionSocket: widget.sessionSocket,
          
        ),
      ),
      (route) => route.isFirst,
    );
  } catch (e) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    await cameraController.start();

    if (!mounted) return;

    ScheduleFlushbar.error(
      context,
      "Check-in failed: ${e.toString()}",
    );
  }
}
}