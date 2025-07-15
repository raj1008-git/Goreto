import 'package:flutter/material.dart';
import 'package:goreto/data/datasources/remote/post_api_service.dart';

import '../models/post/my_post_model.dart';

class MyPostProvider with ChangeNotifier {
  final PostApiService _service = PostApiService();

  List<MyPostModel> _posts = [];
  List<MyPostModel> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchMyPosts() async {
    _isLoading = true;
    notifyListeners();

    _posts = await _service.fetchMyPosts();

    _isLoading = false;
    notifyListeners();
  }
}
