import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../screens/notifications/notifications_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class NotificationBell extends StatefulWidget {
  final Color iconColor;
  
  const NotificationBell({super.key, this.iconColor = AppColors.onSurfaceVariant});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchUnreadCount();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUnreadCount() async {
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastOpenTime = prefs.getString('last_notification_open_time');
      
      final counts = await ApiService.getUnreadCounts(lastOpenTime: lastOpenTime);
      if (mounted) {
        setState(() {
          _unreadCount = (counts['total_unread'] as int?) ?? 0;
        });
      }
    } catch (e) {
      // Ignore errors for background polling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: widget.iconColor),
          onPressed: () async {
            // Save current time as last opened
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('last_notification_open_time', DateTime.now().toIso8601String());

            // When opened, clear the dot locally, then navigate
            if (mounted) {
              setState(() {
                _unreadCount = 0;
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ).then((_) {
                // Re-fetch after returning
                _fetchUnreadCount();
              });
            }
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 8,
                minHeight: 8,
              ),
            ),
          )
      ],
    );
  }
}
