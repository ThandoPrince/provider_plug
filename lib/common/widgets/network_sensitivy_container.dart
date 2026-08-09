import 'package:cross_connectivity/cross_connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class SensitiveContainer extends StatelessWidget {
  const SensitiveContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConnectivityBuilder(
      builder: (context, isConnected, status) {
        final connected = isConnected ?? true;

        return Stack(
          children: [
            // 1. Main UI
            child,

            // 2. HARD BLOCKER (prevents all interaction)
            if (!connected)
              const Positioned.fill(
                child: _InputBlocker(),
              ),

            // 3. Status banner (UI feedback)
            if (!connected)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: StatusBanner(
                  message: "You are offline. Interaction is disabled.",
                  icon: Ionicons.wifi_outline,
                  actionLabel: "RETRY",
                ),
              ),
          ],
        );
      },
    );
  }
}
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.message,
    required this.icon,
    required this.actionLabel,
  });

  final String message;
  final IconData icon;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.shade700,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
class _InputBlocker extends StatelessWidget {
  const _InputBlocker();

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: Container(
        color: Colors.transparent,

        // optional: slight dim to signal locked state
        child: ColoredBox(
          color: Colors.black.withOpacity(0.03),
        ),
      ),
    );
  }
}