import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/menu_item_model.dart';
import '../../models/review_model.dart';
import '../cart/cart_screen.dart';

class FoodDetailsScreen extends StatefulWidget {
  final int menuItemId;

  const FoodDetailsScreen({super.key, required this.menuItemId});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  int _quantity = 1;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  late Future<MenuItemModel?> _menuItemFuture;
  
  // Track selected addons
  final Set<int> _selectedAddonIds = {};

  @override
  void initState() {
    super.initState();
    _menuItemFuture = ApiService.getMenuDetail(widget.menuItemId);
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFavorite(MenuItemModel item) async {
    final success = await ApiService.addFavorite(menuItemId: item.id, type: 'dish');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to favorites'), backgroundColor: AppColors.primary),
      );
    }
  }

  void _addToCart(MenuItemModel item) async {
    final success = await ApiService.addToCart(
      item.id,
      quantity: _quantity,
      addonIds: _selectedAddonIds.toList(),
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart'), backgroundColor: AppColors.primary),
      );
      Navigator.pop(context); // Go back after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: FutureBuilder<MenuItemModel?>(
        future: _menuItemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text('Failed to load item', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text('Go Back', style: AppTextStyles.labelSm(color: AppColors.onPrimary)),
                  )
                ],
              ),
            );
          }

          final item = snapshot.data!;
          
          // Calculate total price including addons
          double totalPrice = item.price;
          if (item.addons != null) {
            for (var addon in item.addons!) {
              if (_selectedAddonIds.contains(addon.id)) {
                totalPrice += addon.price;
              }
            }
          }
          totalPrice *= _quantity;

          return Stack(
            children: [
              // ─── Main Content ───
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 120), // For bottom action bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            item.image,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(color: AppColors.surfaceContainer),
                          ),
                          // Gradient overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    AppColors.midnight.withValues(alpha: 0.5),
                                    AppColors.midnight,
                                  ],
                                  stops: const [0.5, 0.8, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content Body (shifted up slightly to overlap gradient)
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title & Quick Stats
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)
                                            .copyWith(height: 1.1),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: AppTextStyles.headlineMd(color: AppColors.primary)
                                            .copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.glassBackground,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.star, color: AppColors.primary, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.rating.toStringAsFixed(1),
                                        style: AppTextStyles.labelMono(color: AppColors.onSurface),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Kitchen Info
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => KitchenProfileScreen(kitchenId: item.kitchenId)),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(item.kitchenAvatar),
                                      radius: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(item.kitchenName, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                                          Text('View Kitchen Profile', style: AppTextStyles.labelSm(color: AppColors.primary)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Utility Bar
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.glassBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: Row(
                                children: [
                                  _buildUtilityItem(Icons.schedule, item.prepTime),
                                  _buildVerticalDivider(),
                                  _buildUtilityItem(Icons.local_fire_department, 'Estimated'),
                                  _buildVerticalDivider(),
                                  _buildUtilityItem(Icons.restaurant, item.categoryName),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Description
                            Text('Description', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(height: 1.5),
                            ),
                            const SizedBox(height: 32),

                            // Add-ons
                            if (item.addons != null && item.addons!.isNotEmpty) ...[
                              Text('Personalize Your Dish', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                              const SizedBox(height: 12),
                              ...item.addons!.map((addon) {
                                final isSelected = _selectedAddonIds.contains(addon.id);
                                return _buildPersonalizeOption(
                                  addon.name,
                                  '+\$${addon.price.toStringAsFixed(2)}',
                                  isSelected: isSelected,
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedAddonIds.remove(addon.id);
                                      } else {
                                        _selectedAddonIds.add(addon.id);
                                      }
                                    });
                                  },
                                );
                              }),
                              const SizedBox(height: 32),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Top Navigation ───
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: _isScrolled ? 10 : 0, sigmaY: _isScrolled ? 10 : 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: kToolbarHeight + MediaQuery.of(context).padding.top,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                        left: 20,
                        right: 20,
                      ),
                      decoration: BoxDecoration(
                        color: _isScrolled
                            ? AppColors.surface.withValues(alpha: 0.8)
                            : Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _toggleFavorite(item),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.favorite_border, color: AppColors.onSurface),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CartScreen()),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.shopping_bag_outlined, color: AppColors.onSurface),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Bottom Action Bar ───
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 16,
                        bottom: MediaQuery.of(context).padding.bottom + 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.8),
                        border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2))),
                      ),
                      child: Row(
                        children: [
                          // Quantity Selector
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: AppColors.onSurface),
                                  onPressed: () {
                                    if (_quantity > 1) {
                                      setState(() => _quantity--);
                                    }
                                  },
                                ),
                                Text(
                                  _quantity.toString(),
                                  style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: AppColors.onSurface),
                                  onPressed: () {
                                    setState(() => _quantity++);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Add to Cart Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _addToCart(item),
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shopping_bag, color: AppColors.onPrimary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Add • \$${totalPrice.toStringAsFixed(2)}',
                                      style: AppTextStyles.bodyLg(color: AppColors.onPrimary)
                                          .copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUtilityItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.outlineVariant.withValues(alpha: 0.2),
    );
  }

  Widget _buildPersonalizeOption(String title, String price, {bool isSelected = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.2) : AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
              ],
            ),
            Text(price, style: AppTextStyles.labelSm(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
