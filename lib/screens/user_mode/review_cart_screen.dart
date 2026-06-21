import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import 'track_order_screen.dart';

class ReviewCartScreen extends ConsumerWidget {
  const ReviewCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartItems = cart.values.toList();
    final subtotal = ref.read(cartProvider.notifier).totalCartPrice;
    final total = subtotal + 2.99; // Adding service fee

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChefHeader(cartItems.isNotEmpty ? cartItems.first.menuItem.kitchenId : ''),
                const SizedBox(height: 24),
                _buildCartItems(cartItems, ref),
                const SizedBox(height: 16),
                _buildAddMoreButton(),
                const SizedBox(height: 32),
                _buildOrderSummary(subtotal, total),
                const SizedBox(height: 32),
                _buildDeliveryPreview(),
              ],
            ),
          ),
          _buildBottomActionBar(context, ref, cartItems, total),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.backgroundDark.withValues(alpha: 0.8),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.fuchsiaPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Checkout',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.fuchsiaPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_bag, color: AppTheme.fuchsiaPrimary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildChefHeader(String kitchenId) {
    // Ideally fetch kitchen details using kitchenId
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.3), width: 2),
            image: const DecorationImage(
              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB_1wPLxpKzIZiVytSIBKVMx2b2g7Z-WUvooRuih2WMzNT_YKFk80JEsy8a168gD8XE0oUeqGLItjMd-KOKNxACiIn5AHx0uAIF_44A_ZGjOidCHyWYTeFnOzOHOIpcwRdU1MvvvJTI-HZ0S7VPzIc-DfXpChDcJWPFtnPY0smyOYzPaJB_GOG0tik7U-4sI7CzKy8ebpopoyaT2PyT4AK7_VhE3c9Ycbrg4FV1w0ZNvgvbAV1W8EX5phlj_HhZMZD3MYcMYSNo6sin'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chef Isabella\'s Table', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            Row(
              children: [
                const Icon(Icons.verified, color: Colors.greenAccent, size: 14),
                const SizedBox(width: 4),
                Text('Community-Verified Chef', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCartItems(List<CartItem> items, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(child: Text('Your cart is empty', style: GoogleFonts.inter(color: AppTheme.textSecondary)));
    }
    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCartItem(
            item.menuItem.name,
            '\$${item.totalPrice.toStringAsFixed(2)}',
            'Qty: ${item.quantity}',
            [],
            item.menuItem.imageUrl ?? 'https://via.placeholder.com/150',
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCartItem(String name, String price, String qty, List<String> tags, String imgUrl) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
                    Text(price, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(qty, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Text(tag.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary, letterSpacing: 1)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMoreButton() {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: const Icon(Icons.add_circle, color: AppTheme.fuchsiaPrimary),
      label: const Text('Add more items', style: TextStyle(color: AppTheme.fuchsiaPrimary, fontSize: 16)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1), style: BorderStyle.solid), // Flutter doesn't support dashed border out of the box on OutlinedButton
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildOrderSummary(double subtotal, double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Summary', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 16),
        _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 12),
        _buildSummaryRow('Service Fee', '\$2.99'),
        const SizedBox(height: 12),
        _buildSummaryRow('Delivery', 'FREE', isFree: true),
        const SizedBox(height: 16),
        const Divider(color: Colors.white10),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Total', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            Text('\$${total.toStringAsFixed(2)}', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.fuchsiaPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondary)),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: isFree ? FontWeight.bold : FontWeight.normal, color: isFree ? Colors.greenAccent : AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildDeliveryPreview() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.fuchsiaPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text('Delivery Address', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    ],
                  ),
                  Text('Change', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.fuchsiaPrimary, decoration: TextDecoration.underline)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Icon(Icons.home, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Home (Apt 4B)', style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textPrimary)),
                      Text('742 Evergreen Terrace, Springfield', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context, WidgetRef ref, List<CartItem> cartItems, double total) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor.withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: ElevatedButton(
          onPressed: cartItems.isEmpty ? null : () async {
            final kitchenId = cartItems.first.menuItem.kitchenId;
            // Place real order
            await ref.read(orderProvider.notifier).placeOrder(
              kitchenId,
              '742 Evergreen Terrace, Springfield',
              cartItems,
              total,
            );
            if (context.mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TrackOrderScreen()));
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.fuchsiaPrimary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Continue to Delivery', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}
