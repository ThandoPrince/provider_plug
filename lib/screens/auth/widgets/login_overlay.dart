import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class SuccessOverlay {
  static void show(BuildContext context, {required String message}) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            decoration: const BoxDecoration(
              color: Kolors.kDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(35),
                topRight: Radius.circular(35),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle Bar
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),

                const SizedBox(height: 30),

                // Animated Checkmark
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  tween: Tween(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green.withOpacity(0.25),
                          ),
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green.shade400,
                          size: 90,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  "Access Granted!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.75),
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Kolors.kPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Redirecting...",
                      style: TextStyle(
                        color: Kolors.kPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}