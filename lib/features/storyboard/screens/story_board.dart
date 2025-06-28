import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _animator = StoryboardAnimator(vsync: this);

    // Start initial animations
    _animator.runInitialAnimation();

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
    _animator.dispose();
    final storyProvider = Provider.of<StoryBoardProvider>(
      context,
      listen: false,
    );
    storyProvider.removeListener(_onStoryIndexChanged);
    super.dispose();
  }

  void _onStoryIndexChanged() {
    final storyProvider = Provider.of<StoryBoardProvider>(
      context,
      listen: false,
    );
    if (_currentProviderIndex != storyProvider.currentStoryIndex) {
      _currentProviderIndex = storyProvider.currentStoryIndex;
      _animator.triggerNextStoryAnimation(() => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = ScreenSize(context);
    final storyProvider = context.watch<StoryBoardProvider>();
    final currentStory = storyProvider.currentStory;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image with fade
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animator.imageOpacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _animator.imageOpacityAnimation.value,
                  child: Image.asset(
                    currentStory.imagePath,
                    fit: BoxFit.cover,
                    key: ValueKey(currentStory.imagePath),
                  ),
                );
              },
            ),
          ),

          // Animated content card
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: screen.heightP(10)),
              child: AnimatedBuilder(
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
                      child: StoryCard(
                        title: currentStory.title,
                        description: currentStory.description,
                        onPressed: () {
                          if (storyProvider.isLastStory) {
                            Navigator.pushReplacement(
                              context,
                              buildSlideTransition(
                                AppRoutes.getPage(AppRoutes.loginorregister),
                              ),
                            );
                          } else {
                            storyProvider.nextStory();
                          }
                        },
                        isLast: storyProvider.isLastStory,
                        width: screen.widthP(85),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Dots
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
