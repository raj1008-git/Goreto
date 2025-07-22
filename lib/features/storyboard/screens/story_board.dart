// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:goreto/core/utils/media_query_helper.dart';
// import 'package:goreto/features/storyboard/animations/storyboard_animator.dart';
// import 'package:goreto/features/storyboard/providers/story_board_provider.dart';
// import 'package:goreto/features/storyboard/widgets/story_card.dart';
// import 'package:goreto/routes/app_routes.dart';
// import 'package:goreto/routes/transitions.dart';
// import 'package:provider/provider.dart';
//
// class StoryBoardScreen extends StatefulWidget {
//   const StoryBoardScreen({super.key});
//
//   @override
//   State<StoryBoardScreen> createState() => _StoryBoardScreenState();
// }
//
// class _StoryBoardScreenState extends State<StoryBoardScreen>
//     with TickerProviderStateMixin {
//   late StoryboardAnimator _animator;
//   int _currentProviderIndex = 0;
//   bool _isDisposed = false;
//
//   // Cache for preloaded images
//   final Map<String, ImageProvider> _imageCache = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimator();
//     _preloadImages();
//   }
//
//   void _initializeAnimator() {
//     _animator = StoryboardAnimator(vsync: this);
//
//     // Start animations with better frame timing
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       if (!_isDisposed && mounted) {
//         _animator.runInitialAnimation();
//       }
//     });
//   }
//
//   Future<void> _preloadImages() async {
//     // Preload images in background to prevent stuttering
//     final storyProvider = Provider.of<StoryBoardProvider>(
//       context,
//       listen: false,
//     );
//
//     final imagePreloadFutures = <Future>[];
//
//     // Preload all story images
//     for (int i = 0; i < storyProvider.storiesCount; i++) {
//       // Get story by index using the stories list
//       final story = storyProvider.getStoryAt(i);
//       final imageProvider = AssetImage(story.imagePath);
//       _imageCache[story.imagePath] = imageProvider;
//
//       // Preload in background
//       imagePreloadFutures.add(
//         precacheImage(imageProvider, context).catchError((_) {
//           // Ignore preload errors
//         }),
//       );
//     }
//
//     // Don't await - let preloading happen in background
//     unawaited(Future.wait(imagePreloadFutures));
//   }
//
//   void _onStoryIndexChanged(int newIndex) {
//     if (_isDisposed || !mounted) return;
//
//     if (_currentProviderIndex != newIndex) {
//       _currentProviderIndex = newIndex;
//
//       // Trigger animation for story change
//       if (!_animator.isAnimating) {
//         _animator.triggerNextStoryAnimation(() {
//           if (mounted && !_isDisposed) {
//             setState(() {});
//           }
//         });
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _isDisposed = true;
//     _animator.dispose();
//     super.dispose();
//   }
//
//   Widget _buildOptimizedImage(String imagePath) {
//     final cachedImage = _imageCache[imagePath];
//
//     return AnimatedBuilder(
//       animation: _animator.imageOpacityAnimation,
//       builder: (context, child) {
//         return Opacity(
//           opacity: _animator.imageOpacityAnimation.value,
//           child: Image(
//             image: cachedImage ?? AssetImage(imagePath),
//             fit: BoxFit.cover,
//             key: ValueKey(imagePath),
//             frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
//               if (wasSynchronouslyLoaded || frame != null) {
//                 return child;
//               }
//               return Container(color: Colors.grey[200]);
//             },
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 color: Colors.grey[300],
//                 child: const Icon(Icons.error),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildAnimatedCard(BuildContext context, ScreenSize screen) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _animator.cardOffsetAnimation,
//         _animator.cardOpacityAnimation,
//       ]),
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(
//             screen.width * _animator.cardOffsetAnimation.value.dx,
//             0,
//           ),
//           child: Opacity(
//             opacity: _animator.cardOpacityAnimation.value,
//             child: child,
//           ),
//         );
//       },
//       child: Consumer<StoryBoardProvider>(
//         builder: (context, storyProvider, child) {
//           final currentStory = storyProvider.currentStory;
//
//           // Listen for story index changes here
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _onStoryIndexChanged(storyProvider.currentStoryIndex);
//           });
//
//           return StoryCard(
//             title: currentStory.title,
//             description: currentStory.description,
//             onPressed: () => _handleStoryAction(storyProvider),
//             isLast: storyProvider.isLastStory,
//             width: screen.widthP(85),
//           );
//         },
//       ),
//     );
//   }
//
//   void _handleStoryAction(StoryBoardProvider storyProvider) {
//     if (storyProvider.isLastStory) {
//       Navigator.pushReplacement(
//         context,
//         buildSlideTransition(AppRoutes.getPage(AppRoutes.loginorregister)),
//       );
//     } else {
//       storyProvider.nextStory();
//     }
//   }
//
//   Widget _buildDots(ScreenSize screen, StoryBoardProvider storyProvider) {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Padding(
//         padding: EdgeInsets.only(bottom: screen.heightP(5)),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(
//             storyProvider.storiesCount,
//             (index) => AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               curve: Curves.easeInOut,
//               margin: const EdgeInsets.symmetric(horizontal: 4.0),
//               width: 20.0,
//               height: 6.0,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10.0),
//                 shape: BoxShape.rectangle,
//                 color: storyProvider.currentStoryIndex == index
//                     ? const Color(0xFFFFFFFF)
//                     : Colors.grey.withOpacity(0.5),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screen = ScreenSize(context);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Consumer<StoryBoardProvider>(
//         builder: (context, storyProvider, child) {
//           final currentStory = storyProvider.currentStory;
//
//           return Stack(
//             children: [
//               // Optimized background image
//               Positioned.fill(
//                 child: _buildOptimizedImage(currentStory.imagePath),
//               ),
//
//               // Animated content card
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Padding(
//                   padding: EdgeInsets.only(bottom: screen.heightP(10)),
//                   child: _buildAnimatedCard(context, screen),
//                 ),
//               ),
//
//               // Animated dots indicator
//               _buildDots(screen, storyProvider),
//             ],
//           );
//         },
//       ),
//     );
//   }
//
//   // Helper function for unawaited futures
//   void unawaited(Future<void> future) {
//     // Intentionally not awaited
//   }
// }
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:goreto/core/utils/media_query_helper.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentIndex = 0;
  bool _isAnimating = false;

  // Cache for preloaded images
  final Map<String, ImageProvider> _imageCache = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _preloadImages();

    // Simple initial animation
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );
  }

  Future<void> _preloadImages() async {
    final storyProvider = Provider.of<StoryBoardProvider>(
      context,
      listen: false,
    );

    // Preload all images without awaiting
    for (int i = 0; i < storyProvider.storiesCount; i++) {
      final story = storyProvider.getStoryAt(i);
      final imageProvider = AssetImage(story.imagePath);
      _imageCache[story.imagePath] = imageProvider;

      precacheImage(imageProvider, context).catchError((_) {});
    }
  }

  void _onStoryIndexChanged(int newIndex) {
    if (_currentIndex != newIndex && !_isAnimating) {
      _animateToNextStory();
      _currentIndex = newIndex;
    }
  }

  void _animateToNextStory() {
    if (_isAnimating) return;

    _isAnimating = true;
    _controller.reset();
    _controller.forward().then((_) {
      _isAnimating = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBackgroundImage(String imagePath) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(imagePath),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: _imageCache[imagePath] ?? AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedContent(BuildContext context, ScreenSize screen) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(position: _slideAnimation, child: child),
        );
      },
      child: Consumer<StoryBoardProvider>(
        builder: (context, storyProvider, child) {
          final currentStory = storyProvider.currentStory;

          // Check for index changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onStoryIndexChanged(storyProvider.currentStoryIndex);
          });

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Story Card
              Container(
                margin: EdgeInsets.only(bottom: screen.heightP(10)),
                child: StoryCard(
                  title: currentStory.title,
                  description: currentStory.description,
                  onPressed: () => _handleStoryAction(storyProvider),
                  isLast: storyProvider.isLastStory,
                  width: screen.widthP(85),
                ),
              ),

              // Dots Indicator
              _buildDotsIndicator(screen, storyProvider),
            ],
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

  Widget _buildDotsIndicator(
    ScreenSize screen,
    StoryBoardProvider storyProvider,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: screen.heightP(5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          storyProvider.storiesCount,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: storyProvider.currentStoryIndex == index ? 24.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: storyProvider.currentStoryIndex == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.4),
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
      backgroundColor: Colors.black,
      body: Consumer<StoryBoardProvider>(
        builder: (context, storyProvider, child) {
          final currentStory = storyProvider.currentStory;

          return Stack(
            children: [
              // Background Image with smooth transition
              Positioned.fill(
                child: _buildBackgroundImage(currentStory.imagePath),
              ),

              // Gradient overlay for better text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Animated content
              _buildAnimatedContent(context, screen),
            ],
          );
        },
      ),
    );
  }
}
