import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'analytics_screen.dart';
import 'menu_management_screen.dart';
import 'order_management_screen.dart';
import 'profile_screen.dart';

class ChefMainNavigation extends StatefulWidget {
  const ChefMainNavigation({super.key});

  @override
  State<ChefMainNavigation> createState() => _ChefMainNavigationState();
}

class _ChefMainNavigationState extends State<ChefMainNavigation> {
  int _currentIndex = 3; // Default to Stats based on HTML

  final List<Widget> _screens = [
    const ChefProfileScreen(),
    const ChefMenuScreen(),
    const ChefOrdersScreen(),
    const ChefAnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.9),
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            _buildNavItem(0, Icons.restaurant_outlined, Icons.restaurant, 'Kitchen'),
            _buildNavItem(1, Icons.menu_book_outlined, Icons.menu_book, 'Menu'),
            _buildNavItem(2, Icons.receipt_long_outlined, Icons.receipt_long, 'Orders'),
            _buildNavItem(3, Icons.analytics_outlined, Icons.analytics, 'Stats'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimaryContainer),
      ),
    );
  }

  NavigationDestination _buildNavItem(
      int index, IconData unselectedIcon, IconData selectedIcon, String label) {
    final isSelected = _currentIndex == index;
    return NavigationDestination(
      icon: Icon(
        isSelected ? selectedIcon : unselectedIcon,
        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant.withOpacity(0.6),
      ),
      label: label,
    );
  }
}
