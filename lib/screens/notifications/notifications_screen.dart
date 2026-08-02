import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Orders', 'Promotions'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                image: const DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDmj8hgyvwYqvYQqz9ke9LLzp8aKdCCuoCq-fmpL1KRFEzVqSTfxbnMSG-Vu8vC6h9enXJQFedwTkocVED9mRa-E4rD4BWoolc1QCtRecvrEx2FwoRa2Zt2b9pHRiO-mmzWDZcPFSjanjzzNK7oj-iWwJ3Ki3Q35z_S0C1XRcpdfYh0utEv3AnPEhlcn8wJK6tWfs-pIFlApjeSXAWXRwYirMH1xfeisLtnIHv2bBvJAvAFOE5oOCiQoA'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('GoChef', style: AppTextStyles.headlineLgMobile(color: AppColors.primary).copyWith(fontSize: 20)),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'University District',
                      style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Notifications', style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)),
                Text('Mark all as read', style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(decoration: TextDecoration.underline)),
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
            _buildNotificationCard(
              icon: Icons.restaurant,
              iconColor: AppColors.primaryContainer,
              title: 'Order #GC-99210 Prepared',
              time: '2m ago',
              description: 'Chef Elena has just started preparing your Truffle Risotto. Expect delivery in 20 mins.',
              isUnread: true,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.sell,
              iconColor: AppColors.tertiary,
              title: 'Weekend Special',
              time: '1h ago',
              description: 'Enjoy 20% off all Italian Kitchens this Saturday! Book your private chef table now.',
              isUnread: false,
            ),
            const SizedBox(height: 12),
            _buildNotificationCardWithImage(
              imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAFRCmj_r9VK400WojFaLqAOv201ao1yO09OU1mpOkGARCuKaAdHlY2DsD5RVJTqorbO6r_sH7ttzrp-8Z5gX6q__Q9LbUaILPY53iMVIDwA0ISRY5Kk5byFphjw_x5TOhYNtaExdWI7F7EPvg3sE3wSLMp7ufqTs1FJ0WTG2_WFPsPOoiP75EpCVSVsMYso4ofmA1_2QxQubz99B2dXXtK7fBiiVVeDXxFOTvA3ojzGvK8ymC0AEHTGg',
              title: 'New Seasonal Menu',
              time: '4h ago',
              description: 'Chef Maria Rossi just uploaded a new autumn-inspired menu featuring wild mushroom pairings.',
              isUnread: true,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.delivery_dining,
              iconColor: AppColors.secondary,
              title: 'Order Delivered',
              time: 'Yesterday',
              description: 'Enjoy your meal! Order #GC-98122 from Chef Marco has been delivered.',
              isUnread: false,
            ),
            const SizedBox(height: 12),
            _buildNotificationCard(
              icon: Icons.person_pin_circle,
              iconColor: AppColors.primary,
              title: 'New Chef Nearby',
              time: '2d ago',
              description: 'A Michelin-star pastry chef just joined GoChef in your neighborhood. Discover their treats!',
              isUnread: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required String description,
    required bool isUnread,
  }) {
    return Container(
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
              if (isUnread)
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
                    Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                    Text(time, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(height: 1.2)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNotificationCardWithImage({
    required String imageUrl,
    required String title,
    required String time,
    required String description,
    required bool isUnread,
  }) {
    return Container(
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
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                ),
              ),
              if (isUnread)
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
                    Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                    Text(time, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(height: 1.2)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
