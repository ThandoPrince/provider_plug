import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showTopNotification(BuildContext context, String message, {bool isError = false}) {
Flushbar(
  message: 'Round sent successfully!',
  duration: const Duration(seconds: 2),
  margin: const EdgeInsets.all(8),
  borderRadius: BorderRadius.circular(12),
  backgroundColor: Colors.green,
  flushbarPosition: FlushbarPosition.TOP,
  animationDuration: const Duration(milliseconds: 300),
).show(context);
}