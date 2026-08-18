import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_text_styles.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        title: const Text('Contact Support'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/GoCheflogo.png',
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.support_agent, size: 80, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'How can we help you?',
                style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Our support team and AI assistant are available 24/7 to help you with any questions.',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildContactMethod(
                Icons.smart_toy_outlined, 
                'Live Chat (AI Support Assistant)', 
                'Instant answers to your questions 24/7', 
                () => _openAiSupportChat(context),
              ),
              const SizedBox(height: 16),
              _buildContactMethod(
                Icons.sms_outlined, 
                'Text Line', 
                '+1 (555) 123-4567 (SMS & WhatsApp)', 
                () {},
              ),
              const SizedBox(height: 16),
              _buildContactMethod(
                Icons.email_outlined, 
                'Email Us', 
                'support@thegrubnextdoor.com', 
                () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactMethod(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }

  void _openAiSupportChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AiSupportChatSheet(),
    );
  }
}

class _AiSupportChatSheet extends StatefulWidget {
  const _AiSupportChatSheet();

  @override
  State<_AiSupportChatSheet> createState() => _AiSupportChatSheetState();
}

class _AiSupportChatSheetState extends State<_AiSupportChatSheet> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isBot': true,
      'text': 'Hello! 👋 I am your GoChef x The GRUB Next Door AI Assistant. How can I help you today?',
    }
  ];

  final List<String> _quickQuestions = [
    '📦 Where is my order & driver?',
    '🍽️ How does Dine-In reservation work?',
    '❌ How do I cancel or modify an order?',
    '💳 Payment, refund, or promo questions',
    '👨‍🍳 Can I message my chef directly?',
    '📍 How is the 5-mile range calculated?',
  ];

  final Map<String, String> _knowledgeBase = {
    'where is my order': 'You can track your order in real-time by tapping "Tracking" on the bottom navigation or in Order History. You\'ll see live progress from preparation to delivery driver arrival!',
    'dine-in': 'Dine-In Booking allows you to reserve a table date & time at the chef\'s kitchen. Simply choose "Dine-In Booking" at checkout, pick your preferred date and time slot, and enjoy zero delivery fees!',
    'cancel': 'You can cancel or modify an order while it is still in "Pending" status from your Order History screen. Once the chef starts preparing, please message the chef directly via Live Chat for urgent changes.',
    'payment': 'We accept credit cards, debit cards, Apple Pay, Google Pay, and Cash on Delivery. Disount promo codes can be applied directly on the checkout summary page.',
    'refund': 'Refunds are automatically processed to your original payment method within 1-3 business days if an order is cancelled or if an item is unavailable.',
    'chef': 'Yes! You can chat directly with your chef in real-time from the Order Tracking screen or Order History by tapping the Chat icon. You can also send photos directly in the chat!',
    '5-mile': 'Our map explorer automatically shows all artisan kitchens and private chefs within a 5-mile radius around your location to guarantee hot, fresh culinary delivery!',
  };

  void _handleSend(String query) {
    if (query.trim().isEmpty) return;

    final userQuery = query.trim();
    _textController.clear();

    setState(() {
      _messages.add({'isBot': false, 'text': userQuery});
    });

    _scrollToBottom();

    // Generate intelligent AI response
    Future.delayed(const Duration(milliseconds: 400), () {
      String answer = 'Thank you for asking! Our support team is here to assist with any questions. You can also reach our text line at +1 (555) 123-4567 or explore our Help Center FAQs.';
      final lower = userQuery.toLowerCase();

      for (var entry in _knowledgeBase.entries) {
        if (lower.contains(entry.key)) {
          answer = entry.value;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _messages.add({'isBot': true, 'text': answer});
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: const Icon(Icons.smart_toy_outlined, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'GoChef AI Support Assistant',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Always online • Instant replies',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 20),

          // Quick Questions Chips
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickQuestions.length,
              itemBuilder: (context, index) {
                final q = _quickQuestions[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    side: const BorderSide(color: Colors.white12),
                    label: Text(q, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    onPressed: () => _handleSend(q),
                  ),
                );
              },
            ),
          ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isBot = msg['isBot'] as bool;
                return Align(
                  alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    decoration: BoxDecoration(
                      color: isBot ? AppColors.surfaceContainerHigh : AppColors.primary,
                      borderRadius: BorderRadius.circular(18).copyWith(
                        bottomLeft: isBot ? const Radius.circular(4) : const Radius.circular(18),
                        bottomRight: !isBot ? const Radius.circular(4) : const Radius.circular(18),
                      ),
                    ),
                    child: Text(
                      msg['text'] as String,
                      style: TextStyle(
                        color: isBot ? Colors.white : AppColors.onPrimary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Ask a question...',
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _handleSend,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: () => _handleSend(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
