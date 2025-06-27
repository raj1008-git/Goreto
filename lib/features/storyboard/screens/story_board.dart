// lib/features/auth/screens/story_board_screen.dart
import 'package:flutter/material.dart';
import 'package:goreto/core/utils/media_query_helper.dart';
import 'package:goreto/routes/app_routes.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart'; // Import Provider

import '../providers/story_board_provider.dart';

class StoryBoardScreen extends StatelessWidget {
  const StoryBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Now you can directly consume the provider that's available from main.dart
    final screen = ScreenSize(context);
    // Using context.watch to rebuild the widget when StoryBoardProvider notifies listeners
    final storyProvider = context.watch<StoryBoardProvider>();
    final currentStory = storyProvider.currentStory;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: Image.asset(currentStory.imagePath, fit: BoxFit.cover),
            ),
          ),

          // Content Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: screen.heightP(10)),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: Container(
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
                          // Access the provider without listening (context.read) for actions
                          // but since the button text changes, context.watch or Consumer is fine for the whole widget
                          if (storyProvider.isLastStory) {
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                type: PageTransitionType.fade,
                                duration: const Duration(milliseconds: 550),
                                child: AppRoutes.getPage(AppRoutes.dashboard),
                                settings: const RouteSettings(
                                  name: AppRoutes.dashboard,
                                ),
                              ),
                            );
                          } else {
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
                          storyProvider.isLastStory ? 'Get Started' : 'Next',
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
            ),
          ),

          // Dot Indicators
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
