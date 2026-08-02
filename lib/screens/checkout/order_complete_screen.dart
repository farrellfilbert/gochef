import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import '../home/home_screen.dart';
import '../tracking/order_tracking_screen.dart';

class OrderCompleteScreen extends StatelessWidget {
  const OrderCompleteScreen({super.key});

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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outline.withValues(alpha: 0.2)),
                image: const DecorationImage(
                  image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuC4Qw18XxKU0uFFKj5sSYIBv-F96KGx7m4rdcu5yYtqbtVBX5UZrALRBRD2N8tuUc2WugWUH194qn3siP0vygHXmbBzzmn7MbttTH7tmAZZXVA8XZahE7HD_0yYDjns05_tc80RgHwNPW79tdIMtRERy-hQIEG4y4BuYj4Is5fSU659MTS3I5gYkWWHYvKVyDDPqf990YnbGuaX6UKOEmlnKKdY56jFRb-WYI5DTTbZceq9djgxdv6dPQ'),
                  fit: BoxFit.cover,
                ),
              ),
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
                
                Text('Order Placed!', style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)),
                const SizedBox(height: 8),
                Text(
                  'Your gourmet experience is being prepared.',
                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Order #GC-99210',
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
                              image: const DecorationImage(
                                image: NetworkImage(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB46OgfjAhCCn-4KrgUa2u6_enMtNRSDF7MGR-yGf1cfaEr3fmHSSGB-npBtKJqARBnfjRP8ZfOQ7zXp91w5TBKWpCQGsttu2lZhpOmG-F9tlR45OCwfYic8OfiTlwYr_UlRRMY84YKPA4qc23r1JV1v-pNhymi4t8qX5B4ewxmRic8sfEj-QCs9glx3GORoaqHoDriDCYpowXNBnWs7DCJnE__z0MkrvsduMiECJWP69bMUSCEtzDFPA'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Truffle Risotto & Fine Wine', style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16)),
                                Text('2 Items • Arriving in 35-45 min', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
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
                              Text('Estimated Arrival: 8:45 PM', style: AppTextStyles.labelSm(color: AppColors.onSurface)),
                            ],
                          ),
                          Text('\$63.00', style: AppTextStyles.headlineMd(color: AppColors.primary)),
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
                            Text('Earned 120 Loyalty Points', style: AppTextStyles.labelSm(color: AppColors.tertiary).copyWith(fontWeight: FontWeight.bold)),
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
                      MaterialPageRoute(builder: (context) => const OrderTrackingScreen()),
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
                const SizedBox(height: 32),
                
                // Suggestion
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('While you wait...', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuATeQGnzuIpiDuNJvNPdmYEEKY_w62gAfTko7DuKOKS9kWLTiqwslb_6_KJxppQ80IF_X32xAgaHSC3uw4TlRz2YDf2u-zMDUL_EVcCkFZmaZPXxKM_GnnjNiVGBuhSJ2GkT7IBitAfXtm34ep-b-U8QcE5xCcHfygffrUQH1ypmiwCneSDNNsiwxK5dfeURRC-a_vkO3Vq3OCceieHvEojMoC5x0SN1vosRbxSRZ2Is0-12simphPqsg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rate Chef Marco', style: AppTextStyles.labelSm(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                            Text('Last order from 3 days ago', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppColors.primary, size: 16),
                          Icon(Icons.star, color: AppColors.primary, size: 16),
                          Icon(Icons.star, color: AppColors.primary, size: 16),
                          Icon(Icons.star, color: AppColors.primary, size: 16),
                          Icon(Icons.star_border, color: AppColors.outline, size: 16),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
