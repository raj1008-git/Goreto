// import 'package:flutter/material.dart';
//
// import '../../../data/models/Group/group_model.dart';
// import '../utils/group_utils.dart';
// import 'group_avatar.dart';
//
// class JoinedGroupTile extends StatelessWidget {
//   final GroupModel group;
//   final VoidCallback? onTap;
//
//   const JoinedGroupTile({super.key, required this.group, this.onTap});
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
//             const SizedBox(height: 2),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//               decoration: BoxDecoration(
//                 color: Colors.green.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Text(
//                 'JOINED',
//                 style: TextStyle(
//                   color: Colors.green[700],
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//         onTap: onTap ?? () => _defaultOnTap(context),
//       ),
//     );
//   }
//
//   void _defaultOnTap(BuildContext context) {
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('Opening ${group.name}')));
//   }
// }
import 'package:flutter/material.dart';

import '../../../data/models/Group/group_model.dart';
import '../group_chat_screen.dart';
import '../utils/group_utils.dart';
import 'group_avatar.dart';

class JoinedGroupTile extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;

  const JoinedGroupTile({super.key, required this.group, this.onTap});

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
          // onTap: onTap ?? () => _defaultOnTap(context),
          onTap:
              onTap ??
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupChatScreen(group: group),
                ),
              ),
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.green.withOpacity(0.1),
          highlightColor: Colors.green.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Enhanced Group Avatar with green accent for joined status
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      GroupAvatar(group: group, radius: 28),
                      // Joined indicator - small green dot
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
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

                      const SizedBox(height: 8),

                      // Joined status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.withOpacity(0.15),
                              Colors.green.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[700],
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'JOINED',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Enhanced arrow with subtle background
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _defaultOnTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${group.name}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
