import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/session_location_ping_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:provider/provider.dart';
import 'session_helpers.dart';

/// The large blue header showing the clock
class SessionTimerHeader extends StatelessWidget {
  final Duration elapsed;
  const SessionTimerHeader({super.key, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      decoration: const BoxDecoration(
        color: Kolors.kPrimary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Text("ELAPSED TIME", 
            style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w800, letterSpacing: 1.5, fontSize: 11)),
          const SizedBox(height: 8),
          Text(
            SessionHelpers.formatDuration(elapsed),
            style: const TextStyle(color: Colors.white, fontSize: 58, fontWeight: FontWeight.w200, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 16),

          // ✅ Geofence badge listens to controller automatically
          Consumer<SessionLocationPingController>(
            builder: (_, controller, __) {
              final inside = controller.isInsideGeofence;
              final distance = controller.distanceMeters?.toStringAsFixed(1) ?? "-";
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: inside ? Colors.greenAccent : Colors.redAccent, size: 10),
                    const SizedBox(width: 8),
                    Text(
                      inside ? "ON-SITE ($distance m)" : "OFF-SITE ($distance m)",
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
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
}


/// The Pill-shaped status indicator
class GeofenceStatusBadge extends StatelessWidget {
  const GeofenceStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionLocationPingController>(
      builder: (_, controller, __) {
        final inside = controller.isInsideGeofence;
        final distance = controller.distanceMeters?.toStringAsFixed(1) ?? "-";
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: inside ? Colors.greenAccent : Colors.redAccent, size: 10),
              const SizedBox(width: 8),
              Text(
                inside ? "ON-SITE ($distance m)" : "OFF-SITE ($distance m)",
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Generic container for the Info Cards
class SessionInfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SessionInfoCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), 
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey.shade500, letterSpacing: 1.2)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}