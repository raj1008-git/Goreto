// lib/data/models/notification_model.dart
class NotificationModel {
  final int id;
  final String title;
  final String content;
  final int userId;
  final int postId;
  final String createdAt;
  final String updatedAt;
  final PostInfo? post;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
    this.post,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      userId: json['user_id'],
      postId: json['post_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      post: json['post'] != null ? PostInfo.fromJson(json['post']) : null,
    );
  }
}

class PostInfo {
  final int id;
  final String description;

  PostInfo({required this.id, required this.description});

  factory PostInfo.fromJson(Map<String, dynamic> json) {
    return PostInfo(id: json['id'], description: json['description']);
  }
}

class NotificationResponse {
  final int currentPage;
  final List<NotificationModel> data;
  final int total;

  NotificationResponse({
    required this.currentPage,
    required this.data,
    required this.total,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      currentPage: json['current_page'],
      data: (json['data'] as List)
          .map((item) => NotificationModel.fromJson(item))
          .toList(),
      total: json['total'],
    );
  }
}
