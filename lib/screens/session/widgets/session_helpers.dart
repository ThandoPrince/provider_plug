import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class SessionHelpers {
  static String formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  static Widget buildDataRow(IconData icon, String title, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Icon(icon, size: 18, color: Kolors.kPrimary),
      const SizedBox(width: 12),

      // LEFT LABEL
      Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),

      const SizedBox(width: 12),

      // ⭐ THIS FIXES YOUR OVERFLOW
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.right,
          overflow: TextOverflow.fade,
          maxLines: 2,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    ],
  );
}

}