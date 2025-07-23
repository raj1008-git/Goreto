class PostDetailModel {
  final int id;
  final String description;
  final String status;
  final int likes;
  final int userId;
  final String createdAt;
  final String updatedAt;
  final UserInfo userInfo;
  final List<PostCategoryModel> postCategory;
  final List<PostContentModel> postContents;
  final List<PostLocationModel> postLocations;

  PostDetailModel({
    required this.id,
    required this.description,
    required this.status,
    required this.likes,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.userInfo,
    required this.postCategory,
    required this.postContents,
    required this.postLocations,
  });

  factory PostDetailModel.fromJson(Map<String, dynamic> json) {
    return PostDetailModel(
      id: json['id'],
      description: json['description'],
      status: json['status'],
      likes: json['likes'],
      userId: json['user_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      userInfo: UserInfo.fromJson(json['user_info']),
      postCategory: (json['post_category'] as List? ?? [])
          .map((e) => PostCategoryModel.fromJson(e))
          .toList(),
      postContents: (json['post_contents'] as List? ?? [])
          .map((e) => PostContentModel.fromJson(e))
          .toList(),
      postLocations: (json['post_locations'] as List? ?? [])
          .map((e) => PostLocationModel.fromJson(e))
          .toList(),
    );
  }
}

class UserInfo {
  final int id;
  final String name;
  final String profilePictureUrl;

  UserInfo({
    required this.id,
    required this.name,
    required this.profilePictureUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      name: json['name'],
      profilePictureUrl: json['profile_picture_url'],
    );
  }
}

class PostCategoryModel {
  final int id;
  final int postId;
  final int categoryId;
  final String createdAt;
  final String updatedAt;
  final Category category;

  PostCategoryModel({
    required this.id,
    required this.postId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
  });

  factory PostCategoryModel.fromJson(Map<String, dynamic> json) {
    return PostCategoryModel(
      id: json['id'],
      postId: json['post_id'],
      categoryId: json['category_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      category: Category.fromJson(json['category']),
    );
  }
}

class Category {
  final int id;
  final String category;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      category: json['category'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class PostContentModel {
  final int id;
  final String contentPath;
  final int postId;
  final String createdAt;
  final String updatedAt;

  PostContentModel({
    required this.id,
    required this.contentPath,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostContentModel.fromJson(Map<String, dynamic> json) {
    return PostContentModel(
      id: json['id'],
      contentPath: json['content_path'],
      postId: json['post_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class PostLocationModel {
  final int id;
  final int postId;
  final int locationId;
  final String createdAt;
  final String updatedAt;
  final Location location;

  PostLocationModel({
    required this.id,
    required this.postId,
    required this.locationId,
    required this.createdAt,
    required this.updatedAt,
    required this.location,
  });

  factory PostLocationModel.fromJson(Map<String, dynamic> json) {
    return PostLocationModel(
      id: json['id'],
      postId: json['post_id'],
      locationId: json['location_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      location: Location.fromJson(json['location']),
    );
  }
}

class Location {
  final int id;
  final dynamic placeId; // Changed to dynamic because sometimes it's string
  final String name;
  final String latitude;
  final String longitude;
  final int cityId;
  final String createdAt;
  final String updatedAt;
  final int categoryId;
  final String description;
  final double? averageRating;

  Location({
    required this.id,
    required this.placeId,
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
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      cityId: json['city_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      categoryId: json['category_id'],
      description: json['description'],
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] as num).toDouble()
          : null,
    );
  }
}
