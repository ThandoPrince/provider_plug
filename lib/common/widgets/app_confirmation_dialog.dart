import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class AppConfirmationDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  final String confirmText;
  final String? cancelText;

  final Color confirmColor;

  const AppConfirmationDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText,
    this.iconColor = Colors.redAccent,
    this.confirmColor = Kolors.kPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 52,
              color: iconColor,
            ),

            const SizedBox(height: 16),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(.7),
                fontSize: 14,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 26),

            if (cancelText != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.white.withOpacity(.2),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pop(context, false),
                      child: Text(
                        cancelText!,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pop(context, true),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                  onPressed: () =>
                      Navigator.pop(context, true),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}