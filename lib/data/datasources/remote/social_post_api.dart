import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/secure_storage_service.dart';

import '../../providers/social_post_provider.dart'; // For PostsResponse

class SocialPostApiService {
  final Dio dio;

  SocialPostApiService(this.dio);

  Future<PostsResponse> getAllPosts({int page = 1}) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found. Please login again.');
    }

    try {
      final response = await dio.get(
        ApiEndpoints.posts,
        queryParameters: {'page': page},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PostsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch posts: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access forbidden. Check your permissions.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Posts not found.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Check your internet connection.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timeout. Please try again.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }

  Future<String> toggleBookmark(int postId) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found. Please login again.');
    }

    try {
      final response = await dio.post(
        '${ApiEndpoints.tapbookmarks}/$postId',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['message'] ?? 'Bookmark updated successfully';
      } else {
        throw Exception('Failed to toggle bookmark: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (e.response?.statusCode == 403) {
        throw Exception('Access forbidden.');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Post not found.');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error. Please try again.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to toggle bookmark: $e');
    }
  }

  // Optional: Get bookmarked posts
  Future<PostsResponse> getBookmarkedPosts({int page = 1}) async {
    final storage = SecureStorageService();
    final token = await storage.read('access_token');

    if (token == null) {
      throw Exception('Access token not found');
    }

    try {
      final response = await dio.get(
        ApiEndpoints.postBookmarks,
        queryParameters: {'page': page},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return PostsResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch bookmarked posts');
      }
    } catch (e) {
      throw Exception('Error fetching bookmarked posts: $e');
    }
  }
}
