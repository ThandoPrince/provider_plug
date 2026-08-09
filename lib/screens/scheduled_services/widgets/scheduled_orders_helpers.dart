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

    case "in_transit":
      return Colors.blue.shade700;

    case "arrived":
      return Colors.teal.shade600;

    case "in_session":
      return Colors.indigo.shade700;

    case "delivered":
      return Colors.green.shade700;

    default:
      return Colors.blueGrey;
  }
}

String displayStatus(String? status) {
  return (status ?? "UNKNOWN").replaceAll('_', ' ').toUpperCase();
}
