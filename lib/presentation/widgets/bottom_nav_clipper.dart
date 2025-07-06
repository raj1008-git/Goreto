// lib/presentation/widgets/bottom_nav_clipper.dart

import 'package:flutter/material.dart';

class BottomNavClipper extends CustomClipper<Path> {
  const BottomNavClipper();

  @override
  Path getClip(Size size) {
    const fabRadius = 30.0;
    const notchMargin = 8.0;
    final fabX = size.width / 2;
    final fabY = 0.0;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(fabX - fabRadius - notchMargin, 0)
      ..arcToPoint(
        Offset(fabX + fabRadius + notchMargin, 0),
        radius: const Radius.circular(fabRadius + notchMargin),
        clockwise: false,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
