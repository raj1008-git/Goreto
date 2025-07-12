import 'package:flutter/material.dart';

import '../../../data/models/story/story_item_model.dart';

class StoryBoardProvider extends ChangeNotifier {
  int _currentStoryIndex = 0;

  // Define your story data here, or fetch it from a repository if dynamic
  final List<StoryItem> _stories = [
    StoryItem(
      imagePath: 'assets/images/story1.jpg', // Make sure you have these assets
      title: 'Get ready for the next trip',
      description: 'Let Goreto guide your next unforgettable journey.',
    ),
    StoryItem(
      imagePath: 'assets/images/story2.jpg',
      title: 'Navigate Smartly',
      description: 'Find rides, routes and local tips all in one place.',
    ),
    StoryItem(
      imagePath: 'assets/images/story3.jpg',
      title: 'Capture Moments',
      description: 'Explore Experience & Share Stories the Goreto way.',
    ),
  ];

  int get currentStoryIndex => _currentStoryIndex;
  StoryItem get currentStory => _stories[_currentStoryIndex];
  int get storiesCount => _stories.length;
  bool get isLastStory => _currentStoryIndex == _stories.length - 1;

  void nextStory() {
    if (_currentStoryIndex < _stories.length - 1) {
      _currentStoryIndex++;
      notifyListeners(); // Notify listeners to rebuild UI
    }
    // Note: Navigation logic is still handled by the UI (screen)
    // because it involves `BuildContext` and `Navigator`.
    // The provider only exposes the state (`isLastStory`).
  }

  // Potentially add a method to reset for replaying stories if needed
  void resetStories() {
    _currentStoryIndex = 0;
    notifyListeners();
  }
}
