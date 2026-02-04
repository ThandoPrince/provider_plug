import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class ScheduledOrderDetailsHelpers {
  /// Professional Date Formatter
  static String formatDateTime(DateTime? dt) {
    if (dt == null) return "N/A";
    return DateFormat("dd MMM yyyy, HH:mm").format(dt);
  }

  /// Modern Detail Row with refined typography and spacing
  static Widget buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    Color color = Kolors.kDark,
    bool isPrimary = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPrimary 
                    ? Kolors.kPrimary.withOpacity(0.1) 
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isPrimary ? Kolors.kPrimary : Kolors.kDark.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Kolors.kDark.withOpacity(0.7), // Subtle labels
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isPrimary ? Kolors.kPrimary : color,
                fontSize: isPrimary ? 16 : 14,
                fontWeight: isPrimary ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: isPrimary ? 0.2 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Refined Section Card with Premium Soft Shadows
  static Widget buildSectionCard(Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24), // Modern rounded corners
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10), // Downward shadow for depth
          ),
          BoxShadow(
            color: Kolors.kPrimary.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}