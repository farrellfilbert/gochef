import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../services/audio_service.dart';
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
  int _prevUnreadChats = -1;
  int _pendingOrders = 0;
  int _prevPendingOrders = -1;
  String? _lastNotifiedOrderId;
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
    AudioService.unlock();
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
        final newPendingOrders = (counts['pending_orders'] as int?) ?? 0;
        final latestOrderId = counts['latest_order_id']?.toString();
        final latestCustomer = counts['latest_customer_name']?.toString() ?? 'Pelanggan';
        final latestTotal = counts['latest_order_total'] != null ? '\$${counts['latest_order_total']}' : '';

        // 1. Check for incoming orders -> Play Order Chime & Alert
        if (_prevPendingOrders >= 0 && (newPendingOrders > _prevPendingOrders || (latestOrderId != null && latestOrderId != _lastNotifiedOrderId))) {
          _lastNotifiedOrderId = latestOrderId;
          AudioService.playOrder();

          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.restaurant, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🛎️ NEW ORDER RECEIVED!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                        Text(
                          latestOrderId != null ? '$latestCustomer ($latestOrderId) $latestTotal' : 'New incoming order waiting for preparation',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              action: SnackBarAction(
                label: 'VIEW ORDER',
                textColor: Colors.amberAccent,
                onPressed: () {
                  setState(() {
                    _currentIndex = 2; // Switch to Orders screen
                  });
                },
              ),
              backgroundColor: const Color(0xFFD81B60),
              duration: const Duration(seconds: 7),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
        } else if (_prevPendingOrders == -1) {
          _lastNotifiedOrderId = latestOrderId;
        }

        // 2. Check for incoming chats -> Play Message Sound
        if (newChats > _prevUnreadChats && _prevUnreadChats >= 0) {
          AudioService.playMessage();
          
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
          _prevPendingOrders = newPendingOrders;
          _pendingOrders = newPendingOrders;
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
              BottomNavigationBarItem(
                icon: _pendingOrders > 0
                    ? Badge.count(
                        count: _pendingOrders,
                        backgroundColor: Colors.amberAccent,
                        textColor: Colors.black,
                        child: const Icon(Icons.receipt_long_outlined),
                      )
                    : const Icon(Icons.receipt_long_outlined),
                activeIcon: _pendingOrders > 0
                    ? Badge.count(
                        count: _pendingOrders,
                        backgroundColor: Colors.amberAccent,
                        textColor: Colors.black,
                        child: const Icon(Icons.receipt_long),
                      )
                    : const Icon(Icons.receipt_long),
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
        elevation: 6,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
