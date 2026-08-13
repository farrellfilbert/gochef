import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/notification_bell.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Promo & Rewards',
                      style: AppTextStyles.headlineLgMobile(color: AppColors.primary)
                          .copyWith(fontSize: 24),
                    ),
                    const NotificationBell(iconColor: AppColors.primary),
                  ],
                ),
              ),
            ),

            // Top Card: Vouchers & Subscription
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.confirmation_number, color: Colors.orange, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('25 Vouchers', style: AppTextStyles.bodyLg(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                                    Text('Use now!', style: AppTextStyles.labelSm(color: AppColors.primary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 40, color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.star, color: Colors.green, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('GoChef PLUS', style: AppTextStyles.bodyLg(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                                      Text('Subscribed', style: AppTextStyles.labelSm(color: Colors.green)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.percent, color: AppColors.onSurfaceVariant, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Enter promo code', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 20),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Daily Check-in Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.tertiary],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.card_giftcard, color: Colors.white, size: 28),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('A gift for you!', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                                    Text('Claim your daily coins.', style: AppTextStyles.labelSm(color: Colors.white.withValues(alpha: 0.9))),
                                  ],
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.onPrimary,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text('Claim', style: TextStyle(fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(7, (index) {
                                final isToday = index == 3;
                                final isPast = index < 3;
                                final coins = [2000, 30, 50, 1000, 100, 3000, 150][index];
                                return Column(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isPast ? AppColors.surfaceContainerHigh : (isToday ? AppColors.primary : AppColors.surfaceContainerLow),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: isToday ? AppColors.primary : Colors.transparent),
                                      ),
                                      child: Icon(Icons.monetization_on, size: 20, color: isPast ? AppColors.onSurfaceVariant : (isToday ? Colors.white : AppColors.primary.withValues(alpha: 0.5))),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(coins.toString(), style: AppTextStyles.labelSm(color: isToday ? AppColors.onSurface : AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
                                    Text('Day ${index + 1}', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 9)),
                                  ],
                                );
                              }),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Expires in 7 Days', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                Text('T&C Apply', style: AppTextStyles.labelSm(color: AppColors.primary)),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Food Shortcuts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text('Explore Categories', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          _buildShortcutIcon(Icons.local_fire_department, 'Trending', Colors.orange),
                          const SizedBox(width: 16),
                          _buildShortcutIcon(Icons.ramen_dining, 'Asian', Colors.redAccent),
                          const SizedBox(width: 16),
                          _buildShortcutIcon(Icons.local_pizza, 'Western', Colors.amber),
                          const SizedBox(width: 16),
                          _buildShortcutIcon(Icons.fastfood, 'Fast Food', Colors.purpleAccent),
                          const SizedBox(width: 16),
                          _buildShortcutIcon(Icons.eco, 'Healthy', Colors.green),
                          const SizedBox(width: 16),
                          _buildShortcutIcon(Icons.cake, 'Dessert', Colors.pinkAccent),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Top Promos
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Top Promos Today ~', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        children: [
                          _buildPromoCard('40% OFF', 'Spicy Thai Kitchen', 'Authentic Thai Cuisine', 'https://images.unsplash.com/photo-1559314809-0d155014e29e?w=500&auto=format&fit=crop'),
                          const SizedBox(width: 16),
                          _buildPromoCard('21% OFF', 'Fresh Poke', 'Hawaiian Bowls', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop'),
                          const SizedBox(width: 16),
                          _buildPromoCard('BUY 1 GET 1', 'Burger Master', 'American Fast Food', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildPromoCard(String discount, String title, String subtitle, String imageUrl) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  imageUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                  ),
                  child: Text(
                    discount,
                    style: AppTextStyles.labelSm(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLg(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }
}
