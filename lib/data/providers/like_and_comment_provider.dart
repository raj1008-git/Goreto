import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../datasources/remote/like_comment_api_service.dart';
import '../models/post/comment_model.dart';

class LikeCommentProvider with ChangeNotifier {
  late final LikeCommentApiService _service;

  // Like related state
  Map<int, int> _postLikeCounts = {}; // postId -> like count
  Map<int, List<LikeModel>> _postLikers = {}; // postId -> list of likers
  Map<int, bool> _likeLoadingStates = {}; // postId -> loading state

  // Comment related state
  Map<int, List<CommentModel>> _postComments = {}; // postId -> list of comments
  Map<int, bool> _commentLoadingStates = {}; // postId -> loading state
  Map<int, bool> _addingCommentStates = {}; // postId -> adding comment state
  Map<int, int> _commentCounts = {}; // postId -> comment count
  Map<int, bool> _showCommentsStates = {}; // postId -> show comments state

  // Optimistic update tracking
  Map<int, CommentModel?> _optimisticComments =
      {}; // postId -> optimistic comment

  String? _error;

  LikeCommentProvider() {
    _service = LikeCommentApiService(Dio());
  }

  // Getters
  String? get error => _error;

  int getLikeCount(int postId) => _postLikeCounts[postId] ?? 0;
  List<LikeModel> getLikers(int postId) => _postLikers[postId] ?? [];
  bool isLikeLoading(int postId) => _likeLoadingStates[postId] ?? false;

  List<CommentModel> getComments(int postId) {
    final comments = List<CommentModel>.from(_postComments[postId] ?? []);

    // Add optimistic comment at the beginning if exists
    final optimisticComment = _optimisticComments[postId];
    if (optimisticComment != null) {
      comments.insert(0, optimisticComment);
    }

    return comments;
  }

  bool isCommentLoading(int postId) => _commentLoadingStates[postId] ?? false;
  bool isAddingComment(int postId) => _addingCommentStates[postId] ?? false;
  int getCommentCount(int postId) {
    final baseCount = _commentCounts[postId] ?? 0;
    final hasOptimistic = _optimisticComments[postId] != null;
    return hasOptimistic ? baseCount + 1 : baseCount;
  }

  bool isShowingComments(int postId) => _showCommentsStates[postId] ?? false;

  // Initialize post data
  void initializePost(int postId, int initialLikes) {
    _postLikeCounts[postId] = initialLikes;
    _postLikers[postId] = [];
    _postComments[postId] = [];
    _likeLoadingStates[postId] = false;
    _commentLoadingStates[postId] = false;
    _addingCommentStates[postId] = false;
    _commentCounts[postId] = 0;
    _showCommentsStates[postId] = false;
    _optimisticComments[postId] = null;
  }

  // ===== OPTIMISTIC UPDATE METHODS =====

  // Set optimistic like state
  void setOptimisticLike(int postId, bool isLiked) {
    final currentCount = _postLikeCounts[postId] ?? 0;

    if (isLiked) {
      _postLikeCounts[postId] = currentCount + 1;
    } else {
      _postLikeCounts[postId] = (currentCount > 0) ? currentCount - 1 : 0;
    }

    notifyListeners();
  }

  // Add optimistic comment
  void addOptimisticComment(int postId, String commentText) {
    // Create a temporary comment with current user info
    // Note: You might need to get current user info from another provider or service
    final optimisticComment = CommentModel(
      id: -1, // Temporary ID for optimistic comment
      review: commentText,
      userId: -1, // Temporary user ID
      postId: postId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      user: CommentUser(
        id: -1, // Temporary user ID
        name: 'You', // Or get from current user
        email: 'temp@temp.com', // Temporary email
        profilePictureUrl: null, // Or get from current user
      ),
    );

    _optimisticComments[postId] = optimisticComment;

    // Show comments section if not already showing
    _showCommentsStates[postId] = true;

    notifyListeners();
  }

  // Remove optimistic comment (on error)
  void removeOptimisticComment(int postId) {
    _optimisticComments[postId] = null;
    notifyListeners();
  }

  // ===== EXISTING METHODS (Updated) =====

  // Toggle like for a post
  Future<void> toggleLike(int postId) async {
    _likeLoadingStates[postId] = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.toggleLike(postId);

      // Update with actual server response
      _postLikeCounts[postId] = response.likes;

      // Optionally fetch updated likers list
      await _fetchPostLikers(postId);

      _error = null;
    } catch (e) {
      print('❌ Error toggling like: $e');
      _error = 'Failed to toggle like. Please try again.';
      rethrow; // Re-throw so PostCard can handle the error
    } finally {
      _likeLoadingStates[postId] = false;
      notifyListeners();
    }
  }

  // Fetch who liked the post
  Future<void> fetchPostLikers(int postId) async {
    await _fetchPostLikers(postId);
  }

  Future<void> _fetchPostLikers(int postId) async {
    try {
      final response = await _service.getPostLikes(postId);
      _postLikers[postId] = response.likedBy;
      _postLikeCounts[postId] = response.totalLikes;
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching post likers: $e');
      // Don't show error for this background operation
    }
  }

  // Toggle comments visibility
  void toggleCommentsVisibility(int postId) {
    _showCommentsStates[postId] = !(_showCommentsStates[postId] ?? false);

    // If showing comments for first time, fetch them
    if (_showCommentsStates[postId]! && _postComments[postId]!.isEmpty) {
      fetchComments(postId);
    }

    notifyListeners();
  }

  // Fetch comments for a post
  Future<void> fetchComments(int postId, {int page = 1}) async {
    _commentLoadingStates[postId] = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.getPostComments(postId, page: page);

      if (page == 1) {
        _postComments[postId] = response.comments;
      } else {
        _postComments[postId]!.addAll(response.comments);
      }

      _commentCounts[postId] = response.total;
      _error = null;
    } catch (e) {
      print('❌ Error fetching comments: $e');
      _error = 'Failed to load comments. Please try again.';
    } finally {
      _commentLoadingStates[postId] = false;
      notifyListeners();
    }
  }

  Future<bool> addComment(int postId, String review) async {
    if (review.trim().isEmpty) {
      _error = 'Comment cannot be empty';
      notifyListeners();
      return false;
    }

    _addingCommentStates[postId] = true;
    _error = null;
    notifyListeners();

    try {
      final newComment = await _service.addComment(postId, review.trim());

      // Remove optimistic comment and add real one
      _optimisticComments[postId] = null;

      // Add the new comment to the beginning of the list
      if (_postComments[postId] == null) {
        _postComments[postId] = [];
      }
      _postComments[postId]!.insert(0, newComment);

      // Update comment count (don't add 1 since optimistic was already counted)
      _commentCounts[postId] = (_commentCounts[postId] ?? 0) + 1;

      // Show comments if not already showing
      _showCommentsStates[postId] = true;

      _error = null;

      // Optionally refresh comments to get complete user details
      // You can uncomment this line if you want to ensure user details are always complete
      // Future.delayed(Duration(milliseconds: 500), () => fetchComments(postId));

      return true;
    } catch (e) {
      print('❌ Error adding comment: $e');
      _error = 'Failed to add comment. Please try again.';
      rethrow; // Re-throw so PostCard can handle the error
    } finally {
      _addingCommentStates[postId] = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh post data
  Future<void> refreshPostData(int postId) async {
    await Future.wait([
      _fetchPostLikers(postId),
      if (_showCommentsStates[postId] ?? false) fetchComments(postId),
    ]);
  }
}
