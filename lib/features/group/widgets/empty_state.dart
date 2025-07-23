import 'package:flutter/material.dart';

import 'group_tab_view.dart';

class EmptyStateWidget extends StatelessWidget {
  final RefreshCallback onRefresh;
  final GroupTabType tabType;

  const EmptyStateWidget({
    super.key,
    required this.onRefresh,
    required this.tabType,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIcon(), size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _getTitle(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getSubtitle(),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull to refresh',
              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (tabType) {
      case GroupTabType.latest:
        return Icons.groups_outlined;
      case GroupTabType.joined:
        return Icons.group_outlined;
      case GroupTabType.myGroups:
        return Icons.groups_outlined;
    }
  }

  String _getTitle() {
    switch (tabType) {
      case GroupTabType.latest:
        return 'No groups available';
      case GroupTabType.joined:
        return 'No joined groups';
      case GroupTabType.myGroups:
        return 'No groups found';
    }
  }

  String _getSubtitle() {
    switch (tabType) {
      case GroupTabType.latest:
        return 'Check back later for new groups';
      case GroupTabType.joined:
        return 'Join some groups to see them here';
      case GroupTabType.myGroups:
        return 'Create your first group';
    }
  }
}
