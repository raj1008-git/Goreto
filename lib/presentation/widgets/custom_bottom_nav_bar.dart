// lib/presentation/widgets/custom_bottom_navbar.dart

import 'package:flutter/material.dart';
import 'package:goreto/core/constants/appColors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 0, // keep this 0 if you want only border, no shadow
      child: Stack(
        children: [
          // Top black border
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 1, color: Colors.black),
          ),

          // Main nav content
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.dashboard, "Dashboard", 0),
                _buildNavItem(Icons.public, "Stories", 1),
                const SizedBox(width: 40), // space for FAB
                _buildNavItem(Icons.chat, "Chat", 2),
                _buildNavItem(Icons.person, "Profile", 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
