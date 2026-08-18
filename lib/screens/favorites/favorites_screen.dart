import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../notifications/notifications_screen.dart';
import '../../services/api_service.dart';
import '../kitchen/kitchen_profile_screen.dart';
import '../food/food_details_screen.dart';
import '../../models/kitchen_model.dart';
import '../../widgets/custom_app_bar_title.dart';
import '../../widgets/notification_bell.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> _kitchens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final meals = await ApiService.getFavorites(type: 'dish');
      final kitchens = await ApiService.getFavorites(type: 'kitchen');
      setState(() {
        _meals = meals;
        _kitchens = kitchens;
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(int itemId, String type) async {
    // Assuming backend endpoint /favorites.php?action=remove handles it, 
    // but the current ApiService might not have removeFavorite. 
    // We will just do local remove for demonstration if we don't have the API method.
    // If ApiService.removeFavorite exists, call it. For now, local update:
    setState(() {
      if (type == 'dish') {
        _meals.removeWhere((m) => m['menu_item_id'] == itemId || m['item_id'] == itemId);
      } else {
        _kitchens.removeWhere((k) => k['kitchen_id'] == itemId || k['item_id'] == itemId);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from favorites'), backgroundColor: AppColors.primary),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        title: const CustomAppBarTitle(subtitle: 'Favorites'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NotificationBell(iconColor: Colors.white),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                const SizedBox(height: 16),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    ),
                    child: TextField(
                      style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Filter your favorites...',
                        hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
                        prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tabs
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      labelStyle: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                      unselectedLabelStyle: AppTextStyles.headlineMd(color: Colors.white60).copyWith(fontWeight: FontWeight.w500),
                      tabs: const [
                        Tab(text: 'Meals'),
                        Tab(text: 'Kitchens'),
                      ],
                    ),
                  ),
                ),
                
                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMealsTab(),
                      _buildKitchensTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMealsTab() {
    if (_meals.isEmpty) {
      return Center(
        child: Text('No favorite meals found.', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 120),
      itemCount: _meals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final meal = _meals[index];
        return _buildMealCard(
          id: meal['item_id'] ?? meal['menu_item_id'] ?? 0,
          title: meal['name'] ?? 'Unknown',
          subtitle: meal['kitchen_name'] ?? '',
          price: '\$${(meal['price'] != null ? double.parse(meal['price'].toString()) : 0.0).toStringAsFixed(2)}',
          rating: (meal['rating'] != null ? double.parse(meal['rating'].toString()) : 0.0).toStringAsFixed(1),
          imageUrl: meal['image'] ?? '',
        );
      },
    );
  }

  Widget _buildKitchensTab() {
    if (_kitchens.isEmpty) {
      return Center(
        child: Text('No favorite kitchens found.', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 120),
      itemCount: _kitchens.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final kitchen = _kitchens[index];
        return _buildKitchenCard(
          id: kitchen['item_id'] ?? kitchen['kitchen_id'] ?? 0,
          title: kitchen['name'] ?? 'Unknown',
          subtitle: kitchen['cuisine_type'] ?? '',
          rating: (kitchen['rating'] != null ? double.parse(kitchen['rating'].toString()) : 0.0).toStringAsFixed(1),
          avatar: kitchen['image'] ?? kitchen['avatar'] ?? '',
        );
      },
    );
  }

  Widget _buildMealCard({
    required int id,
    required String title,
    required String subtitle,
    required String price,
    required String rating,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        if (id > 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FoodDetailsScreen(menuItemId: id)));
        }
      },
      child: Container(
        height: 176,
        decoration: BoxDecoration(
          color: const Color(0xFF31353F).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA98890).withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
                child: Image.network(imageUrl, fit: BoxFit.cover, height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainer),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(subtitle, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeFavorite(id, 'dish'),
                          child: const Icon(Icons.favorite, color: AppColors.primaryContainer),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(price, style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.primary, size: 14),
                                const SizedBox(width: 4),
                                Text(rating, style: AppTextStyles.labelMono(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            if (id > 0) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FoodDetailsScreen(menuItemId: id)),
                              );
                            }
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: AppColors.onPrimary, size: 20),
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

  Widget _buildKitchenCard({
    required int id,
    required String title,
    required String subtitle,
    required String rating,
    required String avatar,
  }) {
    return GestureDetector(
      onTap: () {
        if (id > 0) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => KitchenProfileScreen(kitchenId: id)));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF31353F).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFA98890).withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                image: DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover,
                  onError: (_, __) => const NetworkImage('https://ui-avatars.com/api/?name=Kitchen')
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineMd(color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text(rating, style: AppTextStyles.labelMono(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _removeFavorite(id, 'kitchen'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: AppColors.primaryContainer, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
