import 'package:flutter/material.dart';
import 'package:flutter_application_2/common/utils/kcolors.dart';

class QrOverlay extends StatelessWidget {
  final Animation<double> animation;

  const QrOverlay({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.7;

    return Stack(
      children: [
        // Semi-transparent hole
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.6),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  height: size,
                  width: size,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Moving laser line
        Center(
          child: SizedBox(
            height: size,
            width: size,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white38, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    Positioned(
                      top: animation.value * size,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Kolors.kPrimary.withOpacity(0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                          gradient: const LinearGradient(
                            colors: [Colors.transparent, Kolors.kPrimary, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // Helper text
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.2,
          left: 0,
          right: 0,
          child: const Column(
            children: [
              Text(
                "Align QR code within the frame",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                "Scanning will start automatically",
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        )
      ],
    );
  }
}
