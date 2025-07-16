import 'package:flutter/material.dart';
import 'package:goreto/features/maps/screens/maps_screen.dart';
import 'package:goreto/presentation/screens/chat/chat_home_screen.dart';
import 'package:goreto/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:goreto/presentation/screens/news_feed/news_feed_screen.dart';
import 'package:goreto/presentation/screens/profile/profile_screen.dart';
import 'package:goreto/presentation/widgets/bottom_nav_bar_bottom_painter.dart';

import '../../core/constants/appColors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const NewsfeedScreen(),
    MapsScreen(), // this is not directly visible in nav, but kept for index
    const ChatHomeScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),

      // FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.location_on, color: Colors.white),
        onPressed: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Custom BottomAppBar with notch
      bottomNavigationBar: Stack(
        children: [
          // ✅ Custom curved border only — no container border anymore
          CustomPaint(
            painter: BottomNavBarBorderPainter(
              color: Colors.black,
              fabRadius: 28.0,
              screenWidth: screenWidth,
            ),
            child: const SizedBox(height: 60),
          ),

          // ✅ Transparent BottomAppBar that doesn't override the curve
          BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            color: Colors.white,
            elevation: 0,
            child: SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(icon: Icons.dashboard, index: 0),
                  _buildNavItem(
                    icon: Icons.keyboard_command_key_rounded,
                    index: 1,
                  ),
                  const SizedBox(width: 40), // For FAB
                  _buildNavItem(icon: Icons.chat, index: 3),
                  _buildNavItem(icon: Icons.person, index: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    // required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
            // Text(
            //   label,
            //   style: TextStyle(
            //     fontSize: 12,
            //     color: isSelected ? AppColors.primary : Colors.grey,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
