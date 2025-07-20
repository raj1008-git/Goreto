import 'package:flutter/material.dart';

class EnhancedBottomNavBarPainter extends CustomPainter {
  final double screenWidth;

  EnhancedBottomNavBarPainter({required this.screenWidth});

  @override
  void paint(Canvas canvas, Size size) {
    // Main border paint
    final borderPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Subtle gradient overlay paint
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
      ).createShader(Rect.fromLTWH(0, 0, screenWidth, size.height));

    final path = Path();
    final centerX = screenWidth / 2;

    // Enhanced curve parameters
    final notchRadius = 32.0; // Slightly smaller
    final curveDepth = 20.0; // Reduced depth
    final edgeOffset = 16.0; // Less spacing
    final curveControlOffset = 12.0; // Smaller control offset

    // Start from the left edge
    path.moveTo(0, 0);

    // Line to left of notch with slight curve
    path.lineTo(centerX - notchRadius - edgeOffset, 0);

    // Enhanced left curve into the notch
    path.cubicTo(
      centerX - notchRadius - curveControlOffset,
      0,
      centerX - notchRadius,
      curveDepth * 0.3,
      centerX - notchRadius * 0.7,
      curveDepth,
    );

    // Main notch arc (more precise)
    path.arcToPoint(
      Offset(centerX + notchRadius * 0.7, curveDepth),
      radius: Radius.circular(notchRadius * 0.8),
      clockwise: false,
    );

    // Enhanced right curve out of the notch
    path.cubicTo(
      centerX + notchRadius,
      curveDepth * 0.3,
      centerX + notchRadius + curveControlOffset,
      0,
      centerX + notchRadius + edgeOffset,
      0,
    );

    // Line to right edge
    path.lineTo(screenWidth, 0);

    // Draw the main border
    canvas.drawPath(path, borderPaint);

    // Add subtle inner glow effect
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    final innerPath = Path();
    innerPath.moveTo(0, -1);
    innerPath.lineTo(centerX - notchRadius - edgeOffset, -1);
    innerPath.cubicTo(
      centerX - notchRadius - curveControlOffset,
      -1,
      centerX - notchRadius,
      curveDepth * 0.3 - 1,
      centerX - notchRadius * 0.7,
      curveDepth - 1,
    );
    innerPath.arcToPoint(
      Offset(centerX + notchRadius * 0.7, curveDepth - 1),
      radius: Radius.circular(notchRadius * 0.8),
      clockwise: false,
    );
    innerPath.cubicTo(
      centerX + notchRadius,
      curveDepth * 0.3 - 1,
      centerX + notchRadius + curveControlOffset,
      -1,
      centerX + notchRadius + edgeOffset,
      -1,
    );
    innerPath.lineTo(screenWidth, -1);

    canvas.drawPath(innerPath, glowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
