import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Stack(
        children: [
          // ─── Main Scrollable Content ───
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 80, // Space for fixed header
                bottom: 140, // Space for fixed footer
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Delivery Address ───
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.location_on, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Deliver to',
                                  style: AppTextStyles.labelSm(
                                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  'University District, Arts District',
                                  style: AppTextStyles.bodyMd(color: AppColors.onSurface)
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Change',
                            style: AppTextStyles.labelMono(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Order Details ───
                  Text(
                    'Order Details',
                    style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                  ),
                  const SizedBox(height: 12),
                  
                  // Item 1
                  _buildCartItem(
                    title: 'Wild Mushroom Tagliatelle',
                    price: '\$24.50',
                    chef: 'Chef Elena Rossi',
                    extra: 'Extra Aged Parmesan',
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA7DN7aS4xXj8hcOgsyJG1NnQKmsRfrKyqtYOT8qwRqJwCGFs0YodHw-WmImFFka3fL8J8P5V8MCyPVN7rx7dDDT4MF7wN_PH-8jo8D3pzwc-9-pvu905WFTugtwCurIYD6OV69Z036kDVv0Tekohk3qQ0UdzjNe5DWFf2IjS-_ns3K0oUgwK5hEyStoPyXHUHXky_nfz8xctgto_8F1df0TjhTAFNO9owXKLwVW3dpOkBWsq8QifLMmQ',
                  ),
                  const SizedBox(height: 12),
                  // Item 2
                  _buildCartItem(
                    title: 'Saffron Sea Bass',
                    price: '\$32.00',
                    chef: 'Chef Marcus Thorne',
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDqYm7OptoH5jMnNDyyB0UbKh-Gz6upan0kgeheBJBpLMbelOSFPOsFzHgvz6xjwDjfugH8N2Cva4uiizTBkTF0AvvDmAw93wn9Ms6sWS6ZS0BJxK01HZzhKdpc6R2kP7IofDU3y0Cg_jFtKFnUO1eFzA2OSGVSPjUXgCeko5LEYZfdke-7D0UgEbFH6fguH1Fqj2J5cCSSYeLMu07gAk-2d6ovH888L6HE3lna499VRbFaRPci0kRGgQ',
                  ),
                  const SizedBox(height: 24),

                  // ─── Promo Code ───
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.loyalty, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                            decoration: InputDecoration(
                              hintText: 'Promo code or coupon',
                              hintStyle: AppTextStyles.bodyMd(
                                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Apply',
                            style: AppTextStyles.labelMono(color: AppColors.primary)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Order Summary ───
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow('Subtotal', '\$56.50'),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Delivery Fee', '\$4.00'),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Service Fee', '\$2.50'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: AppColors.ghostBorder),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                            ),
                            Text(
                              '\$63.00',
                              style: AppTextStyles.headlineMd(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Fixed Header ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 16,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    border: Border(
                      bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                            onPressed: () {
                              if (Navigator.canPop(context)) Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your Cart',
                            style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                          ),
                        ],
                      ),
                      Text(
                        'CLEAR ALL',
                        style: AppTextStyles.labelMono(color: AppColors.primary)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Fixed Footer Checkout ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 32),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.9),
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GRAND TOTAL',
                                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)
                                    .copyWith(letterSpacing: 2),
                              ),
                              Text(
                                '\$63.00',
                                style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.timer, color: AppColors.primary, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '35-45 min',
                                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4A90), Color(0xFFBA005E)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                              );
                            },
                            borderRadius: BorderRadius.circular(28),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Proceed to Checkout',
                                  style: AppTextStyles.headlineMd(color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        Text(
          value,
          style: AppTextStyles.labelMono(color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildCartItem({
    required String title,
    required String price,
    required String chef,
    String? extra,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyLg(color: AppColors.onSurface)
                            .copyWith(fontWeight: FontWeight.bold, height: 1.2),
                      ),
                    ),
                    Text(
                      price,
                      style: AppTextStyles.bodyMd(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'by $chef',
                      style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                if (extra != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    extra,
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Selector
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () {},
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            color: AppColors.onSurface,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '1',
                              style: AppTextStyles.labelMono(color: AppColors.onSurface)
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () {},
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            color: AppColors.onSurface,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
