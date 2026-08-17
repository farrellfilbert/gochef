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
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: AppColors.surface,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: AppColors.surface,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.white70,
            selectedLabelStyle: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.labelSm(color: Colors.white70).copyWith(fontWeight: FontWeight.w500),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_outlined),
                activeIcon: Icon(Icons.restaurant),
                label: 'Kitchen',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'Menu',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                activeIcon: Icon(Icons.analytics),
                label: 'Stats',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _currentIndex = 1; // Switch to Menu screen
          });
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
