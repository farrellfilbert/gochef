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
  List<KitchenModel> _rawKitchens = [];
  List<MenuItemModel> _rawDishes = [];
  List<KitchenModel> _kitchens = [];
  List<MenuItemModel> _dishes = [];

  String _sortBy = 'relevance'; // 'relevance', 'price_asc', 'price_desc', 'rating'
  String? _selectedPriceRange; // null, '$', '$$', '$$$'
  double _minRating = 0.0; // 0.0, 4.0, 4.5
  String? _selectedDietary; // null, 'Halal', 'Vegan', 'Vegetarian', 'Gluten-Free', 'Keto'
  double _maxPrice = 100.0;

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
      _rawKitchens = results['kitchens'] ?? [];
      _rawDishes = results['menu_items'] ?? [];
      _applyFilters();
    } catch (e) {
      debugPrint('Search error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<MenuItemModel> dishes = List.from(_rawDishes);
    List<KitchenModel> kitchens = List.from(_rawKitchens);

    // Max Price filter
    if (_maxPrice < 100.0) {
      dishes = dishes.where((d) => d.price <= _maxPrice).toList();
    }

    // Price Range filter ($: <=15, $$: 15-30, $$$: >30)
    if (_selectedPriceRange == r'$') {
      dishes = dishes.where((d) => d.price <= 15.0).toList();
    } else if (_selectedPriceRange == r'$$') {
      dishes = dishes.where((d) => d.price > 15.0 && d.price <= 30.0).toList();
    } else if (_selectedPriceRange == r'$$$') {
      dishes = dishes.where((d) => d.price > 30.0).toList();
    }

    // Min Rating filter
    if (_minRating > 0.0) {
      kitchens = kitchens.where((k) => k.rating >= _minRating).toList();
      dishes = dishes.where((d) => d.rating >= _minRating).toList();
    }

    // Dietary filter
    if (_selectedDietary != null && _selectedDietary!.isNotEmpty) {
      final queryTag = _selectedDietary!.toLowerCase();
      dishes = dishes.where((d) {
        final name = d.name.toLowerCase();
        final desc = d.description.toLowerCase();
        final cat = d.categoryName.toLowerCase();
        return name.contains(queryTag) || desc.contains(queryTag) || cat.contains(queryTag);
      }).toList();
    }

    // Sorting
    if (_sortBy == 'price_asc') {
      dishes.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'price_desc') {
      dishes.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'rating') {
      dishes.sort((a, b) => b.rating.compareTo(a.rating));
      kitchens.sort((a, b) => b.rating.compareTo(a.rating));
    }

    if (mounted) {
      setState(() {
        _dishes = dishes;
        _kitchens = kitchens;
        _isLoading = false;
      });
    }
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'price_asc':
        return 'Price: Low-High';
      case 'price_desc':
        return 'Price: High-Low';
      case 'rating':
        return 'Rating: High-Low';
      default:
        return 'Relevance';
    }
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Sort By', style: AppTextStyles.headlineMd(color: Colors.white)),
              const SizedBox(height: 16),
              _buildModalOption(
                title: 'Relevance (Default)',
                isSelected: _sortBy == 'relevance',
                onTap: () {
                  setState(() => _sortBy = 'relevance');
                  Navigator.pop(ctx);
                  _applyFilters();
                },
              ),
              _buildModalOption(
                title: 'Price: Low to High',
                isSelected: _sortBy == 'price_asc',
                onTap: () {
                  setState(() => _sortBy = 'price_asc');
                  Navigator.pop(ctx);
                  _applyFilters();
                },
              ),
              _buildModalOption(
                title: 'Price: High to Low',
                isSelected: _sortBy == 'price_desc',
                onTap: () {
                  setState(() => _sortBy = 'price_desc');
                  Navigator.pop(ctx);
                  _applyFilters();
                },
              ),
              _buildModalOption(
                title: 'Highest Rated (4.5+ ⭐)',
                isSelected: _sortBy == 'rating',
                onTap: () {
                  setState(() => _sortBy = 'rating');
                  Navigator.pop(ctx);
                  _applyFilters();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showPriceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Filter by Price', style: AppTextStyles.headlineMd(color: Colors.white)),
              const SizedBox(height: 16),
              _buildModalOption(
                title: 'All Prices',
                isSelected: _selectedPriceRange == null,
                onTap: () {
                  setState(() => _selectedPriceRange = null);
                  Navigator.pop(ctx);
                  _applyFilters();
                },
              ),
              _buildModalOption(
                title: r'$  •  Under $15 (Affordable)',
                isSelected: _selectedPriceRange == r'$',
                onTap: () {
                  setState(() => _selectedPriceRange = r'$');
                  Navigator.pop(ctx);
                  _applyFilters();
                },
              ),
              _buildModalOption(
                title: r'$$  •  $15 - $30 (Standard)',
                isSelected: _selectedPriceRange == r'$$',
                onTap: () {
                  setState(() => _selectedPriceRange = r'$$');
                  Navigator.pop(ctx);
                  _applyFilters();
                },
              ),
              _buildModalOption(
                title: r'$$$  •  Over $30 (Premium / Gourmet)',
                isSelected: _selectedPriceRange == r'$$$',
                onTap: () {
                  setState(() => _selectedPriceRange = r'$$$');
                  Navigator.pop(ctx);
                  _applyFilters();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showRatingModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Filter by Rating', style: AppTextStyles.headlineMd(color: Colors.white)),
              const SizedBox(height: 16),
              _buildModalOption(
                title: 'All Ratings',
                isSelected: _minRating == 0.0,
                onTap: () {
                  setState(() => _minRating = 0.0);
                  Navigator.pop(ctx);
                  _applyFilters();
                },
              ),
              _buildModalOption(
                title: '4.0+ Stars ⭐⭐⭐⭐',
                isSelected: _minRating == 4.0,
                onTap: () {
                  setState(() => _minRating = 4.0);
                  Navigator.pop(ctx);
                  _applyFilters();
                },
              ),
              _buildModalOption(
                title: '4.5+ Stars ⭐⭐⭐⭐⭐ (Top Rated)',
                isSelected: _minRating == 4.5,
                onTap: () {
                  setState(() => _minRating = 4.5);
                  Navigator.pop(ctx);
                  _applyFilters();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDietaryModal() {
    final options = ['All', 'Halal', 'Vegan', 'Vegetarian', 'Gluten-Free', 'Organic', 'Keto', 'Pasta', 'Spicy', 'BBQ', 'Seafood'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Dietary & Preferences', style: AppTextStyles.headlineMd(color: Colors.white)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 10,
                children: options.map((opt) {
                  final isSel = (opt == 'All' && _selectedDietary == null) || (_selectedDietary == opt);
                  return ChoiceChip(
                    label: Text(opt),
                    selected: isSel,
                    selectedColor: Colors.white,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.black : Colors.white,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onSelected: (selected) {
                      setState(() {
                        _selectedDietary = (opt == 'All') ? null : opt;
                      });
                      Navigator.pop(ctx);
                      _applyFilters();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showTuneFilterModal() {
    double tempMaxPrice = _maxPrice;
    double tempMinRating = _minRating;
    String tempSort = _sortBy;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
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
                      Text('All Filters', style: AppTextStyles.headlineMd(color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Max Price', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.w600)),
                      Text('\$${tempMaxPrice.toStringAsFixed(0)}', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Slider(
                    value: tempMaxPrice,
                    min: 5.0,
                    max: 100.0,
                    divisions: 19,
                    activeColor: Colors.white,
                    inactiveColor: AppColors.outlineVariant.withValues(alpha: 0.3),
                    onChanged: (val) => setModalState(() => tempMaxPrice = val),
                  ),
                  const SizedBox(height: 20),
                  Text('Minimum Rating', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildModalRatingChip('Any', 0.0, tempMinRating, (val) => setModalState(() => tempMinRating = val)),
                      const SizedBox(width: 8),
                      _buildModalRatingChip('4.0+ ⭐', 4.0, tempMinRating, (val) => setModalState(() => tempMinRating = val)),
                      const SizedBox(width: 8),
                      _buildModalRatingChip('4.5+ ⭐', 4.5, tempMinRating, (val) => setModalState(() => tempMinRating = val)),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            setState(() {
                              _maxPrice = 100.0;
                              _minRating = 0.0;
                              _sortBy = 'relevance';
                              _selectedPriceRange = null;
                              _selectedDietary = null;
                            });
                            Navigator.pop(ctx);
                            _applyFilters();
                          },
                          child: const Text('Reset All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            setState(() {
                              _maxPrice = tempMaxPrice;
                              _minRating = tempMinRating;
                              _sortBy = tempSort;
                            });
                            Navigator.pop(ctx);
                            _applyFilters();
                          },
                          child: const Text('Apply Filters', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalOption({required String title, required bool isSelected, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.white) : const Icon(Icons.circle_outlined, color: Colors.white30),
    );
  }

  Widget _buildModalRatingChip(String label, double value, double current, Function(double) onSelect) {
    final isSel = current == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? Colors.white : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSel ? Colors.white : AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSel ? Colors.black : Colors.white, fontWeight: isSel ? FontWeight.bold : FontWeight.normal),
        ),
      ),
    );
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
                          style: AppTextStyles.labelSm(color: Colors.white70)
                              .copyWith(letterSpacing: 2, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),

                        // Featured Kitchens
                        if (_kitchens.isNotEmpty) ...[
                          Text(
                            'Featured Kitchens',
                            style: AppTextStyles.headlineMd(color: Colors.white),
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
                            style: AppTextStyles.headlineMd(color: Colors.white),
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
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                                    const Icon(Icons.search, color: Colors.white70, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: _searchController,
                                        style: AppTextStyles.bodyMd(color: Colors.white),
                                        onSubmitted: _performSearch,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                          hintText: 'Search Chefs, Kitchens or Meals…',
                                          hintStyle: TextStyle(color: Colors.white70),
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
                                color: (_maxPrice < 100.0 || _minRating > 0.0) ? Colors.white : AppColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.tune, color: (_maxPrice < 100.0 || _minRating > 0.0) ? Colors.black : Colors.white, size: 20),
                                onPressed: _showTuneFilterModal,
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
                            _buildFilterChip(
                              _sortBy == 'relevance' ? 'Sort by: Relevance' : 'Sort: ${_getSortLabel()}',
                              _sortBy != 'relevance',
                              hasDropdown: true,
                              onTap: _showSortModal,
                            ),
                            _buildFilterChip(
                              _selectedPriceRange == null ? 'Price: \$\$' : 'Price: $_selectedPriceRange',
                              _selectedPriceRange != null,
                              onTap: _showPriceModal,
                            ),
                            _buildFilterChip(
                              _minRating == 0.0 ? 'Rating: 4.5+' : 'Rating: ${_minRating}+ ⭐',
                              _minRating > 0.0,
                              onTap: _showRatingModal,
                            ),
                            _buildFilterChip(
                              _selectedDietary == null ? 'Dietary' : 'Dietary: $_selectedDietary',
                              _selectedDietary != null,
                              hasAdd: _selectedDietary == null,
                              onTap: _showDietaryModal,
                            ),
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
          color: isSelected ? Colors.white : AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : AppColors.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelSm(
                color: isSelected ? Colors.black : Colors.white,
              ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
            ),
            if (hasDropdown) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more,
                size: 16,
                color: isSelected ? Colors.black : Colors.white,
              ),
            ],
            if (hasAdd) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.add,
                size: 16,
                color: isSelected ? Colors.black : Colors.white,
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
                        style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add, color: AppColors.onPrimary, size: 14),
                            const SizedBox(width: 4),
                            Text('Add', style: AppTextStyles.labelSm(color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
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
