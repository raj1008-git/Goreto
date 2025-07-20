import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LoginRegisterAnimator {
  final TickerProvider vsync;
  late AnimationController _fadeController;
  late Animation<double> fadeAnimation;

  // Optimized animation duration
  static const Duration _fadeInDuration = Duration(
    milliseconds: 200,
  ); // Reduced for faster feel

  LoginRegisterAnimator({required this.vsync}) {
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: vsync,
      duration: _fadeInDuration,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic, // Smoother curve
      ),
    );
  }

  void startAnimation() {
    // Use scheduler for better frame timing
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });
  }

  // Add method to start animation with delay
  Future<void> startAnimationWithDelay([Duration delay = Duration.zero]) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });
  }

  // Add method to check if animation is running
  bool get isAnimating => _fadeController.isAnimating;

  // Add method to get animation progress
  double get progress => _fadeController.value;

  // Add method to check if animation is completed
  bool get isCompleted => _fadeController.isCompleted;

  // Method to restart animation if needed
  Future<void> restartAnimation() async {
    _fadeController.reset();
    await _fadeController.forward();
  }

  // Method to reverse animation
  Future<void> reverseAnimation() async {
    await _fadeController.reverse();
  }

  // Method to stop animation
  void stopAnimation() {
    _fadeController.stop();
  }

  // Method to reset animation
  void resetAnimation() {
    _fadeController.reset();
  }

  void dispose() {
    _fadeController.dispose();
  }
}
