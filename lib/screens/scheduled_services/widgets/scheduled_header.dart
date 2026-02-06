import 'package:flutter/material.dart';

class ScheduledOrdersHeader extends StatelessWidget {
  final bool showHeader;
  const ScheduledOrdersHeader({super.key, required this.showHeader});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: showHeader ? 56 : 0,
        curve: Curves.easeOut,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Scheduled Orders",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
