import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

import '../../models/post/social_post_model.dart';

class SocialPostApiService {
  final Dio dio;

  SocialPostApiService(this.dio);

  Future<List<PostModel>> getAllPosts() async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.get(
      ApiEndpoints.posts, // This should be 'api/posts'
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    final List<dynamic> data = response.data['data'];
    return data.map((json) => PostModel.fromJson(json)).toList();
  }

  Future<String> toggleBookmark(int postId) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    final response = await dio.post(
      '${ApiEndpoints.tapbookmarks}/$postId',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response.data['message'] ?? 'Bookmark toggled.';
  }

  // lib/data/datasources/remote/bookmark_api_service.dart
}
