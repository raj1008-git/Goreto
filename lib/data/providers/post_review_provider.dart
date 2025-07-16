import 'package:flutter/material.dart';

import '../datasources/remote/post_api_service.dart';
import '../models/post/post_review_model.dart';

class PostReviewProvider with ChangeNotifier {
  final PostApiService _api = PostApiService();
  List<PostReviewModel> reviews = [];
  bool isLoading = false;

  Future<void> fetchReviews(int postId) async {
    isLoading = true;
    notifyListeners();

    reviews = await _api.fetchPostReviews(postId);

    isLoading = false;
    notifyListeners();
  }
}
