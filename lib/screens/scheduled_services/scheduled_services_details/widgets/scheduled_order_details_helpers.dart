import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class ScheduledOrderDetailsHelpers {
  static String formatDateTime(DateTime? dt) {
    if (dt == null) return "N/A";
    return DateFormat("dd MMM yyyy, HH:mm").format(dt);
  }

  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case "pending":
        return Colors.orange.shade700;
      case "confirmed":
        return Colors.green.shade700;
      case "in progress":
        return Colors.blue.shade700;
      case "shipped":
        return Colors.teal.shade700;
      case "cancelled":
        return Colors.red.shade700;
      default:
        return Colors.blueGrey;
    }
  }

  static Widget buildStatusBadge(String? status) {
    final statusText =
        (status ?? "UNKNOWN").replaceAll('_', ' ').toUpperCase();
    final statusColor = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  static Widget buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    Color color = Kolors.kDark,
    bool isPrimary = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color:
                  isPrimary ? Kolors.kPrimary : Kolors.kDark.withOpacity(0.7),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            flex: 3,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isPrimary ? Kolors.kPrimary : Kolors.kDark,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(
                color: isPrimary ? Kolors.kPrimary : color,
                fontSize: isPrimary ? 16 : 15,
                fontWeight:
                    isPrimary ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildSectionCard(Widget child) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(padding: const EdgeInsets.all(20), child: child),
    );
  }
}
