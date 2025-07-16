import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/dio_client.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/post/my_post_model.dart';
import '../../models/post/post_details_provider.dart';
import '../../models/post/post_review_model.dart';

class PostApiService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>?> createPost({
    required String description,
    required List<String> locationIds,
    required List<String> categoryIds,
    required List<XFile> images,
  }) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry("description", description));

      for (final id in locationIds) {
        formData.fields.add(MapEntry("location_ids[]", id));
      }

      for (final id in categoryIds) {
        formData.fields.add(MapEntry("category_ids[]", id));
      }

      for (var image in images) {
        formData.files.add(
          MapEntry(
            "contents[]",
            await MultipartFile.fromFile(image.path, filename: image.name),
          ),
        );
      }

      final response = await _dio.post(
        ApiEndpoints.createPost,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      print('📡 POST /posts');
      print('📦 Status: ${response.statusCode}');
      print('📥 Response: ${response.data}');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return response.data;
      }

      print('⚠️ Unexpected status code: ${response.statusCode}');
      return null;
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('❌ Server error: ${e.response?.data}');
        print('❌ Status code: ${e.response?.statusCode}');
      } else {
        print('❌ Unexpected error: $e');
      }
      return null;
    }
  }

  // Added method to fetch my posts
  Future<List<MyPostModel>> fetchMyPosts() async {
    try {
      final response = await _dio.get(ApiEndpoints.myPosts);

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((e) => MyPostModel.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load posts");
      }
    } catch (e) {
      print("Fetch my posts error: $e");
      return [];
    }
  }

  Future<PostDetailModel?> fetchPostDetail(int postId) async {
    try {
      final response = await _dio.get(
        "${ApiEndpoints.baseUrl}/posts/$postId",
        options: Options(headers: {"Accept": "application/json"}),
      );

      if (response.statusCode == 200) {
        return PostDetailModel.fromJson(response.data);
      } else {
        print("Failed to load post detail. Status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching post detail: $e");
      return null;
    }
  }

  Future<bool> editPost({
    required int postId,
    required String description,
    required List<String> locationIds,
    required List<String> categoryIds,
    required List<XFile> images,
  }) async {
    try {
      final formData = FormData();

      formData.fields.add(MapEntry("description", description));

      for (final id in locationIds) {
        formData.fields.add(MapEntry("location_ids[]", id));
      }

      for (final id in categoryIds) {
        formData.fields.add(MapEntry("category_ids[]", id));
      }

      for (var image in images) {
        formData.files.add(
          MapEntry(
            "contents[]",
            await MultipartFile.fromFile(image.path, filename: image.name),
          ),
        );
      }

      final response = await _dio.post(
        "${ApiEndpoints.baseUrl}/posts/$postId",
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        print('✅ Post updated: ${response.data}');
        return true;
      }

      print('⚠️ Failed to update post: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error editing post: $e');
      return false;
    }
  }

  Future<bool> deletePost(int postId) async {
    try {
      final response = await _dio.delete(
        "${ApiEndpoints.baseUrl}/posts/$postId",
        options: Options(headers: {"Accept": "application/json"}),
      );

      if (response.statusCode == 200) {
        print("✅ Post deleted: ${response.data}");
        return true;
      } else {
        print("⚠️ Delete failed with status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("❌ Error deleting post: $e");
      return false;
    }
  }

  Future<List<PostReviewModel>> fetchPostReviews(int postId) async {
    try {
      final response = await _dio.get(
        "${ApiEndpoints.baseUrl}/post-reviews/$postId",
        options: Options(headers: {"Accept": "application/json"}),
      );

      print('📡 GET /post-reviews/$postId');
      print('📦 Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((e) => PostReviewModel.fromJson(e)).toList();
      } else {
        print("⚠️ Failed to load reviews. Status: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('❌ Server error: ${e.response?.data}');
        print('❌ Status code: ${e.response?.statusCode}');
      } else {
        print("❌ Unexpected error fetching reviews: $e");
      }
      return [];
    }
  }
}
