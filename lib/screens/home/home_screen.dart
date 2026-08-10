import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../kitchen/kitchen_profile_screen.dart';
import '../food/food_details_screen.dart';
import '../search/search_results_screen.dart';
import '../cart/cart_screen.dart';
import '../../services/api_service.dart';
import '../../models/kitchen_model.dart';
import '../../models/menu_item_model.dart';
import '../../models/category_model.dart';
import '../../models/promotion_model.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_app_bar_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _homeDataFuture;
  late Future<UserModel> _profileFuture;
  late Future<List<dynamic>> _cartFuture;
  int _selectedCategoryId = 1;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = ApiService.getHomeData();
    _profileFuture = ApiService.getProfile();
    _cartFuture = ApiService.getCart();
  }

  Future<void> _refreshData() async {
    setState(() {
      _homeDataFuture = ApiService.getHomeData();
      _profileFuture = ApiService.getProfile();
      _cartFuture = ApiService.getCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          child: FutureBuilder<Map<String, dynamic>>(
            future: _homeDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text('Failed to load data', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _refreshData,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: Text('Retry', style: AppTextStyles.labelSm(color: AppColors.onPrimary)),
                      )
                    ],
                  ),
                );
              }

              final data = snapshot.data ?? {};
              final List<KitchenModel> featuredKitchens = data['featured_kitchens'] ?? [];
              final List<MenuItemModel> allPopularMeals = data['popular_meals'] ?? [];
              final List<CategoryModel> categories = data['categories'] ?? [];
              final List<PromotionModel> promotions = data['promotions'] ?? [];

              final List<MenuItemModel> popularMeals = _selectedCategoryId == 1 
                  ? allPopularMeals 
                  : allPopularMeals.where((m) => m.categoryId == _selectedCategoryId).toList();

              return CustomScrollView(
                slivers: [
                  // ─── App Bar ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(child: CustomAppBarTitle()),
                          Row(
                            children: [
                              FutureBuilder<List<dynamic>>(
                                future: _cartFuture,
                                builder: (context, snapshot) {
                                  int cartCount = 0;
                                  if (snapshot.hasData && snapshot.data != null) {
                                    cartCount = snapshot.data!.length;
                                  }
                                  return Stack(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.shopping_cart, color: AppColors.primary),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                                        },
                                      ),
                                      if (cartCount > 0)
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: AppColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Text(
                                              '$cartCount',
                                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.notifications_none, color: AppColors.onSurfaceVariant),
                                onPressed: () {},
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  // ─── Search Bar ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => SearchResultsScreen(initialQuery: value)),
                                    );
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search student chefs or meals...',
                                  hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ─── Categories ───
                  if (categories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            children: categories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: _buildCategoryChip(
                                  category.name,
                                  isSelected: category.id == _selectedCategoryId,
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryId = category.id;
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                  // ─── Promotions Carousel ───
                  if (promotions.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        child: Container(
                          height: 192,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(promotions.first.image),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.surface,
                                  AppColors.surface.withValues(alpha: 0.4),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'LIMITED OFFER',
                                    style: AppTextStyles.labelSm(color: AppColors.onPrimaryContainer)
                                        .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  promotions.first.title,
                                  style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)
                                      .copyWith(fontSize: 24),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  promotions.first.subtitle,
                                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // ─── Featured Kitchens ───
                  if (featuredKitchens.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Featured Kitchens', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                                Text('View All', style: AppTextStyles.labelSm(color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: featuredKitchens.map((k) {
                                  return _buildFeaturedKitchen(
                                    context: context,
                                    kitchen: k,
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ─── Popular Meals ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0, left: 20.0, right: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Popular Meals', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                          const SizedBox(height: 16),
                          if (popularMeals.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  'No meals found in this category.',
                                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                ),
                              ),
                            )
                          else
                            ...popularMeals.map((m) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: _buildPopularMeal(
                                    context: context,
                                    meal: m,
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMono(
              color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildFeaturedKitchen({
    required BuildContext context,
    required KitchenModel kitchen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => KitchenProfileScreen(kitchenId: kitchen.id)),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Container(
              height: 224,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(kitchen.coverImage.isNotEmpty ? kitchen.coverImage : kitchen.avatar),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.primary, size: 16),
                          const SizedBox(width: 4),
                          Text(kitchen.rating.toStringAsFixed(1), style: AppTextStyles.labelSm(color: AppColors.onSurface)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kitchen.name, style: AppTextStyles.headlineMd(color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(kitchen.cuisineType, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text('VERIFIED',
                        style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontSize: 10)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPopularMeal({
    required BuildContext context,
    required MenuItemModel meal,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FoodDetailsScreen(menuItemId: meal.id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(meal.image),
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
                      Expanded(
                        child: Text(meal.name,
                            style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text('\$${meal.price.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(meal.kitchenName, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(meal.prepTime, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          final success = await ApiService.addToCart(meal.id);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart'), backgroundColor: AppColors.primary),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Add to Cart',
                              style: AppTextStyles.labelSm(color: AppColors.onPrimaryContainer)
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
