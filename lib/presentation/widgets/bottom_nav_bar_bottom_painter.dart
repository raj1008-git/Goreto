import 'package:flutter/material.dart';

class BottomNavBarBorderPainter extends CustomPainter {
  final Color color;
  final double fabRadius;
  final double screenWidth;

  BottomNavBarBorderPainter({
    required this.color,
    required this.fabRadius,
    required this.screenWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    final centerX = screenWidth / 2;

    final notchRadius = fabRadius + 8; // Padding around FAB
    final curveDepth = 20.0; // How deep the curve dips
    final edgeOffset = 14.0; // Horizontal spacing beside FAB

    // Start from the left edge
    path.moveTo(0, 0);

    // Line to left of notch
    path.lineTo(centerX - notchRadius - edgeOffset, 0);

    // Left curve into the notch
    path.quadraticBezierTo(
      centerX - notchRadius,
      0,
      centerX - notchRadius * 0.85,
      curveDepth,
    );

    // Main notch arc
    path.arcToPoint(
      Offset(centerX + notchRadius * 0.85, curveDepth),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    // Right curve out of the notch
    path.quadraticBezierTo(
      centerX + notchRadius,
      0,
      centerX + notchRadius + edgeOffset,
      0,
    );

    // Line to right edge
    path.lineTo(screenWidth, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
