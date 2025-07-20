// class PostModel {
//   final int id;
//   final String description;
//   final String imageUrl;
//   final String location;
//   final String category;
//   final DateTime createdAt;
//
//   PostModel({
//     required this.id,
//     required this.description,
//     required this.imageUrl,
//     required this.location,
//     required this.category,
//     required this.createdAt,
//   });
//
//   factory PostModel.fromJson(Map<String, dynamic> json) {
//     final rawUrl = json['post_contents']?.isNotEmpty == true
//         ? json['post_contents'][0]['content_url'] as String
//         : '';
//
//     // ✅ Replace 'localhost' with your computer's local IP
//     final imagePath = rawUrl.replaceFirst(
//       'localhost',
//       '192.168.254.10',
//     ); // ← change this IP
//
//     final locationName = json['post_locations']?.isNotEmpty == true
//         ? json['post_locations'][0]['location']['name']
//         : '';
//
//     final categoryName = json['post_category']?.isNotEmpty == true
//         ? json['post_category'][0]['category']['category']
//         : '';
//
//     return PostModel(
//       id: json['id'],
//       description: json['description'],
//       imageUrl: imagePath,
//       location: locationName,
//       category: categoryName,
//       createdAt: DateTime.parse(json['created_at']),
//     );
//   }
// }
import 'package:goreto/core/constants/api_endpoints.dart';

class PostModel {
  final int id;
  final String description;
  final String status;
  final int likes;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserInfo userInfo;
  final List<PostCategory> postCategories;
  final List<PostContent> postContents;
  final List<PostLocation> postLocations;

  // Computed properties for easier access
  String get imageUrl =>
      postContents.isNotEmpty ? postContents.first.contentUrl : '';
  String get location => postLocations.isNotEmpty
      ? postLocations.first.location.name
      : 'Unknown Location';
  String get category => postCategories.isNotEmpty
      ? postCategories.first.category.category
      : 'Uncategorized';
  String get userName => userInfo.name;
  String? get userProfilePicture => userInfo.profilePictureUrl;

  PostModel({
    required this.id,
    required this.description,
    required this.status,
    required this.likes,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.userInfo,
    required this.postCategories,
    required this.postContents,
    required this.postLocations,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      description: json['description'] ?? '',
      status: json['status'] ?? 'active',
      likes: json['likes'] ?? 0,
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      userInfo: UserInfo.fromJson(json['user_info']),
      postCategories:
          (json['post_category'] as List<dynamic>?)
              ?.map((e) => PostCategory.fromJson(e))
              .toList() ??
          [],
      postContents:
          (json['post_contents'] as List<dynamic>?)
              ?.map((e) => PostContent.fromJson(e))
              .toList() ??
          [],
      postLocations:
          (json['post_locations'] as List<dynamic>?)
              ?.map((e) => PostLocation.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class UserInfo {
  final int id;
  final String name;
  final String? profilePictureUrl;

  UserInfo({required this.id, required this.name, this.profilePictureUrl});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      name: json['name'] ?? 'Unknown User',
      profilePictureUrl: json['profile_picture_url'],
    );
  }
}

class PostCategory {
  final int id;
  final int postId;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Category category;

  PostCategory({
    required this.id,
    required this.postId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  factory PostCategory.fromJson(Map<String, dynamic> json) {
    return PostCategory(
      id: json['id'],
      postId: json['post_id'],
      categoryId: json['category_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      category: Category.fromJson(json['category']),
    );
  }
}

class Category {
  final int id;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      category: json['category'] ?? 'Uncategorized',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class PostContent {
  final int id;
  final String contentPath;
  final int postId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String contentUrl;

  PostContent({
    required this.id,
    required this.contentPath,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
    required this.contentUrl,
  });

  factory PostContent.fromJson(Map<String, dynamic> json) {
    // Fix localhost URL if needed
    String rawUrl = json['content_url'] ?? '';
    String fixedUrl = rawUrl.replaceFirst(
      'localhost',
      '${ApiEndpoints.ip}',
    ); // Use your IP

    return PostContent(
      id: json['id'],
      contentPath: json['content_path'] ?? '',
      postId: json['post_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      contentUrl: fixedUrl,
    );
  }
}

class PostLocation {
  final int id;
  final int postId;
  final int locationId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Location location;

  PostLocation({
    required this.id,
    required this.postId,
    required this.locationId,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
  });

  factory PostLocation.fromJson(Map<String, dynamic> json) {
    return PostLocation(
      id: json['id'],
      postId: json['post_id'],
      locationId: json['location_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      location: Location.fromJson(json['location']),
    );
  }
}

class Location {
  final int id;
  final String? placeId;
  final String name;
  final String latitude;
  final String longitude;
  final int cityId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int categoryId;
  final String description;
  final double? averageRating;

  Location({
    required this.id,
    this.placeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.cityId,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryId,
    required this.description,
    this.averageRating,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      placeId: json['place_id'],
      name: json['name'] ?? 'Unknown Location',
      latitude: json['latitude'] ?? '0.0',
      longitude: json['longitude'] ?? '0.0',
      cityId: json['city_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      categoryId: json['category_id'] ?? 0,
      description: json['description'] ?? '',
      averageRating: json['average_rating']?.toDouble(),
    );
  }
}
