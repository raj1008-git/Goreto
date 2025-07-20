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

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;
  late AnimationController _iconAnimationController;
  late Animation<double> _fabScaleAnimation;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const NewsfeedScreen(),
    MapsScreen(),
    const ChatHomeScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _iconAnimationController.reset();
    _iconAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),

      // Enhanced FAB with animation and gradient
      floatingActionButton: GestureDetector(
        onTapDown: (_) => _fabAnimationController.forward(),
        onTapUp: (_) => _fabAnimationController.reverse(),
        onTapCancel: () => _fabAnimationController.reverse(),
        child: ScaleTransition(
          scale: _fabScaleAnimation,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Enhanced BottomNavigationBar with beautiful styling
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Beautiful curved border with gradient effect
            CustomPaint(
              painter: EnhancedBottomNavBarPainter(screenWidth: screenWidth),
              child: const SizedBox(height: 58),
            ),

            // Transparent BottomAppBar
            BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              color: Colors.white,
              elevation: 0,
              child: SizedBox(
                height: 58,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      icon: Icons.dashboard_rounded,
                      index: 0,
                      label: 'Dashboard',
                    ),
                    _buildNavItem(
                      icon: Icons.feed_rounded,
                      index: 1,
                      label: 'Feed',
                    ),
                    const SizedBox(width: 40), // Space for FAB
                    _buildNavItem(
                      icon: Icons.chat_bubble_rounded,
                      index: 3,
                      label: 'Chat',
                    ),
                    _buildNavItem(
                      icon: Icons.person_rounded,
                      index: 4,
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;
    return AnimatedBuilder(
      animation: _iconAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: isSelected
              ? 1.0 + (_iconAnimationController.value * 0.1)
              : 1.0,
          child: InkWell(
            onTap: () => _onItemTapped(index),
            borderRadius: BorderRadius.circular(16),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isSelected ? AppColors.primary : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? AppColors.primary : Colors.grey[600],
                    ),
                  ),
                  // Animated indicator dot
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(top: 1),
                    width: isSelected ? 4 : 0,
                    height: isSelected ? 4 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
