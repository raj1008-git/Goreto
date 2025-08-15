import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
import '../../../data/models/Group/group_model.dart';
import '../../../data/providers/group_provider.dart';

class JoinGroupDialog {
  static void show(BuildContext context, GroupModel group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.group_add,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Join Group',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Are you sure you want to join "${group.name}"?',
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _handleJoinGroup(context, group),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Join',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  static void _handleJoinGroup(BuildContext context, GroupModel group) async {
    Navigator.of(context).pop();

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('Joining ${group.name}...'),
          ],
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.blue[600],
      ),
    );

    final result = await context.read<GroupProvider>().joinGroup(group.id);

    // Clear the loading snackbar
    ScaffoldMessenger.of(context).clearSnackBars();

    if (result['success'] == true) {
      _showSuccessSnackBar(context, group);
    } else if (result['alreadyMember'] == true) {
      _showAlreadyMemberSnackBar(context, result);
    } else {
      _showErrorSnackBar(context, result, group);
    }
  }

  static void _showSuccessSnackBar(BuildContext context, GroupModel group) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Welcome to ${group.name}! 🎉',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void _showAlreadyMemberSnackBar(
    BuildContext context,
    Map<String, dynamic> result,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                result['message'] ?? 'You are already a member of this group.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[600],
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static void _showErrorSnackBar(
    BuildContext context,
    Map<String, dynamic> result,
    GroupModel group,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                result['message'] ?? 'Failed to join group. Please try again.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => JoinGroupDialog.show(context, group),
        ),
      ),
    );
  }
}
