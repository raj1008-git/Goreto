// lib/data/datasources/remote/bookmark_api_service.dart

import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

import '../../models/post/social_post_model.dart';

class BookmarkApiService {
  final Dio dio;

  BookmarkApiService(this.dio);

  Future<List<PostModel>> getBookmarkedPosts() async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.get(
      ApiEndpoints
          .postBookmarks, // Define this as '/api/post-bookmarks' in constants
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final List<dynamic> data = response.data['data'];

    // Extract PostModel from nested 'post' object in each bookmark
    return data.map<PostModel>((bookmark) {
      final postJson = bookmark['post'];
      return PostModel.fromJson(postJson);
    }).toList();
  }
}
