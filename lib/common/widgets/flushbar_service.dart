import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class FlushbarService {
  static Flushbar<dynamic>? _currentFlushbar;

  static void dismiss() {
    _currentFlushbar?.dismiss();
    _currentFlushbar = null;
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
    required FlushbarPosition position,
    Duration duration = const Duration(seconds: 3),
  }) {
    dismiss();

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    const navBarHeight = kBottomNavigationBarHeight;

    _currentFlushbar = Flushbar(
      message: message,
      duration: duration,
      icon: Icon(icon, color: Colors.white),
      backgroundColor: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      animationDuration: const Duration(milliseconds: 300),
      flushbarPosition: position,

      /// ✅ Auto-adjust for BottomNavigationBar
      margin: position == FlushbarPosition.BOTTOM
          ? EdgeInsets.fromLTRB(16, 0, 16, navBarHeight + bottomInset + 12)
          : const EdgeInsets.all(16),
    )..show(context);
  }

  /// ✅ SUCCESS
  static void success(
    BuildContext context,
    String message, {
    FlushbarPosition position = FlushbarPosition.TOP,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.green.shade600,
      icon: Icons.check_circle,
      position: position,
      duration: duration,
    );
  }

  /// ⚠️ WARNING
  static void warning(
    BuildContext context,
    String message, {
    FlushbarPosition position = FlushbarPosition.TOP,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.orange.shade700,
      icon: Icons.warning_amber_rounded,
      position: position,
      duration: duration,
    );
  }

  /// ℹ️ INFO
  static void info(
    BuildContext context,
    String message, {
    FlushbarPosition position = FlushbarPosition.TOP,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.blue.shade600,
      icon: Icons.info_outline,
      position: position,
      duration: duration,
    );
  }

  /// ❌ ERROR
  static void error(
    BuildContext context,
    String message, {
    FlushbarPosition position = FlushbarPosition.TOP,
    Duration duration = const Duration(seconds: 4),
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.red.shade700,
      icon: Icons.error_outline,
      position: position,
      duration: duration,
    );
  }
}
