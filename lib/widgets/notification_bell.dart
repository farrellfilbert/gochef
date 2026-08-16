import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../screens/notifications/notifications_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class NotificationBell extends StatefulWidget {
  final Color iconColor;
  
  const NotificationBell({super.key, this.iconColor = AppColors.onSurfaceVariant});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;
  int _prevUnreadCount = 0;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
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
        final newCount = (counts['total_unread'] as int?) ?? 0;
        // Play sound if count increased
        if (newCount > _prevUnreadCount && _prevUnreadCount >= 0 && kIsWeb) {
          try { js.context.callMethod('goChefPlayNotification', []); } catch (_) {}
        }
        setState(() {
          _prevUnreadCount = newCount;
          _unreadCount = newCount;
        });
      }
    } catch (e) {
      // Ignore errors for background polling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: widget.iconColor),
          onPressed: () async {
            // Save current time as last opened
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('last_notification_open_time', DateTime.now().toIso8601String());

            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ).then((_) {
                _fetchUnreadCount();
              });
            }
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _unreadCount > 9 ? '9+' : '$_unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
      ],
    );
  }
}

