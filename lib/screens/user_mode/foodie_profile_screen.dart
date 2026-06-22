import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/premium/bouncing_tap.dart';
import 'foodie_order_history_screen.dart';
import '../saved_addresses_screen.dart';
import '../payment_methods_screen.dart';
import '../account_detail_screen.dart';
import '../loyalty_screen.dart';
import '../help_center_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class FoodieProfileScreen extends ConsumerWidget {
  const FoodieProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(context),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(context, ref, user),
              const SizedBox(height: 24),
              _buildStreakCard(context),
              const SizedBox(height: 24),
              _buildManagementSection(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundDark.withValues(alpha: 0.8),
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: AppTheme.fuchsiaPrimary),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        'GoChef',
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppTheme.fuchsiaPrimary,
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 24),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.3), width: 2),
            image: DecorationImage(
              image: NetworkImage(user?.avatarUrl ?? 'https://ui-avatars.com/api/?name=${user?.fullName ?? "User"}&background=ff3366&color=fff'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surfaceColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      image: DecorationImage(
                        image: NetworkImage(user?.avatarUrl ?? 'https://ui-avatars.com/api/?name=${user?.fullName ?? "User"}&background=ff3366&color=fff'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.fullName ?? 'Foodie', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                        Text('Gold Spatula Member', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text('1,250 pts', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10),
            _buildDrawerItem(context, Icons.settings, 'Account Settings'),
            _buildDrawerItem(context, Icons.location_on, 'Saved Addresses'),
            _buildDrawerItem(context, Icons.payments, 'Payment Methods'),
            _buildDrawerItem(context, Icons.workspace_premium, 'Loyalty Status'),
            const Divider(color: Colors.white10),
            _buildDrawerItem(context, Icons.help, 'Help Center'),
            _buildDrawerItem(context, Icons.logout, 'Sign Out', isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.redAccent : AppTheme.textSecondary),
      title: Text(title, style: GoogleFonts.inter(color: isDestructive ? Colors.redAccent : AppTheme.textSecondary)),
      onTap: () {
        Navigator.pop(context); // Close drawer
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigating to $title')));
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref, dynamic user) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Badges and content
          Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: Colors.greenAccent, size: 14),
                      const SizedBox(width: 4),
                      Text('VERIFIED FOODIE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.fuchsiaPrimary, width: 4),
                      image: DecorationImage(
                        image: NetworkImage(user?.avatarUrl ?? 'https://ui-avatars.com/api/?name=${user?.fullName ?? "User"}&background=ff3366&color=fff'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
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
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.fuchsiaPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.surfaceColor, width: 2),
                        ),
                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(user?.fullName ?? 'Foodie', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.military_tech, color: AppTheme.fuchsiaPrimary, size: 20),
                  const SizedBox(width: 4),
                  Text('GOLD SPATULA MEMBER', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary, letterSpacing: 1.2)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: BouncingTap(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viewing Points Details'))),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          children: [
                            Text('1,250', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                            Text('TOTAL POINTS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: BouncingTap(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viewing Active Orders'))),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          children: [
                            Text('02', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                            Text('ACTIVE ORDERS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context) {
    return BouncingTap(
      onTap: () {
        // Needs a Builder context or just ignore context since we aren't using ScaffoldMessenger here if it's too much.
      },
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.local_fire_department, color: AppTheme.fuchsiaPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('12-Day Streak', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  Text('Spicing things up!', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text('MANAGEMENT', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 2)),
        ),
        _buildActionTile(context, Icons.military_tech, 'Loyalty & Rewards', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoyaltyScreen()));
        }),
        const SizedBox(height: 8),
        _buildActionTile(context, Icons.receipt_long, 'Order History', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodieOrderHistoryScreen(showBackButton: true)));
        }),
        const SizedBox(height: 8),
        _buildActionTile(context, Icons.location_on, 'Saved Addresses', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedAddressesScreen()));
        }),
        const SizedBox(height: 8),
        _buildActionTile(context, Icons.payments, 'Payment Methods', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()));
        }),
        const SizedBox(height: 8),
        _buildActionTile(context, Icons.help, 'Help Center', () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
        }),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Usually we'd pop back to login
              Navigator.of(context, rootNavigator: true).pop();
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2)),
              backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return BouncingTap(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.textSecondary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
