import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/chat_model.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final String otherParticipantId;
  final String otherParticipantName;
  final String otherParticipantAvatar;
  final String? kitchenId;
  final String? orderId;
  final bool isOnline;

  const ChatScreen({
    super.key,
    required this.otherParticipantId,
    required this.otherParticipantName,
    required this.otherParticipantAvatar,
    this.kitchenId,
    this.orderId,
    this.isOnline = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isUploadingImage = false;
  Timer? _timer;
  String? _myUserId;
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    _myUserId = await ApiService.getUserId();
    await _loadMessages();
    
    // Polling every 4 seconds for new messages
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _loadMessages(isPolling: true);
    });
  }

  Future<void> _loadMessages({bool isPolling = false}) async {
    if (!isPolling && mounted) {
      setState(() => _isLoading = true);
    }
    
    final messagesRaw = await ApiService.getChatMessages(
      widget.otherParticipantId, 
      orderId: widget.orderId
    );
    
    if (mounted) {
      final newMessages = messagesRaw.map((m) {
        return MessageModel(
          id: m['id'].toString(),
          text: m['message'] ?? '',
          imageUrl: m['image_url'],
          isMe: m['sender_id'].toString() == _myUserId,
          timestamp: DateTime.parse(m['created_at'].toString().replaceAll(' ', 'T') + 'Z').toLocal(),
        );
      }).toList();

      // Play sound if new message arrived from the other person during polling
      if (isPolling && newMessages.length > _lastMessageCount && kIsWeb) {
        final lastNew = newMessages.last;
        if (!lastNew.isMe) {
          try { js.context.callMethod('goChefPlayMessage', []); } catch (_) {}
        }
      }

      setState(() {
        _messages = newMessages;
        _lastMessageCount = newMessages.length;
        _isLoading = false;
      });
      
      if (!isPolling && _messages.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else if (isPolling && newMessages.length > _lastMessageCount) {
        // Auto-scroll on new messages during polling
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return;

      setState(() => _isUploadingImage = true);

      final bytes = await image.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,' + base64Encode(bytes);

      final uploadedUrl = await ApiService.uploadImageBase64(base64Image);
      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image. Please try again.')),
          );
        }
        return;
      }

      // Optimistically add message
      setState(() {
        _messages.add(
          MessageModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: '',
            imageUrl: uploadedUrl,
            isMe: true,
            timestamp: DateTime.now(),
          ),
        );
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });

      final success = await ApiService.sendChatMessage(
        widget.otherParticipantId,
        '',
        kitchenId: widget.kitchenId,
        orderId: widget.orderId,
        imageUrl: uploadedUrl,
      );

      if (success) {
        _loadMessages(isPolling: true);
      }
    } catch (e) {
      debugPrint('Error picking/sending image: $e');
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final text = _messageController.text.trim();
    _messageController.clear();
    
    // Optimistic UI update
    setState(() {
      _messages.add(
        MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // temp ID
          text: text,
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });
    
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    final success = await ApiService.sendChatMessage(
      widget.otherParticipantId, 
      text,
      kitchenId: widget.kitchenId,
      orderId: widget.orderId,
    );
    
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    } else {
      _loadMessages(isPolling: true); // fetch real ID and timestamp
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.otherParticipantAvatar.isNotEmpty
                      ? NetworkImage(widget.otherParticipantAvatar)
                      : null,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  child: widget.otherParticipantAvatar.isEmpty
                      ? const Icon(Icons.person, color: AppColors.onSurfaceVariant)
                      : null,
                ),
                if (widget.isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherParticipantName,
                    style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.isOnline ? 'Online' : 'Offline',
                    style: AppTextStyles.labelSm(
                      color: widget.isOnline ? Colors.green : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet. Say hi!',
                        style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _buildMessageBubble(message);
                      },
                    ),
              ),
              _buildMessageInput(),
            ],
          ),
    );
  }

  void _showImagePreview(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isMe = message.isMe;
    final hasImage = message.imageUrl != null && message.imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundImage: widget.otherParticipantAvatar.isNotEmpty
                  ? NetworkImage(widget.otherParticipantAvatar)
                  : null,
              backgroundColor: AppColors.surfaceContainerHighest,
              child: widget.otherParticipantAvatar.isEmpty
                  ? const Icon(Icons.person, size: 16, color: AppColors.onSurfaceVariant)
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: hasImage ? 8 : 16,
                vertical: hasImage ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                  bottomLeft: !isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (hasImage) ...[
                    GestureDetector(
                      onTap: () => _showImagePreview(message.imageUrl!),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 240, maxHeight: 240),
                          child: Image.network(
                            message.imageUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                width: 200,
                                height: 160,
                                color: Colors.black26,
                                child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 200,
                                height: 120,
                                color: Colors.black26,
                                child: const Center(
                                  child: Icon(Icons.broken_image, color: Colors.white70, size: 36),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    if (message.text.isNotEmpty) const SizedBox(height: 6),
                  ],
                  if (message.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hasImage ? 8 : 0),
                      child: Text(
                        message.text,
                        style: AppTextStyles.bodyMd(
                          color: isMe ? AppColors.onPrimary : AppColors.onSurface,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hasImage ? 8 : 0),
                    child: Text(
                      DateFormat('HH:mm').format(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe ? AppColors.onPrimary.withValues(alpha: 0.7) : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 22),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isUploadingImage)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: const [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                  ),
                  SizedBox(width: 10),
                  Text('Uploading photo...', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                tooltip: 'Send Photo',
                onPressed: _isUploadingImage ? null : _pickAndSendImage,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.onPrimary, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
