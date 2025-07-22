// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';

// class LoginRegisterAnimator {
//   final TickerProvider vsync;
//   late AnimationController _fadeController;
//   late Animation<double> fadeAnimation;

//   // Optimized animation duration
//   static const Duration _fadeInDuration = Duration(
//     milliseconds: 200,
//   ); // Reduced for faster feel

//   LoginRegisterAnimator({required this.vsync}) {
//     _initializeAnimations();
//   }

//   void _initializeAnimations() {
//     _fadeController = AnimationController(
//       vsync: vsync,
//       duration: _fadeInDuration,
//     );

//     fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _fadeController,
//         curve: Curves.easeOutCubic, // Smoother curve
//       ),
//     );
//   }

//   void startAnimation() {
//     // Use scheduler for better frame timing
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       _fadeController.forward();
//     });
//   }

//   // Add method to start animation with delay
//   Future<void> startAnimationWithDelay([Duration delay = Duration.zero]) async {
//     if (delay > Duration.zero) {
//       await Future.delayed(delay);
//     }

//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       _fadeController.forward();
//     });
//   }

//   // Add method to check if animation is running
//   bool get isAnimating => _fadeController.isAnimating;

//   // Add method to get animation progress
//   double get progress => _fadeController.value;

//   // Add method to check if animation is completed
//   bool get isCompleted => _fadeController.isCompleted;

//   // Method to restart animation if needed
//   Future<void> restartAnimation() async {
//     _fadeController.reset();
//     await _fadeController.forward();
//   }

//   // Method to reverse animation
//   Future<void> reverseAnimation() async {
//     await _fadeController.reverse();
//   }

//   // Method to stop animation
//   void stopAnimation() {
//     _fadeController.stop();
//   }

//   // Method to reset animation
//   void resetAnimation() {
//     _fadeController.reset();
//   }

//   void dispose() {
//     _fadeController.dispose();
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class LoginRegisterAnimator {
  final TickerProvider vsync;

  // Single controller to avoid ticker issues
  late AnimationController _controller;

  // Logo animations
  late Animation<double> logoOpacity;
  late Animation<double> logoScale;
  late Animation<Offset> logoSlide;

  // Card animations
  late Animation<double> cardOpacity;
  late Animation<double> cardScale;
  late Animation<Offset> cardSlide;

  // Button animations
  late Animation<double> buttonOpacity;
  late Animation<double> buttonScale;

  // Background image animation
  late Animation<double> backgroundOpacity;

  // Professional duration - fast and smooth
  static const Duration _animationDuration = Duration(milliseconds: 1000);

  LoginRegisterAnimator({required this.vsync}) {
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Single controller for all animations
    _controller = AnimationController(
      vsync: vsync,
      duration: _animationDuration,
    );

    _setupLogoAnimations();
    _setupCardAnimations();
    _setupButtonAnimations();
    _setupBackgroundAnimation();
  }

  void _setupLogoAnimations() {
    // Logo animations with custom intervals
    logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutQuart),
      ),
    );

    logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    logoSlide = Tween<Offset>(begin: const Offset(0, -0.8), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
          ),
        );
  }

  void _setupCardAnimations() {
    // Card animations start slightly after logo
    cardOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeOutQuart),
      ),
    );

    cardScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );

    cardSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
          ),
        );
  }

  void _setupButtonAnimations() {
    // Buttons animate last for staggered effect
    buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    buttonScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  void _setupBackgroundAnimation() {
    // Background appears immediately for smooth experience
    backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );
  }

  // Start the main animation
  void startAnimation() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  // Quick animation for error cases
  void startQuickAnimation() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _controller.duration = const Duration(milliseconds: 600);
      _controller.forward();
    });
  }

  // Smooth reverse animation
  Future<void> reverseAnimation() async {
    await _controller.reverse();
  }

  // Fast exit for responsive navigation
  Future<void> fastExit() async {
    // Speed up the reverse animation
    _controller.duration = const Duration(milliseconds: 300);
    await _controller.reverse();
  }

  // Convenience getters
  bool get isAnimating => _controller.isAnimating;
  bool get isCompleted => _controller.isCompleted;
  double get progress => _controller.value;

  // Reset animation
  void resetAnimation() {
    _controller.reset();
    _controller.duration = _animationDuration; // Reset duration
  }

  // Stop animation
  void stopAnimation() {
    _controller.stop();
  }

  // Restart animation
  Future<void> restartAnimation() async {
    _controller.reset();
    await _controller.forward();
  }

  void dispose() {
    _controller.dispose();
  }
}
