import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui' as ui;
import 'package:uuid/uuid.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/menu_provider.dart';
import '../../providers/kitchen_provider.dart';
import '../../widgets/premium/glass_card.dart';
import '../../widgets/chef_bottom_nav.dart';

class MenuManagementScreen extends ConsumerStatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  ConsumerState<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen> {
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
              onPressed: () {
                _showAddMenuDialog(context, ref);
              },
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
    final menuAsync = ref.watch(menuProvider);
    final myKitchenAsync = ref.watch(myKitchenProvider);

    return myKitchenAsync.when(
      data: (myKitchen) {
        if (myKitchen == null) return const Center(child: Text('Kitchen not found', style: TextStyle(color: Colors.white)));
        
        return menuAsync.when(
          data: (allItems) {
            final items = allItems.where((i) => i.kitchenId == myKitchen.id).toList();
            if (items.isEmpty) {
              return const Center(child: Text('No menu items yet. Add one!', style: TextStyle(color: Colors.white54)));
            }
            return Column(
              children: items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: _buildDishCard(
                  id: item.id,
                  imageUrl: item.imageUrl ?? 'https://via.placeholder.com/150',
                  title: item.name,
                  desc: item.description ?? '',
                  price: '\$${item.price.toStringAsFixed(2)}',
                  isChefPick: false,
                  isAvailable: item.isAvailable,
                ),
              )).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
    );
  }

  Widget _buildDishCard({
    required String id,
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
                          onPressed: () {
                            ref.read(menuProvider.notifier).toggleAvailability(id);
                          },
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

  void _showAddMenuDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.chefSurface,
          title: const Text('Add Menu Item', style: TextStyle(color: AppTheme.chefTextPrimary)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Dish Name', labelStyle: TextStyle(color: Colors.white70)),
                ),
                TextField(
                  controller: descController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.white70)),
                ),
                TextField(
                  controller: priceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price', labelStyle: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.chefPrimary),
              onPressed: () async {
                final myKitchen = await ref.read(myKitchenProvider.future);
                if (myKitchen != null) {
                  final newItem = MenuItem(
                    id: const Uuid().v4(),
                    kitchenId: myKitchen.id,
                    name: nameController.text,
                    description: descController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
                  );
                  ref.read(menuProvider.notifier).addMenuItem(newItem);
                }
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
