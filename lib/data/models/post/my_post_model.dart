import 'package:goreto/core/constants/api_endpoints.dart';

class MyPostModel {
  final int id;
  final String description;
  final List<String> imageUrls;

  MyPostModel({
    required this.id,
    required this.description,
    required this.imageUrls,
  });

  factory MyPostModel.fromJson(Map<String, dynamic> json) {
    final contents = json['post_contents'] as List<dynamic>? ?? [];

    return MyPostModel(
      id: json['id'],
      description: json['description'],
      imageUrls: contents
          .map((e) => "${ApiEndpoints.storageBaseUrl}/${e['content_path']}")
          .toList()
          .cast<String>(),
    );
  }
}
