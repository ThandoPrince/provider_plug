import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/controller/bookings/session_location_ping_controller.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:provider/provider.dart';
import 'session_helpers.dart';

class SessionTimerHeader extends StatelessWidget {
  final Duration elapsed;
  const SessionTimerHeader({super.key, required this.elapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF121212), // Deep dark to match screen background
      ),
      child: Column(
        children: [
          Text(
            "TIME ELAPSED",
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            SessionHelpers.formatDuration(elapsed),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 54,
              fontWeight: FontWeight.w200,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 20),
          const GeofenceStatusBadge(),
        ],
      ),
    );
  }
}

class GeofenceStatusBadge extends StatelessWidget {
  const GeofenceStatusBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionLocationPingController>(
      builder: (_, controller, __) {
        final inside = controller.isInsideGeofence;
        final distance = controller.distanceMeters?.toStringAsFixed(0) ?? "-";
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: inside 
                ? Colors.greenAccent.withOpacity(0.1) 
                : Colors.redAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: inside ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulse effect could be added here later
              Icon(Icons.location_on, 
                color: inside ? Colors.greenAccent : Colors.redAccent, 
                size: 14),
              const SizedBox(width: 8),
              Text(
                inside ? "ON-SITE" : "OFF-SITE",
                style: TextStyle(
                  color: inside ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: VerticalDivider(
                  width: 1, 
                  thickness: 1, 
                  color: (inside ? Colors.greenAccent : Colors.redAccent).withOpacity(0.3)
                ),
              ),
              Text(
                "$distance m",
                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SessionInfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SessionInfoCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: Kolors.kDark,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}