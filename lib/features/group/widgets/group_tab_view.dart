import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/Group/group_model.dart';
import '../../../data/providers/group_provider.dart';
import 'empty_state.dart';
import 'error_state_widget.dart';
import 'group_tile.dart';
import 'joinable_group_tile.dart';
import 'joined_group_tile.dart';

enum GroupTabType { latest, joined, myGroups }

class GroupTabView extends StatelessWidget {
  final GroupTabType tabType;
  final RefreshCallback onRefresh;

  const GroupTabView({
    super.key,
    required this.tabType,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        final isLoading = _getLoadingState(groupProvider);
        final groups = _getGroups(groupProvider);
        final errorMessage = groupProvider.errorMessage;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage != null) {
          return ErrorStateWidget(
            onRefresh: onRefresh,
            message: _getErrorMessage(),
          );
        }

        if (groups.isEmpty) {
          return EmptyStateWidget(onRefresh: onRefresh, tabType: tabType);
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _buildGroupTile(group);
            },
          ),
        );
      },
    );
  }

  bool _getLoadingState(GroupProvider provider) {
    switch (tabType) {
      case GroupTabType.latest:
        return provider.isLoadingAllGroups;
      case GroupTabType.joined:
        return provider.isLoadingJoinedGroups;
      case GroupTabType.myGroups:
        return provider.isLoadingMyGroups;
    }
  }

  List<GroupModel> _getGroups(GroupProvider provider) {
    switch (tabType) {
      case GroupTabType.latest:
        return provider.allGroups;
      case GroupTabType.joined:
        return provider.joinedGroups;
      case GroupTabType.myGroups:
        return provider.myGroups;
    }
  }

  String _getErrorMessage() {
    switch (tabType) {
      case GroupTabType.latest:
        return 'Failed to load groups';
      case GroupTabType.joined:
        return 'Failed to load joined groups';
      case GroupTabType.myGroups:
        return 'Failed to load groups';
    }
  }

  Widget _buildGroupTile(GroupModel group) {
    switch (tabType) {
      case GroupTabType.latest:
        return JoinableGroupTile(group: group);
      case GroupTabType.joined:
        return JoinedGroupTile(group: group);
      case GroupTabType.myGroups:
        return GroupTile(group: group);
    }
  }
}
