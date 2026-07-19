import 'package:flutter/material.dart';

class FaceOverlay extends StatelessWidget {
  final bool faceDetected;

  const FaceOverlay({
    super.key,
    required this.faceDetected,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return IgnorePointer(
      child: CustomPaint(
        size: size,
        painter: FaceOverlayPainter(
          faceDetected: faceDetected,
        ),
      ),
    );
  }
}

class FaceOverlayPainter extends CustomPainter {
  final bool faceDetected;

  FaceOverlayPainter({
    required this.faceDetected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()
      ..color = Colors.black.withOpacity(0.55);

    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;

    final circleRadius = size.width * 0.33;

    final center = Offset(
      size.width / 2,
      size.height * 0.38,
    );

    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      overlay,
    );

    canvas.drawCircle(
      center,
      circleRadius,
      clearPaint,
    );

    canvas.restore();

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = faceDetected
          ? Colors.greenAccent
          : Colors.white54;

    canvas.drawCircle(
      center,
      circleRadius,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant FaceOverlayPainter oldDelegate) {
    return oldDelegate.faceDetected != faceDetected;
  }
}