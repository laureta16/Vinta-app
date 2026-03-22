import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vinta/theme/app_colors.dart';
import 'package:vinta/features/home/presentation/screens/home_screen.dart';
import 'package:vinta/features/search/presentation/screens/search_screen.dart';
import 'package:vinta/features/post/presentation/screens/add_post_screen.dart';
import 'package:vinta/features/chat/presentation/screens/chat_screen.dart';
import 'package:vinta/features/profile/presentation/screens/profile_screen.dart';
import 'package:vinta/core/services/chat_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const AddPostScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Crucial for floating nav
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildFloatingNavBar(),
    );
  }

  Widget _buildFloatingNavBar() {
    return Container(
      height: 70,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.grid_view_rounded, 'Home'),
                _buildNavItem(1, Icons.search_rounded, 'Explore'),
                _buildNavItem(2, Icons.add_circle_rounded, 'Sell', isLarge: true),
                StreamBuilder<int>(
                  stream: ChatService().getUnreadCountStream(),
                  builder: (context, snapshot) {
                    final count = snapshot.data ?? 0;
                    return Badge(
                      isLabelVisible: count > 0,
                      label: Text(count.toString()),
                      backgroundColor: AppColors.accentColor,
                      child: _buildNavItem(3, Icons.chat_bubble_outline_rounded, 'Messages'),
                    );
                  }
                ),
                _buildNavItem(4, Icons.person_outline_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool isLarge = false}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isLarge ? 32 : 24,
            color: isSelected ? AppColors.accentColor : Colors.white.withOpacity(0.6),
          ),
          if (isSelected && !isLarge)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(color: AppColors.accentColor, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
