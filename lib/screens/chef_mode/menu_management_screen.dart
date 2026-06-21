import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/chef_bottom_nav.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  int _currentIndex = 1; // Kitchen/Menu is index 1 in our bottom nav
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All Items', 'Mains', 'Sides', 'Desserts'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.chefBackground,
      body: Stack(
        children: [
          // Background Glow Effect
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.chefSecondary.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildStatsGrid(),
                        ),
                        const SizedBox(height: 32),
                        _buildFilters(),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildMenuGrid(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation is now handled by ChefMainScreen
          
          // FAB
          Positioned(
            bottom: 100,
            right: 24,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppTheme.chefPrimaryContainer,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.chefPrimary.withValues(alpha: 0.2), width: 2),
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCv-ZOofXJcMAshQ6syetVmJwPNFfZKCUTEIcpq99P6WorcDLLq1lP_CfcthcYZUuMhQZ5wrJ_spy21I7V3i0eY3Pvp73_7zfBKon_LoLB7reN6pAdqYKHiiWHQyFCMp-YRMWf6Q3P1fJghh_XrdH-E1dp0dSF8EG-Z48TTn7fF9K7_hDo2aqV7yHq3ZOlb2rKt8jW6-yf5DlymFdjwfphs8zqASWq2Ked5T0UIKG7s9WZvpWiKcCPhsXeZz0n_KKIVNBwgIQyNlf39'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'GoChef',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.chefPrimaryContainer,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppTheme.chefTextPrimary),
          onPressed: () {},
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.chefSecondary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppTheme.chefSecondary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Kitchen Verified',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.chefSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.chefTertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.chefTertiary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Open for Dinner',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.chefTertiary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Kitchen Menu Management',
            style: GoogleFonts.montserrat(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.chefTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Refine your tonight\'s offerings, set availability, and curate your signature chef\'s picks.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.chefTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Active Dishes', '12', AppTheme.chefPrimary)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Chef\'s Picks', '03', AppTheme.chefSecondary)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Sold Out Today', '02', Colors.redAccent)),
            const SizedBox(width: 12),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Revenue Est.',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.chefPrimaryContainer),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$1,240',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.chefPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color valueColor) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.chefTextSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCategoryIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategoryIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.chefSurfaceVariant : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _categories[index],
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? AppTheme.chefTextPrimary : AppTheme.chefTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.chefSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              style: const TextStyle(color: AppTheme.chefTextPrimary),
              decoration: InputDecoration(
                hintText: 'Search menu...',
                hintStyle: TextStyle(color: AppTheme.chefTextSecondary.withValues(alpha: 0.5)),
                icon: Icon(Icons.search, color: AppTheme.chefTextSecondary),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid() {
    return Column(
      children: [
        _buildDishCard(
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAH1g1tuVqF0wK1YoAmwrTf5igYIh5-6VPkZjMCbC7tUZ23pucVrYdzLklHpfpPlrjdGVfb836B7iHoucPk2b5RXUQ4Rp6Ek5avNDZtDbiapswLz5QDQ2oUiw-TTBNdagerpMVh0ymeeq00jH4oF8vgnloHFBgG9xtDksmBsW57l5cIQSvd4D3L0BGwmT6ugnTRiWjCZnl5jJic7QKOUlF-4iE2-fEUhGOXgrKeCQoGlZfgc_gYBgNjQSUep3iq-I-4gZVJ9FA5hbiz',
          title: 'Truffle Wagyu Burger',
          desc: 'Caramelized onions, truffle aioli, aged gruyère.',
          price: '\$24.00',
          isChefPick: true,
          isAvailable: true,
        ),
        const SizedBox(height: 24),
        _buildDishCard(
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDlJ3T0V2E5h8NtW919fQOpPWq_q16b8decEHpQxPe-E3Ou7HKg_Kpmjb26ZN5m32xzJVmDnHgJBYCCWgfgVGPlkFRAG40efCsCSKgX56RZclE0b6KwdRANnpmRYpA_65ezOB8tuJoeedGpcRnFWfEVCDTHiGJHw4w3xI69f6hwFUuiWipceS1Vz41NzC1QlTT9CxELeow0XKOfO_UnEmjpXJTg3u_K8uLyhyay_JZKlPIKwTUVmZfR6Z0laU4w2q37j-ad6HmT5iq6',
          title: 'Hokkaido Sea Scallops',
          desc: 'Pea purée, crispy pancetta, lemon oil.',
          price: '\$32.00',
          isChefPick: false,
          isAvailable: false,
        ),
        const SizedBox(height: 24),
        _buildDishCard(
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAReaAN3d-dWoMtaD1TYegh24DfCuIbGhnL7aSwVlpmJ6gQk7zCffBxXwLzJHv-N8uhMPpk5LHZRr5HVomopa4sUyioZ8CNkttxJJtFrB2dAtruA3P3AiuHsipG90wzRPOb8v5LTml_qz3ujW1uyj7kbweOS49W_1fFjN001-Co7yS_XFhgWaSZzBA5YA9SWOA5c19GXI3g-29lCT2g3Qc_0ELk-5JKvxgaF3O3RucJ2Zl4Nh5m5xY80TaieD0bEtrwDvQdy0f_3GoN',
          title: 'Gold Leaf Lava Cake',
          desc: '70% Dark cocoa, raspberry infusion.',
          price: '\$18.00',
          isChefPick: false,
          isAvailable: true,
        ),
      ],
    );
  }

  Widget _buildDishCard({
    required String imageUrl,
    required String title,
    required String desc,
    required String price,
    required bool isChefPick,
    required bool isAvailable,
  }) {
    return Opacity(
      opacity: isAvailable ? 1.0 : 0.6,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Image
            Stack(
              children: [
                ColorFiltered(
                  colorFilter: isAvailable 
                    ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                    : const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      image: DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (!isAvailable)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Transform.rotate(
                          angle: -0.1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'SOLD OUT',
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (isChefPick)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.chefTertiary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Chef\'s Pick',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            // Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.chefTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              desc,
                              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.chefTextSecondary),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        price,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.chefPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Availability Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Today',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.chefTextPrimary),
                      ),
                      Switch(
                        value: isAvailable,
                        onChanged: (val) {},
                        activeColor: AppTheme.chefPrimaryContainer,
                        activeTrackColor: AppTheme.chefPrimary.withValues(alpha: 0.3),
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: AppTheme.chefSurfaceVariant,
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 32),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.chefTextPrimary,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: Icon(
                            isAvailable ? Icons.block : Icons.check_circle, 
                            size: 18,
                            color: isAvailable ? Colors.redAccent : AppTheme.chefSecondary,
                          ),
                          label: Text(
                            isAvailable ? 'Mark Sold Out' : 'Re-stock',
                            style: TextStyle(
                              color: isAvailable ? Colors.redAccent : AppTheme.chefSecondary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isAvailable ? Colors.redAccent : AppTheme.chefSecondary,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: isAvailable ? Colors.transparent : AppTheme.chefSecondary.withValues(alpha: 0.1),
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
      ),
    );
  }
}
