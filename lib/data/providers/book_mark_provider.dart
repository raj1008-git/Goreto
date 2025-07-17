// lib/data/providers/bookmark_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../datasources/remote/book_mark_api_service.dart';
import '../models/post/social_post_model.dart';

class BookmarkProvider with ChangeNotifier {
  late final BookmarkApiService _service;

  List<PostModel> _bookmarkedPosts = [];
  bool _isLoading = false;

  BookmarkProvider() {
    _service = BookmarkApiService(Dio());
  }

  List<PostModel> get bookmarkedPosts => _bookmarkedPosts;
  bool get isLoading => _isLoading;

  Future<void> fetchBookmarkedPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookmarkedPosts = await _service.getBookmarkedPosts();
    } catch (e) {
      print('❌ Error fetching bookmarks: $e');
      _bookmarkedPosts = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
