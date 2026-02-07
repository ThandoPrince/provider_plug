import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';


class ScheduleFlushbar {
  /// 🔥 Simple message
  static Future<void> show(
    BuildContext context, {
    required String message,
    IconData icon = Icons.info_outline,
    Color? color,
    Duration duration = const Duration(seconds: 3),
  }) async {
    await Flushbar(
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      icon: Icon(icon, color: Colors.white),
      duration: duration,
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(14),
      backgroundColor: color ?? Kolors.kPrimary,
      flushbarPosition: FlushbarPosition.TOP,
      animationDuration: const Duration(milliseconds: 400),
    ).show(context);
  }

  /// ✅ Success style
  static Future<void> success(BuildContext context, String message) {
    return show(
      context,
      message: message,
      icon: Icons.check_circle,
      color: Colors.green,
    );
  }

  /// ❌ Error style
  static Future<void> error(BuildContext context, String message) {
    return show(
      context,
      message: message,
      icon: Icons.error_outline,
      color: Colors.redAccent,
    );
  }

  /// ⚠️ Warning style
  static Future<void> warning(BuildContext context, String message) {
    return show(
      context,
      message: message,
      icon: Icons.warning_amber_rounded,
      color: Colors.orange,
    );
  }
}
