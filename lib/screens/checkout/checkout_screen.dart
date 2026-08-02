import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import 'order_complete_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isAsap = true;
  String selectedPayment = 'mastercard'; // 'mastercard', 'apple', 'google'
  bool isOrdering = false;

  void _placeOrder() {
    setState(() {
      isOrdering = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrderCompleteScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Checkout',
            style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Delivery Address',
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    TextButton(
                      onPressed: () {},
                      child: Text('Edit', style: AppTextStyles.labelMono(color: AppColors.primary)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('University District',
                                style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('1224 Arts District Way, Apt 4B\nSeattle, WA 98105',
                                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant.withValues(alpha: 0.8))),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Delivery Time
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isAsap = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isAsap ? const Color(0xFFE42278) : Colors.transparent,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: isAsap
                                  ? [BoxShadow(color: const Color(0xFFE42278).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 4))]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'ASAP (25-35 min)',
                              style: AppTextStyles.bodyMd(
                                color: isAsap ? AppColors.onSurface : AppColors.onSurfaceVariant,
                              ).copyWith(fontWeight: isAsap ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isAsap = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isAsap ? const Color(0xFFE42278) : Colors.transparent,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: !isAsap
                                  ? [BoxShadow(color: const Color(0xFFE42278).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 4))]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Schedule',
                              style: AppTextStyles.bodyMd(
                                color: !isAsap ? AppColors.onSurface : AppColors.onSurfaceVariant,
                              ).copyWith(fontWeight: !isAsap ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Method
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment Method',
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    TextButton(
                      onPressed: () {},
                      child: Text('Change', style: AppTextStyles.labelMono(color: AppColors.primary)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                
                // Mastercard
                GestureDetector(
                  onTap: () => setState(() => selectedPayment = 'mastercard'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedPayment == 'mastercard'
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.credit_card, color: AppColors.onSurface),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mastercard', style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                              Text('•••• 8829', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedPayment == 'mastercard' ? AppColors.primary : AppColors.outline,
                              width: 2,
                            ),
                          ),
                          child: selectedPayment == 'mastercard'
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : null,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Alt methods
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedPayment = 'apple'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedPayment == 'apple' ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.apple, color: AppColors.onSurface),
                              const SizedBox(width: 8),
                              Text('Apple Pay', style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedPayment = 'google'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedPayment == 'google' ? AppColors.primary.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // A simple text stand-in for GPay since we can't easily draw the SVG here
                              Text('G', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
                              const SizedBox(width: 4),
                              Text('Pay', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Order Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order Summary',
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    Text('2 Items', style: AppTextStyles.labelMono(color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      _buildOrderItem(
                        'Wild Mushroom Tagliatelle',
                        '\$28.00',
                        'Extra Truffle Oil, No Parsley',
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDfhHoOQsqmla2NxkZRwyH5o4mAvCMG1koOcXJS-UmWLw0lclqCbC82tlTaG78GaAE8HFBiCU6FJZFxCpR-OiLpZImP8W9fbS5x_7290JeMHPiY8wez_0T7ih9S_pN8zFWxNY9b5G93SK3shpyVsaIhDyzkFAADScoWPlFeGweNF2i6QJV6ykSN8jWm8Ak7Dnhy9pQcbDy-ZMj6BqT52hrQmI6eq6TT2cnueVkbbLD87YvufCjOwmzbcw',
                      ),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildOrderItem(
                        'Saffron Sea Bass',
                        '\$32.50',
                        'Side of Roasted Asparagus',
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuA0c_Y4mE1EfQuA-qVzT3TFzG0SfIZnEHqNvpKTJmet3_R1nMtXgLv-FvOjUnxYpA_yG9wk8HBYNXbTJZGHxAOSj84PUSzxsgK_ZaE0zr68C4u01KB_mXD_xd6mYSLF_MIDPuHW3k5iXHT06f5YXS2TQnknatptQXyRFDk-637dxXVGAPNE7Qv4K_G-iHnt0GpyW2xaGti-PE6ZMcP4M09XvWNskp8C2EdQV2ALf6bblJQg5PPodcnZ6A',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Breakdown
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      _buildBreakdownRow('Subtotal', '\$60.50'),
                      const SizedBox(height: 12),
                      _buildBreakdownRow('Delivery Fee', '\$4.00'),
                      const SizedBox(height: 12),
                      _buildBreakdownRow('Service Fee', '\$2.50'),
                      const SizedBox(height: 12),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                          Text('\$63.00', style: AppTextStyles.headlineMd(color: AppColors.primary)),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Action
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 32, top: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withValues(alpha: 0.9),
                    AppColors.background.withValues(alpha: 0),
                  ],
                ),
              ),
              child: GestureDetector(
                onTap: _placeOrder,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: isOrdering ? Colors.green : const Color(0xFFE42278),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: isOrdering
                            ? Colors.green.withValues(alpha: 0.4)
                            : const Color(0xFFE42278).withValues(alpha: 0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  alignment: Alignment.center,
                  child: isOrdering
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                        )
                      : Text(
                          'Place Order - \$63.00',
                          style: AppTextStyles.headlineMd(color: Colors.white),
                        ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrderItem(String title, String price, String desc, String imgUrl) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imgUrl),
                fit: BoxFit.cover,
              ),
            ),
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
                    Text(price, style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
        Text(value, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
