import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';
import 'package:intl/intl.dart';

String formatDateTime(DateTime? dt) {
  if (dt == null) return "N/A";
  return DateFormat("dd MMM yyyy, HH:mm").format(dt);
}

Color getStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case "pending":
      return Colors.orange.shade700;
    case "delivered":
      return Colors.green.shade700;
    case "cancelled":
      return Colors.red.shade700;
    case "in_transit":
      return Kolors.kPrimary;
    case "arrived":
      return Colors.purple.shade700;
    case "in_session":
      return Colors.blue.shade700;
    default:
      return Colors.blueGrey;
  }
}

String displayStatus(String? status) {
  return (status ?? "UNKNOWN").replaceAll('_', ' ').toUpperCase();
}
