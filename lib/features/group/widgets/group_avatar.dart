import 'package:flutter/material.dart';

import '../../../data/models/Group/group_model.dart';
import '../utils/group_utils.dart';

class GroupAvatar extends StatelessWidget {
  final GroupModel group;
  final double radius;

  const GroupAvatar({super.key, required this.group, this.radius = 25});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: GroupUtils.getAvatarColor(group.id),
      backgroundImage: group.profilePictureUrl != null
          ? NetworkImage(group.profilePictureUrl!)
          : null,
      child: group.profilePictureUrl == null
          ? Text(
              GroupUtils.getInitials(group.name),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: radius * 0.64, // Responsive font size
              ),
            )
          : null,
    );
  }
}
