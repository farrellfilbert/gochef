import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../screens/notifications/notifications_screen.dart';
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
      final counts = await ApiService.getUnreadCounts();
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
          onPressed: () {
            // When opened, clear the dot locally, then navigate
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
