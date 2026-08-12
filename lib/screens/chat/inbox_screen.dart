import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/chat_model.dart';
import '../../services/api_service.dart';
import 'chat_screen.dart';
import 'package:intl/intl.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  List<ChatModel> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInbox();
  }
  
  Future<void> _loadInbox() async {
    setState(() => _isLoading = true);
    
    final inboxRaw = await ApiService.getChatInbox();
    
    if (mounted) {
      setState(() {
        _chats = inboxRaw.map((c) {
          return ChatModel(
            id: c['other_user_id'].toString(),
            otherParticipantName: c['name'] ?? 'Unknown',
            otherParticipantAvatar: c['avatar'] ?? '',
            lastMessage: c['last_message'] ?? '',
            lastMessageTime: DateTime.parse(c['created_at']),
            unreadCount: int.tryParse(c['unread_count']?.toString() ?? '0') ?? 0,
            isOnline: true, // we don't have online status in backend yet
          );
        }).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        title: Text('Messages', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : _chats.isEmpty
          ? Center(
              child: Text(
                'No messages yet',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadInbox,
              child: ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return _buildChatTile(chat);
                },
              ),
            ),
    );
  }

  Widget _buildChatTile(ChatModel chat) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              otherParticipantId: chat.id,
              otherParticipantName: chat.otherParticipantName,
              otherParticipantAvatar: chat.otherParticipantAvatar,
              isOnline: chat.isOnline,
            ),
          ),
        ).then((_) {
          // reload inbox when coming back from chat to update unread counts
          _loadInbox();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2))),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: chat.otherParticipantAvatar.isNotEmpty 
                      ? NetworkImage(chat.otherParticipantAvatar) 
                      : null,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  child: chat.otherParticipantAvatar.isEmpty
                      ? const Icon(Icons.person, color: AppColors.onSurfaceVariant)
                      : null,
                ),
                if (chat.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.otherParticipantName,
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16),
                      ),
                      Text(
                        _formatTime(chat.lastMessageTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: chat.unreadCount > 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                          fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: AppTextStyles.bodyMd(
                            color: chat.unreadCount > 0 ? AppColors.onSurface : AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(color: AppColors.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.year == now.year && time.month == now.month && time.day == now.day) {
      return DateFormat('HH:mm').format(time);
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
