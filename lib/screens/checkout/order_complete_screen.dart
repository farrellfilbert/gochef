import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import '../home/home_screen.dart';
import '../tracking/order_tracking_screen.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';

class OrderCompleteScreen extends StatelessWidget {
  final String orderId;
  final String kitchenId;
  final String kitchenName;
  final double totalAmount;
  final int itemsCount;
  final String kitchenAvatar;

  const OrderCompleteScreen({
    super.key,
    required this.orderId,
    required this.kitchenId,
    required this.kitchenName,
    required this.totalAmount,
    required this.itemsCount,
    required this.kitchenAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        automaticallyImplyLeading: false, // Hide back button for success screen
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'GoChef',
              style: AppTextStyles.headlineLgMobile(color: AppColors.primary).copyWith(fontSize: 20),
            ),
            FutureBuilder<UserModel>(
              future: ApiService.getProfile(),
              builder: (context, snapshot) {
                String avatarUrl = 'https://gochef.my.id/assets/default_avatar.png';
                if (snapshot.hasData && snapshot.data!.avatar.isNotEmpty) {
                  avatarUrl = snapshot.data!.avatar;
                }
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                    image: DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
            )
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
        ),
      ),
      body: Stack(
        children: [
          // Ambient background glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: -100,
            right: -100,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 120,
                    spreadRadius: 120,
                  )
                ],
              ),
            ),
          ),
          
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // GoChef Logo
                Image.asset(
                  'assets/images/GoCheflogo.png',
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Success Icon
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryContainer.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: const Icon(Icons.check, color: AppColors.onPrimaryContainer, size: 48),
                ),
                const SizedBox(height: 24),
                
                Text('Payment Successful!', style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)),
                const SizedBox(height: 8),
                Text(
                  'Your order has been placed and is being prepared.',
                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Order #$orderId',
                  style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Order Summary Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF31353F).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFA98890).withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(kitchenAvatar.isNotEmpty ? kitchenAvatar : 'https://gochef.my.id/assets/default_avatar.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(kitchenName, style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16)),
                                Text('$itemsCount Items • Arriving in 35-45 min', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Builder(
                                builder: (context) {
                                  final time = DateTime.now().add(const Duration(minutes: 40));
                                  final ampm = time.hour >= 12 ? 'PM' : 'AM';
                                  final hr = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
                                  final mn = time.minute.toString().padLeft(2, '0');
                                  return Text('Estimated Arrival: $hr:$mn $ampm', style: AppTextStyles.labelSm(color: AppColors.onSurface));
                                }
                              ),
                            ],
                          ),
                          Text('\$${totalAmount.toStringAsFixed(2)}', style: AppTextStyles.headlineMd(color: Colors.white)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Engagement Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryContainer.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars, color: AppColors.tertiary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Earned ${(totalAmount * 10).toInt()} Loyalty Points', style: AppTextStyles.labelSm(color: AppColors.tertiary).copyWith(fontWeight: FontWeight.bold)),
                            Text('Redeemable for your next feast', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Actions
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => OrderTrackingScreen(
                        orderId: orderId,
                        kitchenId: kitchenId,
                        kitchenName: kitchenName,
                        totalAmount: totalAmount,
                        itemsCount: itemsCount,
                        kitchenAvatar: kitchenAvatar,
                        fromCheckout: true,
                      )),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryContainer.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Track Order',
                      style: AppTextStyles.headlineMd(color: AppColors.onPrimaryContainer).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false, // Clears the stack
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outline),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Back to Home',
                      style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          )
        ],
      ),
    );
  }
}
