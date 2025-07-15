import 'package:dio/dio.dart';
import 'package:goreto/core/constants/api_endpoints.dart';
import 'package:goreto/core/services/dio_client.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/post/my_post_model.dart';
import '../../models/post/post_details_provider.dart';

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
}
