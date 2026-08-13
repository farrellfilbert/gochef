import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/notification_model.dart';
import '../../models/order_model.dart';
import '../chat/chat_screen.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  bool _isLoading = true;
  String _currentUserId = '';
  List<NotificationModel> _promos = [];
  List<Map<String, dynamic>> _chats = [];
  List<OrderModel> _activeOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final userId = await ApiService.getUserId() ?? '';
      final results = await Future.wait([
        ApiService.getOrders(),
        ApiService.getChatInbox(),
        ApiService.getNotifications(),
      ]);

      final allOrders = results[0] as List<OrderModel>;
      final allChats = results[1] as List<Map<String, dynamic>>;
      final allNotifs = results[2] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _currentUserId = userId;
          // Filter active orders for tracking
          _activeOrders = allOrders.where((o) => o.status != 'Completed' && o.status != 'Cancelled').toList();
          _chats = allChats;
          _promos = (allNotifs['data'] as List? ?? []).map((n) => NotificationModel.fromJson(n)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    final success = await ApiService.markNotificationRead(notificationId);
    if (success) {
      setState(() {
        final index = _promos.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _promos[index] = NotificationModel(
            id: _promos[index].id,
            title: _promos[index].title,
            message: _promos[index].message,
            createdAt: _promos[index].createdAt,
            isRead: true,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        elevation: 0,
        centerTitle: true,
        title: Text('Notifications', style: AppTextStyles.headlineMd(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          tabs: const [
            Tab(text: 'System'),
            Tab(text: 'Chats'),
            Tab(text: 'Promos'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSystemTab(),
                _buildChatsTab(),
                _buildPromosTab(),
              ],
            ),
    );
  }

  Widget _buildSystemTab() {
    if (_activeOrders.isEmpty) {
      return Center(
        child: Text('No active orders to track', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeOrders.length,
        itemBuilder: (context, index) {
          final order = _activeOrders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order.kitchenName, style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                    Text('Order #${order.id}', style: AppTextStyles.labelSm(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildOrderTracker(order.status),
                const SizedBox(height: 16),
                Center(
                  child: Text('Expected arrival: in 30 mins', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderTracker(String status) {
    const statuses = ['Active', 'Preparing', 'Ready', 'Completed'];
    int currentIndex = statuses.indexOf(status);
    if (currentIndex == -1) currentIndex = 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        bool isCompleted = index <= currentIndex;
        bool isCurrent = index == currentIndex;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      color: index == 0 ? Colors.transparent : (isCompleted ? AppColors.primary : AppColors.surfaceContainerHighest),
                    ),
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted ? AppColors.primary : AppColors.surfaceContainerHighest,
                      border: isCurrent ? Border.all(color: Colors.white, width: 2) : null,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 4,
                      color: index == 3 ? Colors.transparent : (isCompleted && !isCurrent ? AppColors.primary : AppColors.surfaceContainerHighest),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                statuses[index],
                style: AppTextStyles.labelSm(color: isCurrent ? AppColors.primary : AppColors.onSurfaceVariant).copyWith(fontSize: 10),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildChatsTab() {
    if (_chats.isEmpty) {
      return Center(
        child: Text('No messages yet', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          final unreadCount = int.tryParse(chat['unread_count']?.toString() ?? '0') ?? 0;
          final isUnread = unreadCount > 0;
          
          String otherName = chat['name'] ?? 'Unknown';
          if (chat['order_id'] != null && chat['order_id'].toString().isNotEmpty) {
            otherName = '$otherName (Order #${chat['order_id']})';
          }
          final otherAvatar = chat['avatar'] ?? '';
          
          DateTime time;
          try {
            time = DateTime.parse(chat['created_at']);
          } catch (_) {
            time = DateTime.now();
          }

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.surfaceContainerLow,
                  backgroundImage: otherAvatar.isNotEmpty ? NetworkImage(otherAvatar) : null,
                  child: otherAvatar.isEmpty ? const Icon(Icons.store, color: AppColors.onSurfaceVariant) : null,
                ),
                if (isUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
              ],
            ),
            title: Text(
              otherName, 
              style: AppTextStyles.bodyLg(color: Colors.white).copyWith(
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal
              )
            ),
            subtitle: Text(
              chat['last_message'] ?? '', 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMd(color: isUnread ? Colors.white : AppColors.onSurfaceVariant),
            ),
            trailing: Text(
              DateFormat('HH:mm').format(time),
              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
            ),
            onTap: () {
              final otherId = chat['other_user_id']?.toString() ?? '';
              final orderId = chat['order_id']?.toString();
                  
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    otherParticipantId: otherId,
                    otherParticipantName: otherName,
                    otherParticipantAvatar: otherAvatar,
                    orderId: orderId,
                  ),
                ),
              ).then((_) => _loadAllData()); // Refresh when back
            },
          );
        },
      ),
    );
  }

  Widget _buildPromosTab() {
    if (_promos.isEmpty) {
      return Center(
        child: Text('No promotions available', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadAllData,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _promos.length,
        itemBuilder: (context, index) {
          final promo = _promos[index];
          return GestureDetector(
            onTap: () {
              if (!promo.isRead) {
                _markAsRead(promo.id);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: promo.isRead ? AppColors.surface : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: promo.isRead ? Colors.transparent : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_offer, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                promo.title,
                                style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16),
                              ),
                            ),
                            if (!promo.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          promo.message,
                          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
