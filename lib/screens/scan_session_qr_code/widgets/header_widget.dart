import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrHeader extends StatelessWidget {
  final MobileScannerController controller;
  final VoidCallback? onCallPressed; // 👈 add callback

  const QrHeader({
    super.key,
    required this.controller,
    this.onCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// 🔙 Back
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),

        /// 🧾 Title
        const Text(
          "SCAN CLIENT QR",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),

        /// ⚡ Actions (Flash + Call)
        Row(
          children: [
            /// 🔦 Flash Button (rebuilds only this icon)
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, child) {
                final torchState = (value as dynamic).torchState;

                return IconButton(
                  icon: Icon(
                    torchState == TorchState.on
                        ? Icons.flash_on
                        : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: () => controller.toggleTorch(),
                );
              },
            ),

            /// 📞 Call Button
            IconButton(
              icon: const Icon(Icons.call, color: Colors.white),
              onPressed: onCallPressed,
            ),
          ],
        ),
      ],
    );
  }
}
