import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/chef_bottom_nav.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/kitchen_provider.dart';
import '../../providers/order_provider.dart';
import 'package:intl/intl.dart';

class ChefDashboardScreen extends ConsumerStatefulWidget {
  const ChefDashboardScreen({super.key});

  @override
  ConsumerState<ChefDashboardScreen> createState() => _ChefDashboardScreenState();
}

class _ChefDashboardScreenState extends ConsumerState<ChefDashboardScreen> {
  int _currentIndex = 0;
  bool _isKitchenOpen = false;
  bool _kitchenInitialized = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final kitchenAsync = ref.watch(myKitchenProvider);
    
    if (kitchenAsync.hasValue && kitchenAsync.value != null && !_kitchenInitialized) {
      _isKitchenOpen = kitchenAsync.value!.isOpen;
      _kitchenInitialized = true;
    }

    return Scaffold(
      backgroundColor: AppTheme.chefBackground,
      body: Stack(
        children: [
          // Background Glow Effect
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.chefPrimary.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(user),
                  const SizedBox(height: 24),
                  _buildLogo(),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildBentoGrid(),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildActiveOrders(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation is now handled by ChefMainScreen
        ],
      ),
    );
  }

  Widget _buildHeader(AppUser? user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
            GestureDetector(
              onTap: () async {
                try {
                  await ref.read(authProvider.notifier).uploadProfileImage();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image updated!')));
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update image: $e')));
                  }
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.chefPrimary.withValues(alpha: 0.2), width: 2),
                  image: DecorationImage(
                    image: NetworkImage(user?.avatarUrl ?? 'https://ui-avatars.com/api/?name=${user?.fullName ?? "Chef"}&background=ff3366&color=fff'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.chefTextSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    user?.fullName ?? 'Chef',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.chefPrimary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.chefSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Text(
                      _isKitchenOpen ? 'Kitchen Open' : 'Closed',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _isKitchenOpen ? AppTheme.chefSecondary : AppTheme.chefTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        final kitchen = ref.read(myKitchenProvider).value;
                        if (kitchen != null) {
                          final newStatus = !_isKitchenOpen;
                          setState(() {
                            _isKitchenOpen = newStatus;
                          });
                          await ref.read(kitchenProvider.notifier).toggleKitchenStatus(kitchen.id, newStatus);
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _isKitchenOpen ? AppTheme.chefSecondary.withValues(alpha: 0.2) : AppTheme.chefSurfaceVariant,
                        ),
                        child: AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          alignment: _isKitchenOpen ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isKitchenOpen ? AppTheme.chefSecondary : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.chefSurfaceVariant.withValues(alpha: 0.4),
                ),
                child: const Icon(Icons.notifications_outlined, color: AppTheme.chefTextPrimary, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/images/gochef_logo.png',
        height: 48,
        fit: BoxFit.contain,
        color: AppTheme.chefTextPrimary, // Optional, since logo is white/gray maybe
      ),
    );
  }

  Widget _buildBentoGrid() {
    return Column(
      children: [
        // Earnings Card
        GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL EARNINGS TODAY',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.chefTextSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$1,248.50',
                        style: GoogleFonts.montserrat(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.chefPrimaryContainer,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.chefSecondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, color: AppTheme.chefSecondary, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+12% vs yesterday',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.chefSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Simulated Chart
              SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildChartBar(0.4, AppTheme.chefPrimary.withValues(alpha: 0.2)),
                    const SizedBox(width: 4),
                    _buildChartBar(0.55, AppTheme.chefPrimary.withValues(alpha: 0.2)),
                    const SizedBox(width: 4),
                    _buildChartBar(0.45, AppTheme.chefPrimary.withValues(alpha: 0.2)),
                    const SizedBox(width: 4),
                    _buildChartBar(0.7, AppTheme.chefPrimary.withValues(alpha: 0.2)),
                    const SizedBox(width: 4),
                    _buildChartBar(0.6, AppTheme.chefPrimary.withValues(alpha: 0.2)),
                    const SizedBox(width: 4),
                    _buildChartBar(0.85, AppTheme.chefPrimary.withValues(alpha: 0.2)),
                    const SizedBox(width: 4),
                    _buildChartBar(1.0, AppTheme.chefPrimaryContainer),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Stats Row
        Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Orders Today',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.chefTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '42',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.chefTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Pending',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.chefTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '5',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.chefTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kitchen Rating',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.chefTextSecondary,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.star, color: AppTheme.chefSecondary, size: 20),
              const SizedBox(width: 4),
              Text(
                '4.9',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.chefTextPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(240 reviews)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.chefTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartBar(double heightFactor, Color color) {
    return Expanded(
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveOrders() {
    final ordersAsync = ref.watch(activeOrdersStreamProvider);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Active Orders',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.chefTextPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppTheme.chefPrimaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    ordersAsync.value?.length.toString() ?? '0',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'View History',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.chefPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No active orders yet.',
                    style: TextStyle(color: AppTheme.chefTextSecondary.withOpacity(0.7)),
                  ),
                ),
              );
            }
            return Column(
              children: orders.map((order) {
                // Get the first item image or a placeholder
                String imageUrl = 'https://via.placeholder.com/150';
                String title = 'Order #${order.id.substring(0, 5)}';
                if (order.items.isNotEmpty && order.items.first.menuItem != null) {
                  imageUrl = order.items.first.menuItem!.imageUrl ?? imageUrl;
                  title = '${order.items.first.quantity}x ${order.items.first.menuItem!.name}';
                  if (order.items.length > 1) {
                    title += ' & ${order.items.length - 1} more';
                  }
                }

                // formatting time
                final diff = DateTime.now().difference(order.createdAt);
                String timeAgo = diff.inMinutes < 60 ? '${diff.inMinutes} mins ago' : '${diff.inHours} hours ago';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildOrderCard(
                    imageUrl: imageUrl,
                    title: title,
                    subtitle: 'Order #${order.id.substring(0, 5)} • $timeAgo',
                    status: order.status.toUpperCase(),
                    statusIcon: Icons.restaurant_menu,
                    statusColor: order.status == 'pending' ? AppTheme.chefTertiary : AppTheme.chefSecondary,
                    customerName: order.foodie?.fullName ?? 'Customer',
                    distance: 'Delivery',
                    primaryAction: order.status == 'pending' ? 'Accept' : 'Update Status',
                    secondaryAction: 'Chat',
                    onPrimaryAction: () {
                      if (order.status == 'pending') {
                         ref.read(orderProvider.notifier).updateOrderStatus(order.id, 'preparing');
                      } else if (order.status == 'preparing') {
                         ref.read(orderProvider.notifier).updateOrderStatus(order.id, 'ready');
                      } else if (order.status == 'ready') {
                         ref.read(orderProvider.notifier).updateOrderStatus(order.id, 'delivering');
                      } else if (order.status == 'delivering') {
                         ref.read(orderProvider.notifier).updateOrderStatus(order.id, 'completed');
                      }
                    }
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.chefPrimary)),
          error: (e, st) => Center(child: Text('Error loading orders: $e')),
        ),
      ],
    );
  }

  Widget _buildOrderCard({
    required String imageUrl,
    required String title,
    required String subtitle,
    required String status,
    required IconData statusIcon,
    required Color statusColor,
    required String customerName,
    required String distance,
    required String primaryAction,
    required String secondaryAction,
    VoidCallback? onPrimaryAction,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
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
                        Expanded(
                          child: Text(
                            title,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.chefTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.chefTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(statusIcon, color: statusColor, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                status,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor.withValues(alpha: 0.2),
                            border: Border.all(color: AppTheme.chefSurface, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              customerName.substring(0, 1),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Customer: $customerName • $distance',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.chefTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimaryAction ?? () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.chefPrimaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    primaryAction,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.chefTextPrimary,
                    side: BorderSide(color: AppTheme.chefTextSecondary.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    secondaryAction,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
