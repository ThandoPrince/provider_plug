import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/Session_model.dart';
import 'package:flutter_application_2/common/models/models/order_service_models/shipment_model.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class SessionScreen extends StatefulWidget {
  final SessionModel session;

  const SessionScreen({super.key, required this.session});

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _elapsed = Duration(
      seconds: widget.session.checkinTime != null
          ? DateTime.now().difference(widget.session.checkinTime!).inSeconds
          : 0,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed += const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Active Session", style: TextStyle(fontWeight: FontWeight.w900)),
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
                // 1. Timer Hero Section
                _buildTimerHeader(),

                // 2. Scrollable Details
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

                       
                       

                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              // End session logic
                            },
                            child: const Text("END SESSION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            formatDuration(_elapsed),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 54,
              fontWeight: FontWeight.w300,
              fontFamily: 'Courier', // Gives it a digital clock feel
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fiber_manual_record, color: Colors.greenAccent, size: 12),
                SizedBox(width: 8),
                Text("Session in Progress", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade600, letterSpacing: 1),
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
          _dataRow(Icons.person_outline, "Name", "${client.firstName} ${client.lastName}"),
          const SizedBox(height: 12),
          _dataRow(Icons.email_outlined, "Email", client.clientProfile?.emailAddress ?? 'N/A'),
          const SizedBox(height: 12),
          _dataRow(Icons.phone_android, "Mobile", client.clientProfile?.mobileNumber ?? 'N/A'),
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
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
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
        Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF263238))),
      ],
    );
  }
}