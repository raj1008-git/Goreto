// // comment_model.dart
// class CommentModel {
//   final int id;
//   final String review;
//   final int userId;
//   final int postId;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final CommentUser user;
//
//   CommentModel({
//     required this.id,
//     required this.review,
//     required this.userId,
//     required this.postId,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.user,
//   });
//
//   factory CommentModel.fromJson(Map<String, dynamic> json) {
//     return CommentModel(
//       id: json['id'],
//       review: json['review'] ?? '',
//       userId: json['user_id'],
//       postId: json['post_id'],
//       createdAt: DateTime.parse(json['created_at']),
//       updatedAt: DateTime.parse(json['updated_at']),
//       user: CommentUser.fromJson(json['user']),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'review': review,
//       'user_id': userId,
//       'post_id': postId,
//       'created_at': createdAt.toIso8601String(),
//       'updated_at': updatedAt.toIso8601String(),
//       'user': user.toJson(),
//     };
//   }
// }
//
// class CommentUser {
//   final int id;
//   final String name;
//   final String email;
//   final String? profilePictureUrl;
//
//   CommentUser({
//     required this.id,
//     required this.name,
//     required this.email,
//     this.profilePictureUrl,
//   });
//
//   factory CommentUser.fromJson(Map<String, dynamic> json) {
//     return CommentUser(
//       id: json['id'],
//       name: json['name'] ?? 'Unknown User',
//       email: json['email'] ?? '',
//       profilePictureUrl: json['profile_picture_url'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'email': email,
//       'profile_picture_url': profilePictureUrl,
//     };
//   }
// }
//
// // Response model for paginated comments
// class CommentsResponse {
//   final List<CommentModel> comments;
//   final int currentPage;
//   final int lastPage;
//   final int total;
//   final String? nextPageUrl;
//   final String? prevPageUrl;
//
//   CommentsResponse({
//     required this.comments,
//     required this.currentPage,
//     required this.lastPage,
//     required this.total,
//     this.nextPageUrl,
//     this.prevPageUrl,
//   });
//
//   factory CommentsResponse.fromJson(Map<String, dynamic> json) {
//     final List<dynamic> data = json['data'] ?? [];
//     final List<CommentModel> comments = data
//         .map((json) => CommentModel.fromJson(json))
//         .toList();
//
//     return CommentsResponse(
//       comments: comments,
//       currentPage: json['current_page'] ?? 1,
//       lastPage: json['last_page'] ?? 1,
//       total: json['total'] ?? 0,
//       nextPageUrl: json['next_page_url'],
//       prevPageUrl: json['prev_page_url'],
//     );
//   }
// }
//
// // like_model.dart
// class LikeModel {
//   final int userId;
//   final String name;
//   final String? profilePictureUrl;
//
//   LikeModel({required this.userId, required this.name, this.profilePictureUrl});
//
//   factory LikeModel.fromJson(Map<String, dynamic> json) {
//     return LikeModel(
//       userId: json['user_id'],
//       name: json['name'] ?? 'Unknown User',
//       profilePictureUrl: json['profile_picture_url'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'user_id': userId,
//       'name': name,
//       'profile_picture_url': profilePictureUrl,
//     };
//   }
// }
//
// class LikeResponse {
//   final String postId;
//   final int totalLikes;
//   final List<LikeModel> likedBy;
//
//   LikeResponse({
//     required this.postId,
//     required this.totalLikes,
//     required this.likedBy,
//   });
//
//   factory LikeResponse.fromJson(Map<String, dynamic> json) {
//     final List<dynamic> likedByData = json['liked_by'] ?? [];
//     final List<LikeModel> likedBy = likedByData
//         .map((json) => LikeModel.fromJson(json))
//         .toList();
//
//     return LikeResponse(
//       postId: json['post_id'].toString(),
//       totalLikes: json['total_likes'] ?? 0,
//       likedBy: likedBy,
//     );
//   }
// }
//
// class PostLikeResponse {
//   final String message;
//   final int likes;
//
//   PostLikeResponse({required this.message, required this.likes});
//
//   factory PostLikeResponse.fromJson(Map<String, dynamic> json) {
//     return PostLikeResponse(
//       message: json['message'] ?? '',
//       likes: json['likes'] ?? 0,
//     );
//   }
// }
// comment_model.dart
class CommentModel {
  final int id;
  final String review;
  final int userId;
  final int postId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CommentUser user;

  CommentModel({
    required this.id,
    required this.review,
    required this.userId,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: _parseToInt(json['id']),
      review: json['review'] ?? '',
      userId: _parseToInt(json['user_id']),
      postId: _parseToInt(json['post_id']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: CommentUser.fromJson(json['user']),
    );
  }

  // Helper method to safely parse int values
  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    return 0; // Default fallback
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'review': review,
      'user_id': userId,
      'post_id': postId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

class CommentUser {
  final int id;
  final String name;
  final String email;
  final String? profilePictureUrl;

  CommentUser({
    required this.id,
    required this.name,
    required this.email,
    this.profilePictureUrl,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: _parseToInt(json['id']),
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? '',
      profilePictureUrl: json['profile_picture_url'],
    );
  }

  // Helper method to safely parse int values
  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    return 0; // Default fallback
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_picture_url': profilePictureUrl,
    };
  }
}

// Response model for paginated comments
class CommentsResponse {
  final List<CommentModel> comments;
  final int currentPage;
  final int lastPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  CommentsResponse({
    required this.comments,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> data = json['data'] ?? [];
    final List<CommentModel> comments = data
        .map((json) => CommentModel.fromJson(json))
        .toList();

    return CommentsResponse(
      comments: comments,
      currentPage: _parseToInt(json['current_page'] ?? 1),
      lastPage: _parseToInt(json['last_page'] ?? 1),
      total: _parseToInt(json['total'] ?? 0),
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  // Helper method to safely parse int values
  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    return 0; // Default fallback
  }
}

// like_model.dart
class LikeModel {
  final int userId;
  final String name;
  final String? profilePictureUrl;

  LikeModel({required this.userId, required this.name, this.profilePictureUrl});

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      userId: _parseToInt(json['user_id']),
      name: json['name'] ?? 'Unknown User',
      profilePictureUrl: json['profile_picture_url'],
    );
  }

  // Helper method to safely parse int values
  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    return 0; // Default fallback
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'profile_picture_url': profilePictureUrl,
    };
  }
}

class LikeResponse {
  final String postId;
  final int totalLikes;
  final List<LikeModel> likedBy;

  LikeResponse({
    required this.postId,
    required this.totalLikes,
    required this.likedBy,
  });

  factory LikeResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> likedByData = json['liked_by'] ?? [];
    final List<LikeModel> likedBy = likedByData
        .map((json) => LikeModel.fromJson(json))
        .toList();

    return LikeResponse(
      postId: json['post_id'].toString(),
      totalLikes: _parseToInt(json['total_likes'] ?? 0),
      likedBy: likedBy,
    );
  }

  // Helper method to safely parse int values
  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    return 0; // Default fallback
  }
}

class PostLikeResponse {
  final String message;
  final int likes;

  PostLikeResponse({required this.message, required this.likes});

  factory PostLikeResponse.fromJson(Map<String, dynamic> json) {
    return PostLikeResponse(
      message: json['message'] ?? '',
      likes: _parseToInt(json['likes'] ?? 0),
    );
  }

  // Helper method to safely parse int values
  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    return 0; // Default fallback
  }
}
