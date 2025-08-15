// import 'package:flutter/material.dart';
// import 'package:goreto/data/datasources/remote/post_api_service.dart';
//
// import '../models/post/post_details_provider.dart';
//
// class PostDetailProvider with ChangeNotifier {
//   final PostApiService _apiService = PostApiService();
//
//   PostDetailModel? postDetail;
//   bool isLoading = false;
//
//   Future<void> loadPostDetail(int postId) async {
//     isLoading = true;
//     notifyListeners();
//
//     postDetail = await _apiService.fetchPostDetail(postId);
//
//     isLoading = false;
//     notifyListeners();
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:goreto/data/datasources/remote/post_api_service.dart';
//
// import '../models/post/post_details_provider.dart';
//
// class PostDetailProvider with ChangeNotifier {
//   final PostApiService _apiService = PostApiService();
//
//   PostDetailModel? postDetail;
//   bool isLoading = false;
//   String? errorMessage;
//
//   Future<void> loadPostDetail(int postId) async {
//     isLoading = true;
//     errorMessage = null;
//     postDetail = null;
//     notifyListeners();
//
//     try {
//       print("🔍 Loading post detail for ID: $postId");
//       final result = await _apiService.fetchPostDetail(postId);
//
//       if (result != null) {
//         postDetail = result;
//         print("✅ Post detail loaded successfully");
//       } else {
//         errorMessage = "Failed to load post details";
//         print("❌ Post detail is null");
//       }
//     } catch (e) {
//       errorMessage = "Error loading post: $e";
//       print("❌ Error in loadPostDetail: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   void clearError() {
//     errorMessage = null;
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:goreto/data/datasources/remote/post_api_service.dart';

import '../models/post/post_details_provider.dart';

class PostDetailProvider with ChangeNotifier {
  final PostApiService _apiService = PostApiService();

  PostDetailModel? postDetail;
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadPostDetail(int postId) async {
    isLoading = true;
    errorMessage = null;
    postDetail = null;
    notifyListeners();

    try {
      print("🔍 Loading post detail for ID: $postId");
      final result = await _apiService.fetchPostDetail(postId);

      if (result != null) {
        postDetail = result;
        print("✅ Post detail loaded successfully");
      } else {
        errorMessage = "Failed to load post details";
        print("❌ Post detail is null");
      }
    } catch (e) {
      errorMessage = "Error loading post: $e";
      print("❌ Error in loadPostDetail: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
