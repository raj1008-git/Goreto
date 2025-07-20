import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class StoryboardAnimator {
  final TickerProvider vsync;
  late AnimationController imageFadeController;
  late Animation<double> imageOpacityAnimation;

  late AnimationController cardSlideController;
  late Animation<Offset> cardOffsetAnimation;
  late Animation<double> cardOpacityAnimation;

  // Optimized durations for better performance
  static const Duration _imageFadeDuration = Duration(milliseconds: 350);
  static const Duration _cardSlideDuration = Duration(milliseconds: 300);
  static const Duration _delayBeforeCardEntry = Duration(milliseconds: 150);
  static const Duration _delayBeforeNewImageEntry = Duration(milliseconds: 50);

  // Completer for managing async animation chains
  Completer<void>? _animationCompleter;
  bool _isAnimating = false;

  StoryboardAnimator({required this.vsync}) {
    _initializeControllers();
  }

  void _initializeControllers() {
    imageFadeController = AnimationController(
      vsync: vsync,
      duration: _imageFadeDuration,
    );

    // Use more performant curves
    imageOpacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: imageFadeController,
        curve: Curves.easeInOut, // More efficient than linear
      ),
    );

    cardSlideController = AnimationController(
      vsync: vsync,
      duration: _cardSlideDuration,
    );

    cardOffsetAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: cardSlideController,
            curve: Curves.easeOutQuart, // Smooth, performant curve
          ),
        );

    cardOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: cardSlideController, curve: Curves.easeOut),
    );
  }

  void runInitialAnimation() {
    if (_isAnimating) return;
    _isAnimating = true;

    // Use SchedulerBinding to optimize frame timing
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _runInitialAnimationAsync();
    });
  }

  Future<void> _runInitialAnimationAsync() async {
    try {
      await imageFadeController.forward();
      await Future.delayed(_delayBeforeCardEntry);
      await cardSlideController.forward();
    } finally {
      _isAnimating = false;
    }
  }

  Future<void> triggerNextStoryAnimation(VoidCallback onUpdate) async {
    if (_isAnimating) {
      await _animationCompleter?.future;
    }

    _animationCompleter = Completer<void>();
    _isAnimating = true;

    try {
      await _performStoryTransition(onUpdate);
    } finally {
      _isAnimating = false;
      if (!_animationCompleter!.isCompleted) {
        _animationCompleter!.complete();
      }
    }
  }

  Future<void> _performStoryTransition(VoidCallback onUpdate) async {
    // Optimized animation sequence using microtasks
    await _exitCurrentStory();

    // Update content in the next frame to avoid jank
    await Future.microtask(() => onUpdate());

    await _enterNewStory();
  }

  Future<void> _exitCurrentStory() async {
    final futures = <Future<void>>[];

    // Run exit animations in parallel
    if (imageFadeController.isCompleted) {
      futures.add(imageFadeController.reverse());
    }

    if (cardSlideController.isCompleted) {
      futures.add(cardSlideController.reverse());
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    await Future.delayed(_delayBeforeNewImageEntry);
  }

  Future<void> _enterNewStory() async {
    // Reset controllers efficiently
    imageFadeController.reset();
    cardSlideController.reset();

    // Chain animations with optimized timing
    await imageFadeController.forward();
    await Future.delayed(_delayBeforeCardEntry);
    await cardSlideController.forward();
  }

  // Add method to check animation state
  bool get isAnimating => _isAnimating;

  // Add method to cancel animations if needed
  void cancelAnimations() {
    if (_isAnimating) {
      imageFadeController.stop();
      cardSlideController.stop();
      _isAnimating = false;
      _animationCompleter?.complete();
    }
  }

  void dispose() {
    cancelAnimations();
    imageFadeController.dispose();
    cardSlideController.dispose();
  }
}
