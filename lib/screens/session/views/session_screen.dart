import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_model.dart';

import 'package:flutter_application_2/common/controller/bookings/session_status_controller.dart';
import 'package:flutter_application_2/common/services/session_by_shipment_api.dart';
import 'package:flutter_application_2/common/services/session_socket_service.dart';
import 'package:flutter_application_2/screens/scheduled_services_details/widgets/schedule_flushbar_widget.dart';
import 'package:flutter_application_2/screens/session/widgets/client_profile_row.dart';

import 'package:flutter_application_2/screens/session/widgets/session_helpers.dart';
import 'package:flutter_application_2/screens/ratings_screen/views/ratings_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class SessionScreen extends StatefulWidget {
  final SessionModel session;
  final SessionSocketService sessionSocket;
  
  final Position? initialLocation;

  const SessionScreen({
    super.key,
    required this.session,
   required this.sessionSocket,
    this.initialLocation,
  });

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late Timer _timer;
Timer? _pollTimer;
  late Duration _elapsed;
  
Timer? _geofenceTimer;
bool _isOutsideGeofence = false;
double? _distanceFromSite;
  bool get isCompleted => widget.session.checkoutTime != null;

  @override
void initState() {
  super.initState();

  _elapsed = Duration(seconds: widget.session.durationSeconds ?? 0);
  widget.sessionSocket.onMessage = _handleSocketMessage;

  widget.sessionSocket.onDisconnected = () {
    debugPrint("Session socket disconnected");
  };

  widget.sessionSocket.onError = (e) {
    debugPrint("Session socket error: $e");
  };

  

    if (!isCompleted) {
  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      if (mounted) {
        setState(() => _elapsed += const Duration(seconds: 1));
      }
    },
  );

  _pollTimer = Timer.periodic(
    const Duration(seconds: 20),
    (_) => _pollSession(),
  );

  _geofenceTimer = Timer.periodic(
    const Duration(seconds: 20),
    (_) => _sendGeofencePing(),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _sendGeofencePing(); // first ping immediately
  });
}
  }


  void _handleSocketMessage(Map<String, dynamic> message) {
  switch (message["type"]) {
    case "geofence_ping_ack":
      final data = message["data"] as Map<String, dynamic>? ?? {};

      final inside = data["inside_geofence"] == true;
      final distance =
          (data["distance_from_site_meters"] as num?)?.toDouble();

      debugPrint(
          "ACK -> inside=$inside distance=$distance");

      if (!mounted) return;

      setState(() {
        _isOutsideGeofence = !inside;
        _distanceFromSite = inside ? null : distance;
      });

      break;
  }
}

  Future<void> _sendGeofencePing() async {
  try {
    if (!widget.sessionSocket.isConnected) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    widget.sessionSocket.sendGeofencePing(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
    );
  } catch (e) {
    debugPrint("❌ Failed to send geofence ping: $e");
  }
}

  void _stopAllTimers() {
  _timer.cancel();
  _pollTimer?.cancel();
  _geofenceTimer?.cancel();
}
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

  


  @override
  void dispose() {
    _stopAllTimers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark Theme Background
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text(
          "ACTIVE SESSION",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 2, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildLiveTimerHeader(),
          if (_isOutsideGeofence)
    _buildGeofenceWarning(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA), // Professional Off-white Sheet
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel("JOB DETAILS"),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      child: Column(
                        children: [
                          _buildDetailRow(Icons.fingerprint, "Session ID", "#${widget.session.sessionId}"),
                          _buildDivider(),
                          _buildDetailRow(Icons.local_shipping_outlined, "Shipment ID", "#${widget.session.shipment?.shipmentId}"),
                          _buildDivider(),
                          _buildDetailRow(Icons.calendar_today_outlined, "Check-in Time", 
                            widget.session.checkinTime != null 
                            ? DateFormat("dd MMM yyyy - HH:mm").format(DateTime.parse(widget.session.checkinTime.toString()).toLocal())
                            : "-"),
                          _buildDivider(),
                          _buildDetailRow(Icons.handyman_outlined, "Service", widget.session.shipment?.serviceOrdered?.order?.serviceRequired?.serviceName ?? "-"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (widget.session.shipment?.serviceOrdered?.order?.client != null) ...[
                      _buildSectionLabel("CLIENT INFORMATION"),
                      const SizedBox(height: 12),
                      _buildInfoCard(
                        child: ClientProfileRow(
                          name: "${widget.session.shipment!.serviceOrdered!.order!.client!.firstName} ${widget.session.shipment!.serviceOrdered!.order!.client!.lastName}",
                          imageUrl: widget.session.shipment?.serviceOrdered?.order?.client?.profileImageUrl,
                          rating: double.tryParse(widget.session.shipment?.serviceOrdered?.order?.client?.rating ?? ''),
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                    if (!isCompleted) _buildEndSessionButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI HELPER METHODS ---


  Widget _buildGeofenceWarning() {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red.shade700,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: Colors.white,
          size: 30,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "You are outside the service area",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _distanceFromSite == null
                    ? "Please return to the client's location."
                    : "You are ${_distanceFromSite!.toStringAsFixed(1)} m away from the service location.",
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildLiveTimerHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 40, top: 10),
      child: Column(
        children: [
          Text(
            "TIME ELAPSED",
            style: TextStyle(color: Kolors.kOffWhite.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            SessionHelpers.formatDuration(_elapsed),
            style: const TextStyle(
              color: Kolors.kOffWhite,
              fontSize: 52,
              fontWeight: FontWeight.w200,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Text("LIVE TRACKING ACTIVE", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: const TextStyle(color: Kolors.kDark, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2));
  }

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Kolors.kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Kolors.kPrimary, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              Text(value, style: const TextStyle(color: Kolors.kDark, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDivider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Divider(color: Colors.grey.withOpacity(0.08), height: 1),
      );

  Widget _buildEndSessionButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(colors: [Colors.redAccent, Color(0xFFD32F2F)]),
        boxShadow: [
          BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () {
          HapticFeedback.heavyImpact();
          _handleEndSession();
        },
        child: const Text("END SESSION", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white)),
      ),
    );
  }

  Future<void> _handleEndSession() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 60, width: 60,
                  decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                  child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 30),
                ),
                const SizedBox(height: 20),
                const Text("End Session?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Kolors.kDark)),
                const SizedBox(height: 12),
                Text(
                  "Are you sure you want to finish this session? This will finalize the service and notify the client.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Kolors.kDark.withOpacity(0.6), height: 1.5),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("CANCEL", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("END NOW", style: TextStyle(fontWeight: FontWeight.w900)),
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

    _showLoadingOverlay();

    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final success = await context.read<SessionStatusController>().endSession(
            status: 'completed',
            sessionId: widget.session.sessionId!,
            latitude: pos.latitude,
            longitude: pos.longitude,
            accuracy: pos.accuracy,
          );

      if (success && mounted) {
  _stopAllTimers();

  // Disconnect the session websocket permanently before leaving.
  await widget.sessionSocket.disconnect();

  Navigator.of(context).pop(); // Pop loading

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => RatingsScreen(
        providerEmail: widget.session.shipment
                ?.serviceOrdered
                ?.order
                ?.providerForService
                ?.provider
                ?.spProfile
                ?.emailAddress ??
            "",
        sessionId: widget.session.sessionId,
        session: widget.session,
      ),
    ),
  );
} else {
        Navigator.of(context).pop(); // Pop loading
        await ScheduleFlushbar.error(context, "Failed to end session. Please try again.");
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      debugPrint("❌ End session failed: $e");
    }
  }
}