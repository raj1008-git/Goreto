// Updated GroupScreen with the Create Group FAB
// lib/features/group/screens/group_screen.dart

import 'package:flutter/material.dart';
import 'package:goreto/features/group/widgets/create_group_FAB.dart';
import 'package:goreto/features/group/widgets/group_tab_view.dart';
import 'package:provider/provider.dart';

import '../../core/constants/appColors.dart';
import '../../data/providers/group_provider.dart';
// Import the new FAB

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);

    // Add listener for tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0: // Latest Groups tab
            context.read<GroupProvider>().fetchAllGroups();
            break;
          case 1: // Joined Groups tab
            context.read<GroupProvider>().fetchJoinedGroups();
            break;
          case 2: // My Groups tab
            // Already loaded in addPostFrameCallback
            break;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroupProvider>().fetchMyGroups();
      context.read<GroupProvider>().fetchAllGroups();
      context.read<GroupProvider>().fetchJoinedGroups();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('assets/logos/goreto.png', width: 32, height: 32),
              const SizedBox(width: 12),
              const Text(
                'Groups',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: 'Latest Groups'),
            Tab(text: 'Joined Group'),
            Tab(text: 'My Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GroupTabView(
            tabType: GroupTabType.latest,
            onRefresh: () => context.read<GroupProvider>().fetchAllGroups(),
          ),
          GroupTabView(
            tabType: GroupTabType.joined,
            onRefresh: () => context.read<GroupProvider>().fetchJoinedGroups(),
          ),
          GroupTabView(
            tabType: GroupTabType.myGroups,
            onRefresh: () => context.read<GroupProvider>().fetchMyGroups(),
          ),
        ],
      ),
      floatingActionButton:
          const CreateGroupFAB(), // Add the beautiful FAB here
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
