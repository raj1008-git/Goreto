import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../datasources/remote/social_post_api.dart';
import '../models/post/social_post_model.dart';

class SocialPostApiProvider with ChangeNotifier {
  late final SocialPostApiService _service;
  List<PostModel> _posts = [];
  bool _isLoading = false;
  String? _error;

  // Pagination support for future use
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreData = true;

  SocialPostApiProvider() {
    _service = SocialPostApiService(Dio()); // Pass Dio explicitly
  }

  // Getters
  List<PostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMoreData => _hasMoreData;

  Future<void> fetchPosts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getAllPosts(page: _currentPage);

      if (refresh || _currentPage == 1) {
        _posts = response.posts;
      } else {
        _posts.addAll(response.posts);
      }

      // Update pagination info
      _currentPage = response.currentPage;
      _totalPages = response.lastPage;
      _hasMoreData = response.currentPage < response.lastPage;

      _error = null;
    } catch (e) {
      print('❌ Error fetching social posts: $e');
      _error = 'Failed to load posts. Please try again.';

      if (_currentPage == 1) {
        _posts = [];
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMorePosts() async {
    if (!_hasMoreData || _isLoading) return;

    _currentPage++;
    await fetchPosts();
  }

  Future<String> toggleBookmark(int postId) async {
    try {
      final message = await _service.toggleBookmark(postId);
      return message;
    } catch (e) {
      print('❌ Error toggling bookmark: $e');
      throw Exception('Failed to toggle bookmark');
    }
  }

  // Method to refresh posts
  Future<void> refreshPosts() async {
    await fetchPosts(refresh: true);
  }

  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Response model for paginated posts
class PostsResponse {
  final List<PostModel> posts;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PostsResponse({
    required this.posts,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PostsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] ?? [];
    final List<PostModel> posts = data
        .map((json) => PostModel.fromJson(json))
        .toList();

    return PostsResponse(
      posts: posts,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      total: json['total'] ?? 0,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}
