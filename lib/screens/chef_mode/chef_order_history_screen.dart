import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';
import '../../providers/order_provider.dart';

class ChefOrderHistoryScreen extends ConsumerWidget {
  const ChefOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(ref),
              const SizedBox(height: 24),
              _buildFilterAndSearchBar(),
              const SizedBox(height: 24),
              _buildOrderList(ref),
              const SizedBox(height: 32),
              _buildPagination(),
              const SizedBox(height: 100), // padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);
    double lifetimeEarnings = 0.0;
    
    if (ordersAsync.hasValue) {
      for (final order in ordersAsync.value!) {
        if (order.status == 'completed' || order.status == 'delivered') {
          lifetimeEarnings += order.totalAmount;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ANALYTICS', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary, letterSpacing: 1.5)),
                Text('Order History', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ],
            ),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Lifetime Earnings', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                      Text('\$${lifetimeEarnings.toStringAsFixed(2)}', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.payments, color: Colors.orangeAccent, size: 28),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterAndSearchBar() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            style: GoogleFonts.inter(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search customer, order ID, or dish...',
              hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.chefSurfaceVariant.withValues(alpha: 0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.fuchsiaPrimary)),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton(Icons.filter_list, 'Filter'),
                const SizedBox(width: 8),
                _buildFilterButton(Icons.calendar_month, 'Date Range'),
                const SizedBox(width: 8),
                _buildPrimaryButton(Icons.download, 'Export CSV'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: AppTheme.textSecondary, size: 18),
      label: Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPrimaryButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.fuchsiaPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildOrderList(WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);
    
    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text('No orders found yet.', style: TextStyle(color: Colors.white70)),
            ),
          );
        }

        return Column(
          children: orders.map((order) {
            String title = 'Order #${order.id.substring(0, 5)}';
            String imageUrl = 'https://via.placeholder.com/150';
            if (order.items.isNotEmpty && order.items.first.menuItem != null) {
              title = '${order.items.first.quantity}x ${order.items.first.menuItem!.name}';
              imageUrl = order.items.first.menuItem!.imageUrl ?? imageUrl;
              if (order.items.length > 1) {
                title += ' & ${order.items.length - 1} more';
              }
            }

            Color statusColor = AppTheme.fuchsiaPrimary;
            if (order.status == 'completed' || order.status == 'delivered') {
              statusColor = Colors.greenAccent;
            } else if (order.status == 'cancelled') {
              statusColor = Colors.redAccent;
            } else if (order.status == 'pending') {
              statusColor = AppTheme.chefTertiary;
            }

            final isDimmed = order.status == 'cancelled';
            final amountLabel = order.status == 'cancelled' ? 'Refunded' : 'Payout';
            final amountPrefix = order.status == 'cancelled' ? '' : '+';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildOrderItem(
                '#ORD-${order.id.substring(0, 5).toUpperCase()}', 
                order.status, 
                statusColor,
                title, 
                'Customer: ${order.foodie?.fullName ?? "Foodie"}',
                DateFormat('MMM dd, yyyy').format(order.createdAt), 
                DateFormat('hh:mm a').format(order.createdAt), 
                amountLabel, 
                '$amountPrefix\$${order.totalAmount.toStringAsFixed(2)}',
                imageUrl,
                isDimmed: isDimmed,
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.fuchsiaPrimary)),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildOrderItem(
    String id, String status, Color statusColor,
    String title, String subtitle,
    String date, String time, String amountLabel, String amount,
    String imgUrl, {bool isDimmed = false}
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(id, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(date, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                Text(time, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text(amountLabel, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                Text(amount, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: isDimmed ? AppTheme.textSecondary : AppTheme.fuchsiaPrimary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageNavButton(Icons.chevron_left),
        const SizedBox(width: 16),
        _buildPageNumber('1', isActive: true),
        const SizedBox(width: 8),
        _buildPageNumber('2'),
        const SizedBox(width: 8),
        _buildPageNumber('3'),
        const SizedBox(width: 16),
        _buildPageNavButton(Icons.chevron_right),
      ],
    );
  }

  Widget _buildPageNavButton(IconData icon) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Icon(icon, color: AppTheme.textSecondary),
    );
  }

  Widget _buildPageNumber(String number, {bool isActive = false}) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.fuchsiaPrimary : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: isActive ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      alignment: Alignment.center,
      child: Text(number, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isActive ? Colors.white : AppTheme.textSecondary)),
    );
  }
}
