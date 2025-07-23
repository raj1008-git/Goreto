import 'package:flutter/material.dart';

import '../../../data/models/Group/group_model.dart';

class GroupUtils {
  static final List<Color> _avatarColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
  ];

  static Color getAvatarColor(int groupId) {
    return _avatarColors[groupId % _avatarColors.length];
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    } else {
      return (words[0].substring(0, 1) + words[1].substring(0, 1))
          .toUpperCase();
    }
  }

  static String formatMemberCount(List<UserGroupModel> userGroups) {
    int count = userGroups.length;
    return count == 1 ? '1 member' : '$count members';
  }

  static String getUserRole(List<UserGroupModel> userGroups) {
    // This would need the current user ID to determine role
    // For now, we'll show the first user's role
    if (userGroups.isNotEmpty) {
      return userGroups.first.memberRole.toUpperCase();
    }
    return 'MEMBER';
  }
}
