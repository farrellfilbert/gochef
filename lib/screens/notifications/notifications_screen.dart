import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/notification_model.dart';
import '../../widgets/custom_app_bar_title.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Orders', 'Promotions'];
  
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final notifs = await ApiService.getNotifications();
      setState(() {
        _notifications = (notifs['notifications'] as List).cast<NotificationModel>();
      });
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    final success = await ApiService.markNotificationRead(notificationId);
    if (success) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: _notifications[index].id,
            title: _notifications[index].title,
            message: _notifications[index].message,
            type: _notifications[index].type,
            isRead: true,
            createdAt: _notifications[index].createdAt,
          );
        }
      });
    }
  }

  Future<void> _markAllAsRead() async {
    for (var notif in _notifications) {
      if (!notif.isRead) {
        await _markAsRead(notif.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<NotificationModel> filteredNotifs = _notifications;
    if (_selectedFilter == 1) { // Orders
      filteredNotifs = _notifications.where((n) => n.type == 'order').toList();
    } else if (_selectedFilter == 2) { // Promotions
      filteredNotifs = _notifications.where((n) => n.type == 'promotion').toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        title: const CustomAppBarTitle(subtitle: 'Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Notifications', style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)),
                GestureDetector(
                  onTap: _markAllAsRead,
                  child: Text('Mark all as read', style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Category Tabs
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  bool isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: isSelected ? Colors.transparent : AppColors.outlineVariant.withValues(alpha: 0.2)),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.3), blurRadius: 15)]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _filters[index],
                        style: AppTextStyles.labelMono(color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Notifications List
            if (filteredNotifs.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text('No notifications found', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
                ),
              )
            else
              ...filteredNotifs.map((n) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildNotificationCard(
                    notification: n,
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required NotificationModel notification,
  }) {
    IconData icon = Icons.notifications;
    Color iconColor = AppColors.primary;

    if (notification.type == 'order') {
      icon = Icons.restaurant;
      iconColor = AppColors.primaryContainer;
    } else if (notification.type == 'promotion') {
      icon = Icons.sell;
      iconColor = AppColors.tertiary;
    }

    return GestureDetector(
      onTap: () {
        if (!notification.isRead) _markAsRead(notification.id);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2029).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA98890).withValues(alpha: 0.1)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: iconColor.withValues(alpha: 0.2)),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                if (!notification.isRead)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 2),
                        boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.3), blurRadius: 10)],
                      ),
                    ),
                  )
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
                      Expanded(
                        child: Text(notification.title, style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(DateTime.tryParse(notification.createdAt) ?? DateTime.now()), 
                        style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6))
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notification.message, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(height: 1.2)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
