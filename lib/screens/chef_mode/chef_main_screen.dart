import 'package:flutter/material.dart';
import 'chef_dashboard_screen.dart';
import 'menu_management_screen.dart';
import 'chef_order_history_screen.dart';
import 'earnings_analytics_screen.dart';
import '../../widgets/chef_bottom_nav.dart';
import '../../core/theme.dart';

class ChefMainScreen extends StatefulWidget {
  final int initialIndex;
  const ChefMainScreen({super.key, this.initialIndex = 0});

  @override
  State<ChefMainScreen> createState() => _ChefMainScreenState();
}

class _ChefMainScreenState extends State<ChefMainScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const ChefDashboardScreen(),
    const MenuManagementScreen(),
    // Orders placeholder
    const ChefOrderHistoryScreen(),
    // Earnings placeholder
    const EarningsAnalyticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.chefBackground,
      body: Stack(
        children: [
          _screens[_currentIndex],
          ChefBottomNav(
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
