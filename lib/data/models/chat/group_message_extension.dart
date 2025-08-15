// lib/data/models/chat/group_message_extensions.dart

import 'message_model.dart';

/// Extensions for MessageModel to handle group-specific functionality
extension GroupMessageExtensions on MessageModel {
  /// Check if this message is from a group chat
  bool get isGroupMessage => chat?.isGroup == true;

  /// Get the group name if this is a group message
  String? get groupName => isGroupMessage ? chat?.name : null;

  /// Check if the message sender is the group creator
  bool isFromGroupCreator(String creatorId) {
    return chat?.createdBy == sentBy.toString();
  }

  /// Format message for group display with sender name
  String getDisplayText(String senderName) {
    if (isGroupMessage) {
      return messages; // For groups, we show sender name separately in UI
    }
    return messages; // For one-on-one, just show the message
  }

  /// Get message bubble color for group messages
  /// Different users can have different colors
  int getSenderColorIndex() {
    // Use sender ID to generate a consistent color index
    return sentBy % 8; // Assuming 8 different colors
  }
}

/// Model for group chat information that extends the base chat model
class GroupChatInfo {
  final int id;
  final String name;
  final bool isGroup;
  final String createdBy;
  final String createdAt;
  final String updatedAt;
  final String? imagePath;
  final List<GroupMember>? members;

  GroupChatInfo({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.imagePath,
    this.members,
  });

  factory GroupChatInfo.fromJson(Map<String, dynamic> json) {
    return GroupChatInfo(
      id: json['id'],
      name: json['name'],
      isGroup: json['is_group'] == 1,
      createdBy: json['created_by'].toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      imagePath: json['image_path'],
      members: json['members'] != null
          ? (json['members'] as List)
                .map((member) => GroupMember.fromJson(member))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_group': isGroup ? 1 : 0,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image_path': imagePath,
      'members': members?.map((member) => member.toJson()).toList(),
    };
  }
}

/// Model for group member information
class GroupMember {
  final int userId;
  final String name;
  final String email;
  final String role;
  final String joinedAt;

  GroupMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      userId: json['user_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] ?? json['member_role'] ?? 'member',
      joinedAt: json['joined_at'] ?? json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'role': role,
      'joined_at': joinedAt,
    };
  }

  /// Get user initials for avatar
  String get initials {
    final words = name.split(' ');
    if (words.isEmpty) return 'U';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}

/// Utility class for group message operations
class GroupMessageUtils {
  /// Generate avatar colors for different users
  static const List<List<int>> avatarColors = [
    [0xFF6366F1, 0xFF8B5CF6], // Purple
    [0xFF10B981, 0xFF059669], // Green
    [0xFFF59E0B, 0xFFD97706], // Orange
    [0xFFEF4444, 0xFFDC2626], // Red
    [0xFF3B82F6, 0xFF2563EB], // Blue
    [0xFF8B5CF6, 0xFF7C3AED], // Violet
    [0xFF06B6D4, 0xFF0891B2], // Cyan
    [0xFFF97316, 0xFFEA580C], // Orange-Red
  ];

  /// Get avatar gradient colors for a user
  static List<int> getAvatarColors(int userId) {
    return avatarColors[userId % avatarColors.length];
  }

  /// Format timestamp for group messages
  static String formatGroupMessageTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today - show time
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      // This week - show day name
      const dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      return dayNames[dateTime.weekday - 1];
    } else {
      // Older - show date
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  /// Check if two messages are from the same sender and close in time
  static bool shouldGroupMessages(MessageModel current, MessageModel previous) {
    if (current.sentBy != previous.sentBy) return false;

    final currentTime = DateTime.parse(current.sentAt);
    final previousTime = DateTime.parse(previous.sentAt);

    // Group messages if they're within 5 minutes of each other
    return currentTime.difference(previousTime).inMinutes <= 5;
  }

  /// Get sender name from group members
  static String getSenderName(int senderId, List<GroupMember> members) {
    try {
      final member = members.firstWhere((member) => member.userId == senderId);
      return member.name;
    } catch (e) {
      return 'Unknown User';
    }
  }

  /// Get sender initials from group members
  static String getSenderInitials(int senderId, List<GroupMember> members) {
    try {
      final member = members.firstWhere((member) => member.userId == senderId);
      return member.initials;
    } catch (e) {
      return 'U';
    }
  }
}
