import 'package:flutter/material.dart';
import 'package:goreto/core/utils/media_query_helper.dart';
import 'package:goreto/routes/app_routes.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

import '../providers/story_board_provider.dart';

// Ensure this import path is correct based on our last discussion

class StoryBoardScreen extends StatefulWidget {
  const StoryBoardScreen({super.key});

  @override
  State<StoryBoardScreen> createState() => _StoryBoardScreenState();
}

class _StoryBoardScreenState extends State<StoryBoardScreen>
    with TickerProviderStateMixin {
  // --- Animation Controllers and Animations ---
  late AnimationController _imageFadeController; // Controls image fade in/out
  late Animation<double> _imageOpacityAnimation;

  late AnimationController
  _cardSlideController; // Controls card slide in/out and fade in/out
  late Animation<Offset> _cardOffsetAnimation;
  late Animation<double> _cardOpacityAnimation;

  // --- Local state to track provider's index changes ---
  int _currentProviderIndex = 0;
  static const Duration _imageFadeDuration = Duration(milliseconds: 700);
  static const Duration _cardSlideDuration = Duration(milliseconds: 700);
  static const Duration _delayBeforeCardEntry = Duration(
    milliseconds: 200,
  ); // Delay for card after image
  static const Duration _delayBeforeNewImageEntry = Duration(milliseconds: 150);
  @override
  @override
  void initState() {
    super.initState();

    _imageFadeController = AnimationController(
      vsync: this,
      duration: _imageFadeDuration, // Use the defined duration
    );
    _imageOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _imageFadeController, curve: Curves.easeOut),
    );

    _cardSlideController = AnimationController(
      vsync: this,
      duration: _cardSlideDuration, // Use the defined duration
    );
    _cardOffsetAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _cardSlideController,
            curve: Curves.easeOutCubic,
          ),
        );
    _cardOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardSlideController, curve: Curves.easeIn),
    );

    // --- MODIFIED SECTION FOR INITIAL ANIMATIONS WITH DELAY ---
    _imageFadeController.forward().then((_) {
      // Start image fade-in
      // After image fade-in completes, introduce a small delay, then start card slide-in
      Future.delayed(_delayBeforeCardEntry, () {
        if (mounted) {
          // Ensure widget is still in tree before starting animation
          _cardSlideController.forward();
        }
      });
    });
    // --- END MODIFIED SECTION ---

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storyProvider = Provider.of<StoryBoardProvider>(
        context,
        listen: false,
      );
      storyProvider.addListener(_onStoryIndexChanged);
      _currentProviderIndex = storyProvider.currentStoryIndex;
    });
  }

  @override
  void dispose() {
    _imageFadeController.dispose();
    _cardSlideController.dispose();
    // Remove listener from provider to prevent memory leaks
    final storyProvider = Provider.of<StoryBoardProvider>(
      context,
      listen: false,
    );
    storyProvider.removeListener(_onStoryIndexChanged);
    super.dispose();
  }

  // --- Callback when StoryBoardProvider notifies listeners ---
  void _onStoryIndexChanged() {
    final storyProvider = Provider.of<StoryBoardProvider>(
      context,
      listen: false,
    );
    // Only trigger animation if the index has actually changed
    if (_currentProviderIndex != storyProvider.currentStoryIndex) {
      _currentProviderIndex =
          storyProvider.currentStoryIndex; // Update local index
      _triggerNextStoryAnimation();
    }
  }

  // --- Animation Orchestration for "Next" button press ---
  Future<void> _triggerNextStoryAnimation() async {
    // 1. **Phase: Exit Animations (Current Image fades out, Current Card slides left & fades out)**
    await Future.wait([
      _imageFadeController.reverse(),
      _cardSlideController.reverse(from: 0.0),
    ]);

    // --- ADD THIS DELAY ---
    // Introduce a small delay after old content has disappeared
    await Future.delayed(_delayBeforeNewImageEntry);
    // --- END ADDED DELAY ---

    // 2. **Phase: Update Content and Reset Controllers**
    setState(() {}); // This rebuilds the widget with the next story's data

    _imageFadeController.reset();
    _cardSlideController.reset();

    // 3. **Phase: Entry Animations (New Image fades in, NEW DELAY, New Card slides from right & fades in)**
    // Start new image fade-in
    await _imageFadeController.forward();

    // --- ADD THIS DELAY ---
    // After new image fades in, introduce a small delay, then start new card slide-in
    await Future.delayed(_delayBeforeCardEntry);
    // --- END ADDED DELAY ---

    if (mounted) {
      // Ensure widget is still in tree before starting animation
      await _cardSlideController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);
    // context.watch ensures this widget rebuilds when storyProvider notifies
    final storyProvider = context.watch<StoryBoardProvider>();
    final currentStory = storyProvider.currentStory;

    return Scaffold(
      body: Stack(
        children: [
          // --- Background Image with Fade Animation ---
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _imageOpacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _imageOpacityAnimation.value,
                  // Use a Key here to tell Flutter that the Image.asset itself has changed,
                  // which can help in ensuring smooth transitions with different assets.
                  child: Image.asset(
                    currentStory.imagePath,
                    fit: BoxFit.cover,
                    key: ValueKey(currentStory.imagePath),
                  ),
                );
              },
            ),
          ),

          // --- Content Card with Slide and Fade Animation ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: screen.heightP(10)),
              // AnimatedBuilder rebuilds its child whenever _cardOffsetAnimation or _cardOpacityAnimation changes.
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _cardOffsetAnimation,
                  _cardOpacityAnimation,
                ]),
                builder: (context, child) {
                  return Transform.translate(
                    // Apply the horizontal slide based on animation value
                    offset: Offset(
                      screen.width * _cardOffsetAnimation.value.dx,
                      0,
                    ),
                    child: Opacity(
                      opacity: _cardOpacityAnimation
                          .value, // Apply fade based on animation value
                      child: Container(
                        // Key helps Flutter identify this specific container as it changes content
                        key: ValueKey(storyProvider.currentStoryIndex),
                        width: screen.widthP(85),
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(25.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currentStory.title,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: screen.widthP(5.5),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF192639),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentStory.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screen.widthP(3.8),
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: () {
                                if (storyProvider.isLastStory) {
                                  // Final navigation to dashboard with right-to-left slide
                                  Navigator.pushReplacement(
                                    context,
                                    PageTransition(
                                      type: PageTransitionType
                                          .rightToLeft, // Changed to slide
                                      duration: const Duration(
                                        milliseconds: 550,
                                      ),
                                      child: AppRoutes.getPage(
                                        AppRoutes.dashboard,
                                      ),
                                      settings: const RouteSettings(
                                        name: AppRoutes.dashboard,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Call nextStory on the provider.
                                  // The _onStoryIndexChanged listener will then trigger the animations.
                                  storyProvider.nextStory();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE4A70A),
                                padding: EdgeInsets.symmetric(
                                  horizontal: screen.widthP(10),
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                storyProvider.isLastStory
                                    ? 'Get Started'
                                    : 'Next',
                                style: TextStyle(
                                  fontSize: screen.widthP(4),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // --- Dot Indicators (no animation needed here, updates via Provider.watch) ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: screen.heightP(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  storyProvider.storiesCount,
                  (index) => Container(
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
          ),
        ],
      ),
    );
  }
}
