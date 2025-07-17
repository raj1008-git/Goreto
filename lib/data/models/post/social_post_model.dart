import 'package:goreto/core/constants/api_endpoints.dart';

class PostModel {
  final int id;
  final String description;
  final String imageUrl;
  final String location;
  final String category;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.category,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final imagePath = json['post_contents']?.isNotEmpty == true
        ? json['post_contents'][0]['content_path']
        : '';
    final locationName = json['post_locations']?.isNotEmpty == true
        ? json['post_locations'][0]['location']['name']
        : '';
    final categoryName = json['post_category']?.isNotEmpty == true
        ? json['post_category'][0]['category']['category']
        : '';

    return PostModel(
      id: json['id'],
      description: json['description'],
      imageUrl: '${ApiEndpoints.baseUrl}/storage/$imagePath',
      location: locationName,
      category: categoryName,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
