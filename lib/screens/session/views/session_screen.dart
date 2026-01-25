import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/session_location_ping_controller.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/session_model.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class SessionScreen extends StatefulWidget {
  final SessionModel session;

  const SessionScreen({super.key, required this.session});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late Timer _timer;
  Timer? _pingTimer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Initialize elapsed time
    _elapsed = Duration(
      seconds: widget.session.checkinTime != null
          ? DateTime.now().difference(widget.session.checkinTime!).inSeconds
          : 0,
    );

    // Start session timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });

    // Start posting location pings
    _startLocationPings();
  }

  Future<void> _startLocationPings() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint("📍 Location permission denied");
      return; // Stop if no permission
    }

    _pingTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _sendPing(),
    );
  }

  Future<void> _sendPing() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final controller = context.read<SessionLocationPingController>();

      await controller.postPing(
        sessionId: widget.session.sessionId!,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );

      // Optional: print for debug
      debugPrint(
        "📍 Ping sent | Inside geofence: ${controller.isInsideGeofence} | Distance: ${controller.distanceMeters?.toStringAsFixed(2)}m",
      );
    } catch (e) {
      debugPrint("📍 Location ping failed: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pingTimer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final shipment = session.shipment;

    return WillPopScope(
      onWillPop: () async {
        _pingTimer?.cancel();
        _timer.cancel();
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("Active Session",
              style: TextStyle(fontWeight: FontWeight.w900)),
          centerTitle: true,
          backgroundColor: Kolors.kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {},
            )
          ],
        ),
        body: shipment == null
            ? const Center(child: Text("No shipment data available"))
            : Column(
                children: [
                  // Timer Hero Section
                  _buildTimerHeader(),

                  // Scrollable Details
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Service Details"),
                          _buildShipmentCard(shipment),
                          const SizedBox(height: 24),
                          _buildSectionTitle("Client Information"),
                          _buildClientCard(shipment),
                          const SizedBox(height: 24),
                          _buildGeofenceStatus(),
                          const SizedBox(height: 24),

                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              onPressed: () {
                                _pingTimer?.cancel();
                                _timer.cancel();
                                Navigator.pop(context, true);
                              },
                              child: const Text("END SESSION",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // Timer Header
  Widget _buildTimerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: const BoxDecoration(
        color: Kolors.kPrimary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const Text(
            "TOTAL ELAPSED TIME",
            style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            formatDuration(_elapsed),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 54,
              fontWeight: FontWeight.w300,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 12),
          Consumer<SessionLocationPingController>(
            builder: (_, controller, __) {
              final inside = controller.isInsideGeofence;
              final distance = controller.distanceMeters?.toStringAsFixed(2) ?? "-";
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fiber_manual_record,
                        color: inside ? Colors.greenAccent : Colors.redAccent,
                        size: 12),
                    const SizedBox(width: 8),
                    Text(
                      inside
                          ? "Inside Geofence ($distance m)"
                          : "Outside Geofence ($distance m)",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGeofenceStatus() {
    return Consumer<SessionLocationPingController>(
  builder: (_, controller, __) {
    final inside = controller.isInsideGeofence;
    final distance = controller.distanceMeters != null
    ? controller.distanceMeters!.toStringAsFixed(2)
    : "-";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fiber_manual_record,
              color: inside ? Colors.greenAccent : Colors.redAccent,
              size: 12),
          const SizedBox(width: 8),
          Text(
            inside
                ? "Inside Geofence ($distance m)"
                : "Outside Geofence ($distance m)",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  },
);

  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Colors.grey.shade600,
            letterSpacing: 1),
      ),
    );
  }

  Widget _buildShipmentCard(Shipment shipment) {
    return _infoContainer(
      child: Column(
        children: [
          _dataRow(Icons.fingerprint, "Session ID", "#${widget.session.sessionId}"),
          const Divider(height: 24),
          _dataRow(Icons.local_shipping_outlined, "Shipment ID", "#${shipment.shipmentId}"),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildClientCard(Shipment shipment) {
    final client = shipment.serviceOrdered?.order?.client;
    if (client == null) return const Text("No Client Info");

    return _infoContainer(
      child: Column(
        children: [
          _dataRow(Icons.person_outline, "Name",
              "${client.firstName} ${client.lastName}"),
          const SizedBox(height: 12),
          _dataRow(Icons.email_outlined, "Email",
              client.clientProfile?.emailAddress ?? 'N/A'),
          const SizedBox(height: 12),
          _dataRow(Icons.phone_android, "Mobile",
              client.clientProfile?.mobileNumber ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _infoContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _dataRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Kolors.kPrimary),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF263238))),
      ],
    );
  }
}
