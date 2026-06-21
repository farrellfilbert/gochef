import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/custom_bottom_nav.dart';
import 'user_mode/explore_kitchens_screen.dart';
import 'explore_screen.dart';
import 'package:gochef/screens/user_mode/foodie_order_history_screen.dart';
import 'user_mode/foodie_profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ExploreKitchensScreen(),
    const ExploreScreen(), // Keeping as search/discover
    const FoodieOrderHistoryScreen(),
    const FoodieProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          _screens[_currentIndex],
          CustomBottomNav(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
