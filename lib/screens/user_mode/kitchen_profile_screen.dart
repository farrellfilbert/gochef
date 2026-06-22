import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/menu_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/premium/glass_card.dart';
import 'recipe_details_screen.dart';
import 'dart:math' as math;

class KitchenProfileScreen extends ConsumerWidget {
  final Kitchen kitchen;
  const KitchenProfileScreen({super.key, required this.kitchen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).totalCartPrice;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      floatingActionButton: cart.isNotEmpty ? FloatingActionButton.extended(
        onPressed: () async {
          final items = cart.values.toList();
          try {
            await ref.read(orderProvider.notifier).placeOrder(
              kitchen.id,
              'Dummy Address 123', // Hardcoded for now
              items,
              total,
            );
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed successfully!')));
            Navigator.pop(context); // Go back to explore
          } catch(e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
          }
        },
        backgroundColor: AppTheme.fuchsiaPrimary,
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: Text('Checkout - \$${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ) : null,
      body: CustomScrollView(
        slivers: [
          // Hero App Bar
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            backgroundColor: AppTheme.backgroundDark,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: AppTheme.surfaceLight.withValues(alpha: 0.5), shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(color: AppTheme.surfaceLight.withValues(alpha: 0.5), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: AppTheme.textPrimary),
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(color: AppTheme.surfaceLight.withValues(alpha: 0.5), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.share, color: AppTheme.textPrimary),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    kitchen.coverImageUrl ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuAooa_6Otp4bv9mi8oMO1jEJmSpu98sfj83EnWZANii4K14-Ls-VhefSKglfvj0zfYyEgco9PLNlmvJviK6AQAzwDbE3z2_ItskellUdO6u508eWOAjoz_kXgk4o750mNgy_BXlGd_624f0uwwAC5eiVG6TwPtZYJXDeiDeYvId-mn5Dgw-rrRqo2p0BKrkMXLa652Q4QE5xY0xRBHOo3OmBXMBz_Mnx4bi5hUw7bRYKephdWRRiMgvsofqdw5lnZ0fvVXMf-uDGv3b',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppTheme.backgroundDark.withValues(alpha: 0.9)],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified, size: 14, color: Colors.green),
                                  const SizedBox(width: 4),
                                  Text('Verified Kitchen', style: GoogleFonts.inter(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GlassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.history, size: 14, color: AppTheme.textPrimary),
                                  const SizedBox(width: 4),
                                  Text('Checked 2 days ago', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textPrimary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(kitchen.name, style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        Text('"${kitchen.description ?? 'Authentic Flavors'}"', style: GoogleFonts.inter(fontSize: 14, fontStyle: FontStyle.italic, color: AppTheme.fuchsiaPrimary)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStat(kitchen.rating.toString(), 'Ratings', Icons.star),
                            const SizedBox(width: 16),
                            Container(height: 30, width: 1, color: Colors.white24),
                            const SizedBox(width: 16),
                            _buildStat('0', 'Reviews', null),
                            const SizedBox(width: 16),
                            Container(height: 30, width: 1, color: Colors.white24),
                            const SizedBox(width: 16),
                            _buildStat('15m', 'Delivery', null),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Sticky Tabs (Simulated)
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 50.0,
              maxHeight: 50.0,
              child: Container(
                color: AppTheme.backgroundDark.withValues(alpha: 0.95),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTab('Menu', isActive: true),
                    _buildTab('Reviews'),
                    _buildTab('Story'),
                    _buildTab('Photos'),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer(
                builder: (context, ref, child) {
                  final menuAsync = ref.watch(menuProvider);
                  
                  return menuAsync.when(
                    data: (allItems) {
                      final items = allItems.where((i) => i.kitchenId == kitchen.id).toList();
                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 64),
                          child: Center(
                            child: Text('This chef hasn\'t added any menu items yet.', style: TextStyle(color: AppTheme.textSecondary)),
                          ),
                        );
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Menu Items', 'Fresh from ${kitchen.name}.'),
                          const SizedBox(height: 16),
                          ...items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildDishCard(
                              context,
                              ref,
                              item,
                            ),
                          )).toList(),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.fuchsiaPrimary)),
                    error: (e, st) => Center(child: Text('Error: $e')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String val, String label, IconData? icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(val, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            if (icon != null) const SizedBox(width: 4),
            if (icon != null) Icon(icon, size: 16, color: Colors.orange),
          ],
        ),
        Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildTab(String title, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isActive ? AppTheme.fuchsiaPrimary : Colors.transparent, width: 2)),
      ),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? AppTheme.fuchsiaPrimary : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            Text(subtitle, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ),
        Text('View Full Menu', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.fuchsiaPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDishCard(BuildContext context, WidgetRef ref, MenuItem item) {
    final tags = item.category != null ? [item.category!] : [];
    
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailsScreen(
          dishName: item.name,
          heroImage: item.imageUrl ?? 'https://via.placeholder.com/150',
          chefName: kitchen.name,
        )));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: Image.network(item.imageUrl ?? 'https://via.placeholder.com/150', width: 120, height: 120, fit: BoxFit.cover),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(item.name, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))),
                        Text('\$${item.price.toStringAsFixed(2)}', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.description ?? '', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: tags.map((t) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(4)),
                            child: Text(t.toUpperCase(), style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                          )).toList(),
                        ),
                        GestureDetector(
                          onTap: () {
                            ref.read(cartProvider.notifier).addItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added to cart!')));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: AppTheme.fuchsiaPrimary, shape: BoxShape.circle),
                            child: const Icon(Icons.add, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailySpecialHero() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCp9Hu7Qpffd7LthKWsgJM-05SztIbqyB9JrHz3DmtZNyC-2mqOSNeSJlkLj5vXQKKiRF0V6LTZGY7AkqEwEUUQHeZLOaF2cbwAxpHmlq6IPQXt1VnhmiP0cHi9zvyCLq_UfWgbyd5Fy_T8F05sld1MCciY8DuQ8TS_wwWUomW0KJaOIUnzd3mCjTt_MxjaWSex1NaY8GugOAF-wxdvg9XCIwTotIu_l_TOvPTLAcUaI-pkIQYb9uZolXF35bweRcet5QnN_-GAepfb'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, AppTheme.backgroundDark.withValues(alpha: 0.9)],
          ),
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.all(16),
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('FRESH PICK', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                    Text('Summer Harvest Bowl', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    Text('Our seasonal best with roasted corn, poblano peppers, and lime-cilantro quinoa.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary), maxLines: 2),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$14.99', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.fuchsiaPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAIV3gPDOeeyw5fd-8yOT9QUA3MU17htppuB7biJS0aBlcXLZAoYWan8JKOw_KpJapDLd54y5nz4K4iDjurqktGjZHhkSBTzbVxPkaeCs2Gz2nVOJFEj6wKkXgKahxlxzjWzuzvDN3CHT7SRung84fkm-HWy1yeGG7FeICyv53NQCgiPEUg6ogPpZGOd-jC7hjMUc3yX5mCvd8TQvuAyaNkr-ufw-i8smzM7Gf7KwQ1bUbb1lmiLw-TC85F2_0pucSDP4pqsviZElrd'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Text('Chef\'s Story', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.fuchsiaPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('The Oaxacan Soul', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('"Cooking is how I share my heritage with the neighborhood."', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size(double.infinity, 36),
            ),
            child: Text('Read More', style: GoogleFonts.inter(color: AppTheme.fuchsiaPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildPairingsCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCWU9At0Xg3C0ZlI8HQl-xdSabRbj--TI7B0we3r_6QNErtubpzLVH5PopYjowloQOPfjgGmTV_6G7e6h6JuafGg6YoRd4pOHILG-FiRoAo-OsE8csjIWHPS9qK3JH9X5dBeXmlbR6oZwd-k-YyxcmJP7pzLdU0DC8N8Z1oBhX_IsRyJ48F9qnyf9MnzvjrxsVQJ3eYFEgQJomO18yeZPxSMJTw7K48KoblbckBFB5zentyr8TDuHI7ezyBuAJY6py8HseVEI9Xr9s0'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.backgroundDark.withValues(alpha: 0.5),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pairings', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('View Drinks Menu', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.fuchsiaPrimary)),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
