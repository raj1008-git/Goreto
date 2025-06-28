import 'package:flutter/material.dart';

class StoryboardAnimator {
  final TickerProvider vsync;
  late AnimationController imageFadeController;
  late Animation<double> imageOpacityAnimation;

  late AnimationController cardSlideController;
  late Animation<Offset> cardOffsetAnimation;
  late Animation<double> cardOpacityAnimation;

  static const Duration _imageFadeDuration = Duration(milliseconds: 700);
  static const Duration _cardSlideDuration = Duration(milliseconds: 700);
  static const Duration _delayBeforeCardEntry = Duration(milliseconds: 200);
  static const Duration _delayBeforeNewImageEntry = Duration(milliseconds: 150);

  StoryboardAnimator({required this.vsync}) {
    imageFadeController = AnimationController(
      vsync: vsync,
      duration: _imageFadeDuration,
    );
    imageOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: imageFadeController, curve: Curves.easeOut),
    );

    cardSlideController = AnimationController(
      vsync: vsync,
      duration: _cardSlideDuration,
    );
    cardOffsetAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: cardSlideController,
            curve: Curves.easeOutCubic,
          ),
        );
    cardOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: cardSlideController, curve: Curves.easeIn),
    );
  }

  void runInitialAnimation() {
    imageFadeController.forward().then((_) {
      Future.delayed(_delayBeforeCardEntry, () {
        cardSlideController.forward();
      });
    });
  }

  Future<void> triggerNextStoryAnimation(VoidCallback onUpdate) async {
    await Future.wait([
      imageFadeController.reverse(),
      cardSlideController.reverse(from: 0.0),
    ]);
    await Future.delayed(_delayBeforeNewImageEntry);

    onUpdate(); // triggers setState in widget

    imageFadeController.reset();
    cardSlideController.reset();

    await imageFadeController.forward();
    await Future.delayed(_delayBeforeCardEntry);
    await cardSlideController.forward();
  }

  void dispose() {
    imageFadeController.dispose();
    cardSlideController.dispose();
  }
}
