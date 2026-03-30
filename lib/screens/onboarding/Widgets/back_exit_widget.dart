import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleBackToExit extends StatefulWidget {
  final Widget child;
  final Duration interval;
  final String message;

  const DoubleBackToExit({
    super.key,
    required this.child,
    this.interval = const Duration(seconds: 2),
    this.message = "Press back again to exit",
  });

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  DateTime? _lastBackPressed;

  void _showExitWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        backgroundColor: const Color(0xFF333333), // Darker grey to match your theme
        behavior: SnackBarBehavior.floating,
        duration: widget.interval,
        // Aligns with your SPLoginScreen SnackBar positioning
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 160,
          left: 50,
          right: 50,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // Pill shape looks better for short alerts
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents immediate exit
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final now = DateTime.now();
        final isWarningStillValid = _lastBackPressed != null &&
            now.difference(_lastBackPressed!) < widget.interval;

        if (isWarningStillValid) {
      
          SystemNavigator.pop();
        } else {
          // First tap: Update time and show warning
          _lastBackPressed = now;
          _showExitWarning();
        }
      },
      child: widget.child,
    );
  }
}