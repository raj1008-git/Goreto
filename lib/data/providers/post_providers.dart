import 'package:flutter/material.dart';
import 'package:goreto/data/datasources/remote/post_api_service.dart';
import 'package:image_picker/image_picker.dart';

class PostProvider with ChangeNotifier {
  final PostApiService _postService = PostApiService();

  Future<bool> createPost({
    required String description,
    required List<String> locationIds,
    required List<String> categoryIds,
    required List<XFile> images,
  }) async {
    final result = await _postService.createPost(
      description: description,
      locationIds: locationIds,
      categoryIds: categoryIds,
      images: images,
    );

    return result != null && result['post_id'] != null;
  }
}
