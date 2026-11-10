import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../screens/chat/inbox_screen.dart';
import 'dart:async';

class ChatIconButton extends StatefulWidget {
  final Color iconColor;

  const ChatIconButton({super.key, this.iconColor = Colors.white});

  @override
  State<ChatIconButton> createState() => _ChatIconButtonState();
}

class _ChatIconButtonState extends State<ChatIconButton> {
  int _unreadChats = 0;
  int? _prevUnreadChats;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchUnreadChats(isInitial: true);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      _fetchUnreadChats(isInitial: false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchUnreadChats({bool isInitial = false}) async {
    if (!mounted) return;
    try {
      final counts = await ApiService.getUnreadCounts();
      if (mounted) {
        final newChats = (counts['unread_chats'] as int?) ?? 0;
        if (!isInitial && _prevUnreadChats != null && newChats > _prevUnreadChats!) {
          AudioService.playMessage();
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
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(Icons.chat_bubble_outline, color: widget.iconColor),
          tooltip: 'Messages / Inbox',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InboxScreen()),
            ).then((_) => _fetchUnreadChats(isInitial: true));
          },
        ),
        if (_unreadChats > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                _unreadChats > 99 ? '99+' : '$_unreadChats',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

