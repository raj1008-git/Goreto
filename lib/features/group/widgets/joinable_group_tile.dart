// import 'package:flutter/material.dart';
//
// import '../../../core/constants/appColors.dart';
// import '../../../data/models/Group/group_model.dart';
// import '../utils/group_utils.dart';
// import 'group_avatar.dart';
// import 'join_group_dialog.dart';
//
// class JoinableGroupTile extends StatelessWidget {
//   final GroupModel group;
//
//   const JoinableGroupTile({super.key, required this.group});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: GroupAvatar(group: group),
//         title: Text(
//           group.name,
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Text(
//               GroupUtils.formatMemberCount(group.userGroups),
//               style: TextStyle(color: Colors.grey[600], fontSize: 13),
//             ),
//           ],
//         ),
//         trailing: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: AppColors.primary,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: const Text(
//             'Join',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         onTap: () => JoinGroupDialog.show(context, group),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

import '../../../core/constants/appColors.dart';
import '../../../data/models/Group/group_model.dart';
import '../utils/group_utils.dart';
import 'group_avatar.dart';
import 'join_group_dialog.dart';

class JoinableGroupTile extends StatelessWidget {
  final GroupModel group;

  const JoinableGroupTile({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => JoinGroupDialog.show(context, group),
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Enhanced Group Avatar with subtle glow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: GroupAvatar(group: group, radius: 28),
                ),

                const SizedBox(width: 16),

                // Content section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group name with better typography
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: Color(0xFF2D3748),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 6),

                      // Member count with icon
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            GroupUtils.formatMemberCount(group.userGroups),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Enhanced join button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => JoinGroupDialog.show(context, group),
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Join',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
