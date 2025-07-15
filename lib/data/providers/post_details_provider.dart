import 'package:flutter/material.dart';
import 'package:goreto/data/datasources/remote/post_api_service.dart';

import '../models/post/post_details_provider.dart';

class PostDetailProvider with ChangeNotifier {
  final PostApiService _apiService = PostApiService();

  PostDetailModel? postDetail;
  bool isLoading = false;

  Future<void> loadPostDetail(int postId) async {
    isLoading = true;
    notifyListeners();

    postDetail = await _apiService.fetchPostDetail(postId);

    isLoading = false;
    notifyListeners();
  }
}
