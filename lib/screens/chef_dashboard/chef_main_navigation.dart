import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
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
  int _currentIndex = 0; // Default to Kitchen Profile page
  int _unreadChats = 0;
  int _prevUnreadChats = 0;
  Timer? _pollingTimer;

  final List<Widget> _screens = [
    const ChefProfileScreen(),
    const ChefMenuScreen(),
    const ChefOrdersScreen(),
    const ChefAnalyticsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchUnreadCounts();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _fetchUnreadCounts();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUnreadCounts() async {
    if (!mounted) return;
    try {
      final counts = await ApiService.getUnreadCounts();
      if (mounted) {
        final newChats = (counts['unread_chats'] as int?) ?? 0;

        // Play chime sound and show snackbar if new chat received
        if (newChats > _prevUnreadChats && _prevUnreadChats >= 0 && kIsWeb) {
          try {
            js.context.callMethod('goChefPlayMessage', []);
          } catch (_) {}
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.mark_chat_unread, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('💬 Pesan baru dari pelanggan ($newChats belum dibaca)'),
                ],
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        setState(() {
          _prevUnreadChats = newChats;
          _unreadChats = newChats;
        });
      }
    } catch (_) {}
  }

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
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white60,
            selectedLabelStyle: AppTextStyles.labelSm(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTextStyles.labelSm(color: Colors.white60).copyWith(fontWeight: FontWeight.w500),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: _unreadChats > 0
                    ? Badge.count(
                        count: _unreadChats,
                        backgroundColor: Colors.redAccent,
                        textColor: Colors.white,
                        child: const Icon(Icons.restaurant_outlined),
                      )
                    : const Icon(Icons.restaurant_outlined),
                activeIcon: _unreadChats > 0
                    ? Badge.count(
                        count: _unreadChats,
                        backgroundColor: Colors.redAccent,
                        textColor: Colors.white,
                        child: const Icon(Icons.restaurant),
                      )
                    : const Icon(Icons.restaurant),
                label: 'Kitchen',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'Menu',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
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
