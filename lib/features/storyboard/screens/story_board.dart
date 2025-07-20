import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:goreto/core/utils/media_query_helper.dart';
import 'package:goreto/features/storyboard/animations/storyboard_animator.dart';
import 'package:goreto/features/storyboard/providers/story_board_provider.dart';
import 'package:goreto/features/storyboard/widgets/story_card.dart';
import 'package:goreto/routes/app_routes.dart';
import 'package:goreto/routes/transitions.dart';
import 'package:provider/provider.dart';

class StoryBoardScreen extends StatefulWidget {
  const StoryBoardScreen({super.key});

  @override
  State<StoryBoardScreen> createState() => _StoryBoardScreenState();
}

class _StoryBoardScreenState extends State<StoryBoardScreen>
    with TickerProviderStateMixin {
  late StoryboardAnimator _animator;
  int _currentProviderIndex = 0;
  bool _isDisposed = false;

  // Cache for preloaded images
  final Map<String, ImageProvider> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimator();
    _preloadImages();
  }

  void _initializeAnimator() {
    _animator = StoryboardAnimator(vsync: this);

    // Start animations with better frame timing
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        _animator.runInitialAnimation();
      }
    });
  }

  Future<void> _preloadImages() async {
    // Preload images in background to prevent stuttering
    final storyProvider = Provider.of<StoryBoardProvider>(
      context,
      listen: false,
    );

    final imagePreloadFutures = <Future>[];

    // Preload all story images
    for (int i = 0; i < storyProvider.storiesCount; i++) {
      // Get story by index using the stories list
      final story = storyProvider.getStoryAt(i);
      final imageProvider = AssetImage(story.imagePath);
      _imageCache[story.imagePath] = imageProvider;

      // Preload in background
      imagePreloadFutures.add(
        precacheImage(imageProvider, context).catchError((_) {
          // Ignore preload errors
        }),
      );
    }

    // Don't await - let preloading happen in background
    unawaited(Future.wait(imagePreloadFutures));
  }

  void _onStoryIndexChanged(int newIndex) {
    if (_isDisposed || !mounted) return;

    if (_currentProviderIndex != newIndex) {
      _currentProviderIndex = newIndex;

      // Trigger animation for story change
      if (!_animator.isAnimating) {
        _animator.triggerNextStoryAnimation(() {
          if (mounted && !_isDisposed) {
            setState(() {});
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animator.dispose();
    super.dispose();
  }

  Widget _buildOptimizedImage(String imagePath) {
    final cachedImage = _imageCache[imagePath];

    return AnimatedBuilder(
      animation: _animator.imageOpacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _animator.imageOpacityAnimation.value,
          child: Image(
            image: cachedImage ?? AssetImage(imagePath),
            fit: BoxFit.cover,
            key: ValueKey(imagePath),
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) {
                return child;
              }
              return Container(color: Colors.grey[200]);
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCard(BuildContext context, ScreenSize screen) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _animator.cardOffsetAnimation,
        _animator.cardOpacityAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            screen.width * _animator.cardOffsetAnimation.value.dx,
            0,
          ),
          child: Opacity(
            opacity: _animator.cardOpacityAnimation.value,
            child: child,
          ),
        );
      },
      child: Consumer<StoryBoardProvider>(
        builder: (context, storyProvider, child) {
          final currentStory = storyProvider.currentStory;

          // Listen for story index changes here
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onStoryIndexChanged(storyProvider.currentStoryIndex);
          });

          return StoryCard(
            title: currentStory.title,
            description: currentStory.description,
            onPressed: () => _handleStoryAction(storyProvider),
            isLast: storyProvider.isLastStory,
            width: screen.widthP(85),
          );
        },
      ),
    );
  }

  void _handleStoryAction(StoryBoardProvider storyProvider) {
    if (storyProvider.isLastStory) {
      Navigator.pushReplacement(
        context,
        buildSlideTransition(AppRoutes.getPage(AppRoutes.loginorregister)),
      );
    } else {
      storyProvider.nextStory();
    }
  }

  Widget _buildDots(ScreenSize screen, StoryBoardProvider storyProvider) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: screen.heightP(5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            storyProvider.storiesCount,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: 20.0,
              height: 6.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                shape: BoxShape.rectangle,
                color: storyProvider.currentStoryIndex == index
                    ? const Color(0xFFFFFFFF)
                    : Colors.grey.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<StoryBoardProvider>(
        builder: (context, storyProvider, child) {
          final currentStory = storyProvider.currentStory;

          return Stack(
            children: [
              // Optimized background image
              Positioned.fill(
                child: _buildOptimizedImage(currentStory.imagePath),
              ),

              // Animated content card
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: screen.heightP(10)),
                  child: _buildAnimatedCard(context, screen),
                ),
              ),

              // Animated dots indicator
              _buildDots(screen, storyProvider),
            ],
          );
        },
      ),
    );
  }

  // Helper function for unawaited futures
  void unawaited(Future<void> future) {
    // Intentionally not awaited
  }
}
