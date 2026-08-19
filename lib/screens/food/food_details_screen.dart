import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/menu_item_model.dart';
import '../../models/menu_addon_model.dart';
import '../../models/review_model.dart';
import '../cart/cart_screen.dart';
import '../kitchen/kitchen_profile_screen.dart';
import '../../widgets/cart_icon_button.dart';

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
  bool _isFavorite = false;
  late Future<MenuItemModel?> _menuItemFuture;
  
  // Track selected addons
  final Set<int> _selectedAddonIds = {};
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _menuItemFuture = ApiService.getMenuDetail(widget.menuItemId);
    ApiService.getFavorites(type: 'dish').then((favs) {
      if (mounted) {
        setState(() {
          _isFavorite = favs.any((f) => f['id'] == widget.menuItemId);
        });
      }
    });
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
    _notesController.dispose();
    super.dispose();
  }

  void _toggleAddon(MenuAddonCategoryModel category, MenuAddonModel addon) {
    setState(() {
      if (category.isMultiple) {
        if (_selectedAddonIds.contains(addon.id)) {
          _selectedAddonIds.remove(addon.id);
        } else {
          _selectedAddonIds.add(addon.id);
        }
      } else {
        // Single selection
        if (_selectedAddonIds.contains(addon.id)) {
          // If they click the already selected radio, maybe we allow deselecting if it's not required?
          // Actually, standard behavior for radio is once selected, can't deselect unless picking another.
          if (!category.isRequired) {
            _selectedAddonIds.remove(addon.id);
          }
        } else {
          for (var opt in category.options) {
            _selectedAddonIds.remove(opt.id);
          }
          _selectedAddonIds.add(addon.id);
        }
      }
    });
  }

  void _toggleFavorite(MenuItemModel item) async {
    setState(() => _isFavorite = !_isFavorite);
    final success = await ApiService.addFavorite(menuItemId: item.id, type: 'dish');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'), backgroundColor: AppColors.primary),
      );
    } else if (!success && mounted) {
      setState(() => _isFavorite = !_isFavorite);
    }
  }

  void _addToCart(MenuItemModel item) async {
    if (item.addonCategories != null) {
      for (var category in item.addonCategories!) {
        if (category.isRequired) {
          bool hasSelection = category.options.any((opt) => _selectedAddonIds.contains(opt.id));
          if (!hasSelection) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please select an option for ${category.name}'), backgroundColor: AppColors.error),
            );
            return;
          }
        }
      }
    }

    final success = await ApiService.addToCart(
      item.id,
      quantity: _quantity,
      addonIds: _selectedAddonIds.toList(),
      notes: _notesController.text.trim(),
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
          if (item.addonCategories != null) {
            for (var category in item.addonCategories!) {
              for (var addon in category.options) {
                if (_selectedAddonIds.contains(addon.id)) {
                  totalPrice += addon.price;
                }
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
                                        '${item.name} (${item.calories} calories)',
                                        style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)
                                            .copyWith(height: 1.1),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${item.price.toStringAsFixed(2)}',
                                        style: AppTextStyles.headlineMd(color: Colors.white)
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
                                          const Text('View Kitchen Profile', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
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
                                  _buildUtilityItem(Icons.local_fire_department, '${item.calories} kcal'),
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
                              style: AppTextStyles.bodyMd(color: Colors.white).copyWith(height: 1.5),
                            ),
                            const SizedBox(height: 32),

                            // Add-ons
                            if (item.addonCategories != null && item.addonCategories!.isNotEmpty) ...[
                              Text('Personalize Your Dish', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                              const SizedBox(height: 16),
                              ...item.addonCategories!.map((category) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          category.name,
                                          style: AppTextStyles.bodyLg(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        if (category.isRequired)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('Required', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                          )
                                        else
                                          const Text('Optional', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ...category.options.map((addon) {
                                      final isSelected = _selectedAddonIds.contains(addon.id);
                                      return _buildPersonalizeOption(
                                        addon.name,
                                        '+\$${addon.price.toStringAsFixed(2)}',
                                        isSelected: isSelected,
                                        isMultiple: category.isMultiple,
                                        onTap: () {
                                          setState(() {
                                            if (isSelected) {
                                              _selectedAddonIds.remove(addon.id);
                                            } else {
                                              if (!category.isMultiple) {
                                                // Remove other selections from this category
                                                for (var opt in category.options) {
                                                  _selectedAddonIds.remove(opt.id);
                                                }
                                              }
                                              _selectedAddonIds.add(addon.id);
                                            }
                                          });
                                        },
                                      );
                                    }),
                                    const SizedBox(height: 24),
                                  ],
                                );
                              }),
                            ],
                            
                            // Notes
                            Text('Special Instructions', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _notesController,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal),
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'e.g. no onions, extra spicy, etc.',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                                filled: true,
                                fillColor: AppColors.surfaceContainerLow,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                            const SizedBox(height: 32),
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
                                    child: Icon(
                                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: _isFavorite ? AppColors.primary : AppColors.onSurface,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              const CartIconButton(iconColor: AppColors.onSurface),
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
                              onTap: () {
                                  bool canAddToCart = true;
                                  if (item.addonCategories != null) {
                                    for (var cat in item.addonCategories!) {
                                      if (cat.isRequired) {
                                        bool hasSelection = cat.options.any((opt) => _selectedAddonIds.contains(opt.id));
                                        if (!hasSelection) {
                                          canAddToCart = false;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Please select an option for ${cat.name}')),
                                          );
                                          break;
                                        }
                                      }
                                    }
                                  }

                                  if (canAddToCart) {
                                    _addToCart(item);
                                  }
                              },
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
                                    const Icon(Icons.shopping_cart, color: AppColors.onPrimary),
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

  Widget _buildPersonalizeOption(String title, String price, {required bool isSelected, bool isMultiple = true, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isMultiple
                      ? (isSelected ? Icons.check_box : Icons.check_box_outline_blank)
                      : (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked),
                  color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
              ],
            ),
            Text(price, style: AppTextStyles.labelMono(color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
