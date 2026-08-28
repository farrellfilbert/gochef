import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../screens/notifications/notifications_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../utils/web_js.dart';

class NotificationBell extends StatefulWidget {
  final Color iconColor;
  
  const NotificationBell({super.key, this.iconColor = const Color(0xFFC4C6D0)});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  int _unreadCount = 0;
  int? _prevUnreadCount;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchUnreadCount(isInitial: true);
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchUnreadCount(isInitial: false);
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUnreadCount({bool isInitial = false}) async {
    if (!mounted) return;
    try {
      final counts = await ApiService.getUnreadCounts();
      if (mounted) {
        final newCount = (counts['unread_notifications'] as int?) ?? 0;
        // ONLY play sound when a NEW notification arrives while already on the screen (never on initial load)
        if (!isInitial && _prevUnreadCount != null && newCount > _prevUnreadCount! && kIsWeb) {
          try { WebJs.callMethod('goChefPlayNotification', []); } catch (_) {}
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

