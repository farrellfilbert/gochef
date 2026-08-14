import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../kitchen/kitchen_profile_screen.dart';
import '../food/food_details_screen.dart';
import '../search/search_results_screen.dart';
import '../search/search_modal.dart';
import '../cart/cart_screen.dart';
import '../../services/api_service.dart';
import '../../models/kitchen_model.dart';
import '../../models/menu_item_model.dart';
import '../../models/category_model.dart';
import '../../models/promotion_model.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_app_bar_title.dart';
import '../../widgets/notification_bell.dart';

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
  double? _maxPriceFilter;
  double _dummyDistance = 5.0; // km

  void _showFilterModal(BuildContext context) {
    double currentMaxPrice = _maxPriceFilter ?? 50.0;
    double currentDistance = _dummyDistance;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Max Price', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                      Text('\$${currentMaxPrice.toStringAsFixed(0)}', style: AppTextStyles.bodyMd(color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: currentMaxPrice,
                    min: 5.0,
                    max: 100.0,
                    divisions: 19,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.outlineVariant.withValues(alpha: 0.3),
                    onChanged: (value) {
                      setModalState(() {
                        currentMaxPrice = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Distance (km)', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                      Text('${currentDistance.toStringAsFixed(1)} km', style: AppTextStyles.bodyMd(color: AppColors.primary)),
                    ],
                  ),
                  Slider(
                    value: currentDistance,
                    min: 1.0,
                    max: 20.0,
                    divisions: 19,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.outlineVariant.withValues(alpha: 0.3),
                    onChanged: (value) {
                      setModalState(() {
                        currentDistance = value;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _maxPriceFilter = currentMaxPrice;
                          _dummyDistance = currentDistance;
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Apply Filters', style: AppTextStyles.labelSm(color: AppColors.onPrimary)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
    await Future.wait([_homeDataFuture, _profileFuture, _cartFuture]);
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

              final List<MenuItemModel> popularMeals = allPopularMeals.where((m) {
                if (_selectedCategoryId != 1 && m.categoryId != _selectedCategoryId) return false;
                if (_maxPriceFilter != null && m.price > _maxPriceFilter!) return false;
                return true;
              }).toList();

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
                                        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
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
                              const NotificationBell(iconColor: Colors.white),
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
                                readOnly: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SearchModal(),
                                      fullscreenDialog: true,
                                    ),
                                  );
                                },
                                style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                                decoration: InputDecoration(
                                  hintText: 'Search Chefs, Kitchens or Meals…',
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
                                    style: AppTextStyles.labelSm(color: Colors.white)
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
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const SearchResultsScreen(initialQuery: ''),
                                      ),
                                    );
                                  },
                                  child: Text('View All', style: AppTextStyles.labelSm(color: Colors.white)),
                                ),
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
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Popular Meals', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                                IconButton(
                                  icon: const Icon(Icons.tune, color: Colors.white),
                                  onPressed: () => _showFilterModal(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (categories.isNotEmpty)
                            SingleChildScrollView(
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
                          const SizedBox(height: 16),
                          if (popularMeals.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  'No meals found matching your filters.',
                                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                ),
                              ),
                            )
                          else
                            ...popularMeals.map((m) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0, left: 20.0, right: 20.0),
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
          color: isSelected ? AppColors.primaryContainer : AppColors.surface.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.outlineVariant.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMono(
              color: isSelected ? Colors.white : Colors.white70),
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
                          style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FoodDetailsScreen(menuItemId: meal.id)),
                          );
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
