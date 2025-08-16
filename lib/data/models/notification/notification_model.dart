// // lib/data/models/notification_model.dart
// class NotificationModel {
//   final int id;
//   final String title;
//   final String content;
//   final int userId;
//   final int postId;
//   final String createdAt;
//   final String updatedAt;
//   final PostInfo? post;
//
//   NotificationModel({
//     required this.id,
//     required this.title,
//     required this.content,
//     required this.userId,
//     required this.postId,
//     required this.createdAt,
//     required this.updatedAt,
//     this.post,
//   });
//
//   factory NotificationModel.fromJson(Map<String, dynamic> json) {
//     return NotificationModel(
//       id: json['id'],
//       title: json['title'],
//       content: json['content'],
//       userId: json['user_id'],
//       postId: json['post_id'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//       post: json['post'] != null ? PostInfo.fromJson(json['post']) : null,
//     );
//   }
// }
//
// class PostInfo {
//   final int id;
//   final String description;
//
//   PostInfo({required this.id, required this.description});
//
//   factory PostInfo.fromJson(Map<String, dynamic> json) {
//     return PostInfo(id: json['id'], description: json['description']);
//   }
// }
//
// class NotificationResponse {
//   final int currentPage;
//   final List<NotificationModel> data;
//   final int total;
//
//   NotificationResponse({
//     required this.currentPage,
//     required this.data,
//     required this.total,
//   });
//
//   factory NotificationResponse.fromJson(Map<String, dynamic> json) {
//     return NotificationResponse(
//       currentPage: json['current_page'],
//       data: (json['data'] as List)
//           .map((item) => NotificationModel.fromJson(item))
//           .toList(),
//       total: json['total'],
//     );
//   }
// }
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
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
    this.post,
    this.isRead = false,
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
      isRead: json['is_read'] ?? false,
    );
  }

  // Create from real-time data
  factory NotificationModel.fromRealTime(Map<String, dynamic> data) {
    final now = DateTime.now().toIso8601String();
    return NotificationModel(
      id: data['id'] ?? 0,
      title: data['title'] ?? 'New Notification',
      content: data['content'] ?? '',
      userId: data['user_id'] ?? 0,
      postId: data['post_id'] ?? 0,
      createdAt: now,
      updatedAt: now,
      isRead: false,
    );
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? content,
    int? userId,
    int? postId,
    String? createdAt,
    String? updatedAt,
    PostInfo? post,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      postId: postId ?? this.postId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      post: post ?? this.post,
      isRead: isRead ?? this.isRead,
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
  final int unreadCount;

  NotificationResponse({
    required this.currentPage,
    required this.data,
    required this.total,
    required this.unreadCount,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final notifications = (json['data'] as List)
        .map((item) => NotificationModel.fromJson(item))
        .toList();

    final unreadCount = notifications.where((n) => !n.isRead).length;

    return NotificationResponse(
      currentPage: json['current_page'],
      data: notifications,
      total: json['total'],
      unreadCount: unreadCount,
    );
  }
}
