import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../kitchen/kitchen_profile_screen.dart';
import '../food/food_details_screen.dart';
import '../../models/kitchen_model.dart';
import '../../models/menu_item_model.dart';

class SearchResultsScreen extends StatefulWidget {
  final String initialQuery;

  const SearchResultsScreen({super.key, this.initialQuery = ''});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late TextEditingController _searchController;
  bool _isLoading = false;
  List<KitchenModel> _kitchens = [];
  List<MenuItemModel> _dishes = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _performSearch(widget.initialQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    try {
      final results = await ApiService.search(query);
      setState(() {
        _kitchens = results['kitchens'] ?? [];
        _dishes = results['menu_items'] ?? [];
      });
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalResults = _kitchens.length + _dishes.length;

    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Stack(
        children: [
          // ─── Main Content ───
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      top: 130, // Space for fixed header & filters
                      bottom: 100, // Space for bottom nav
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Results Summary
                        Text(
                          '$totalResults KITCHENS & DISHES FOUND',
                          style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)
                              .copyWith(letterSpacing: 2),
                        ),
                        const SizedBox(height: 24),

                        // Featured Kitchens
                        if (_kitchens.isNotEmpty) ...[
                          Text(
                            'Featured Kitchens',
                            style: AppTextStyles.headlineMd(color: AppColors.primary),
                          ),
                          const SizedBox(height: 12),
                          ..._kitchens.map((k) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildKitchenCard(
                                kitchen: k,
                                context: context,
                              ),
                            );
                          }),
                          const SizedBox(height: 32),
                        ],

                        // Matching Dishes
                        if (_dishes.isNotEmpty) ...[
                          Text(
                            'Matching Dishes',
                            style: AppTextStyles.headlineMd(color: AppColors.primary),
                          ),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75, // Adjust for image + text
                            children: _dishes.map((d) {
                              return _buildDishCard(
                                dish: d,
                                context: context,
                              );
                            }).toList(),
                          ),
                        ],
                        
                        if (_kitchens.isEmpty && _dishes.isEmpty && !_isLoading)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Text('No results found for "${_searchController.text}"',
                                  style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
                            ),
                          )
                      ],
                    ),
                  ),
          ),

          // ─── Top AppBar (Sticky Search Header) ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: AppColors.surface.withValues(alpha: 0.8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search Bar Row
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 16,
                          left: 20,
                          right: 20,
                          bottom: 16,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                              onPressed: () {
                                if (Navigator.canPop(context)) Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    const Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                                        onSubmitted: _performSearch,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: 'Search...',
                                          hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.tune, color: AppColors.primary, size: 20),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                        child: Row(
                          children: [
                            _buildFilterChip('Sort by: Relevance', true, hasDropdown: true, onTap: () {}),
                            _buildFilterChip('Price: \$\$', false, onTap: () {}),
                            _buildFilterChip('Rating: 4.5+', false, onTap: () {}),
                            _buildFilterChip('Dietary', false, hasAdd: true, onTap: () {}),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.ghostBorder),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, {bool hasDropdown = false, bool hasAdd = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelSm(
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              ),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more,
                size: 16,
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              ),
            ],
            if (hasAdd) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.add,
                size: 16,
                color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKitchenCard({
    required KitchenModel kitchen,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => KitchenProfileScreen(kitchenId: kitchen.id)));
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
                  image: NetworkImage(kitchen.avatar),
                  fit: BoxFit.cover,
                  onError: (_, __) => const NetworkImage('https://ui-avatars.com/api/?name=Kitchen')
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
                        child: Text(kitchen.name, style: AppTextStyles.headlineMd(color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.primary, size: 14),
                          const SizedBox(width: 4),
                          Text(kitchen.rating.toStringAsFixed(1), style: AppTextStyles.labelMono(color: AppColors.onSurface)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(kitchen.cuisineType, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(child: Text(kitchen.location, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
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

  Widget _buildDishCard({
    required MenuItemModel dish,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => FoodDetailsScreen(menuItemId: dish.id)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      dish.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainer),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, color: AppColors.onSurface, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            // Details Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: AppTextStyles.bodyLg(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${dish.kitchenName}',
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${dish.price.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, color: AppColors.primary, size: 16),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
