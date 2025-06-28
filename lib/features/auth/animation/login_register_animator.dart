import 'package:flutter/material.dart';

class LoginRegisterAnimator {
  final TickerProvider vsync;
  late final AnimationController controller;
  late final Animation<double> fadeAnimation;

  static const Duration fadeDuration = Duration(milliseconds: 800);
  static const Duration fadeDelay = Duration(milliseconds: 800);

  LoginRegisterAnimator({required this.vsync}) {
    controller = AnimationController(vsync: vsync, duration: fadeDuration);

    fadeAnimation = CurvedAnimation(parent: controller, curve: Curves.easeIn);

    Future.delayed(fadeDelay, () {
      controller.forward();
    });
  }

  void dispose() {
    controller.dispose();
  }
}
