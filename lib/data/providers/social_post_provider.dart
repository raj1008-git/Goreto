import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../datasources/remote/social_post_api.dart';
import '../models/post/social_post_model.dart';

class SocialPostApiProvider with ChangeNotifier {
  late final SocialPostApiService _service;
  List<PostModel> _posts = [];
  bool _isLoading = false;

  SocialPostApiProvider() {
    _service = SocialPostApiService(Dio()); // ✅ Pass Dio explicitly
  }

  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _service.getAllPosts();
    } catch (e) {
      print('❌ Error fetching social posts: $e');
      _posts = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ Bookmark toggle function
  Future<String> toggleBookmark(int postId) async {
    try {
      final message = await _service.toggleBookmark(postId);
      return message;
    } catch (e) {
      print('❌ Error toggling bookmark: $e');
      return 'Failed to toggle bookmark';
    }
  }
}
