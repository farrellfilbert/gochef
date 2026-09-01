import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'search_results_screen.dart';
import '../map_screen.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';
import '../../models/menu_item_model.dart';

class SearchModal extends StatefulWidget {
  const SearchModal({super.key});

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Base location for mini-map (North Hollywood / LA default, matching app theme)
  LatLng _baseLocation = const LatLng(34.1722, -118.3765);

  // Real persistent search history
  List<String> _searchHistory = [];
  bool _isLoadingHistory = true;

  // Real recommended foods fetched from API
  List<MenuItemModel> _recommendedFoods = [];
  bool _isLoadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    // Auto focus the search field when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _loadRecentSearches();
    _fetchRecommendations();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final loc = await LocationService.getCurrentLocation();
      if (loc != null && mounted) {
        setState(() {
          _baseLocation = loc.coordinates;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedHistory = prefs.getStringList('recent_searches');
      if (savedHistory != null && savedHistory.isNotEmpty) {
        if (mounted) {
          setState(() {
            _searchHistory = savedHistory;
            _isLoadingHistory = false;
          });
        }
      } else {
        // Default initial suggestions for first-time users
        final defaultSuggestions = ['Truffle Pasta', 'Smoked Brisket', 'Healthy Salad', 'Spicy Ramen'];
        if (mounted) {
          setState(() {
            _searchHistory = defaultSuggestions;
            _isLoadingHistory = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchHistory = ['Truffle Pasta', 'Smoked Brisket', 'Healthy Salad', 'Spicy Ramen'];
          _isLoadingHistory = false;
        });
      }
    }
  }

  Future<void> _saveRecentSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _searchHistory.removeWhere((item) => item.toLowerCase() == cleanQuery.toLowerCase());
      _searchHistory.insert(0, cleanQuery);
      if (_searchHistory.length > 8) {
        _searchHistory = _searchHistory.sublist(0, 8);
      }
      await prefs.setStringList('recent_searches', _searchHistory);
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _removeRecentSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _searchHistory.removeWhere((item) => item.toLowerCase() == query.toLowerCase());
      });
      await prefs.setStringList('recent_searches', _searchHistory);
    } catch (_) {}
  }

  Future<void> _clearAllRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _searchHistory.clear();
      });
      await prefs.remove('recent_searches');
    } catch (_) {}
  }

  Future<void> _fetchRecommendations() async {
    try {
      final homeData = await ApiService.getHomeData();
      final List<MenuItemModel> popularMeals = homeData['popular_meals'] ?? [];
      if (mounted) {
        setState(() {
          _recommendedFoods = popularMeals.take(6).toList();
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    _saveRecentSearch(cleanQuery);
    Navigator.pop(context); // Close modal
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(initialQuery: cleanQuery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Search Input Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          const Icon(Icons.search, color: AppColors.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              style: AppTextStyles.bodyMd(color: Colors.white),
                              onSubmitted: _submitSearch,
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: 'Search Chefs, Kitchens or Meals…',
                                hintStyle: AppTextStyles.bodyMd(color: Colors.white60),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.white70, size: 18),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: AppTextStyles.labelSm(color: Colors.white70)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent Searches Section
                    if (_searchHistory.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Searches',
                              style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              onTap: _clearAllRecentSearches,
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Text(
                                  'Clear All',
                                  style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _searchHistory.map((query) {
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () => _submitSearch(query),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.history, size: 14, color: AppColors.primary),
                                        const SizedBox(width: 6),
                                        Text(query, style: AppTextStyles.labelSm(color: AppColors.onSurface)),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () => _removeRecentSearch(query),
                                          child: Icon(Icons.close, size: 13, color: Colors.white.withValues(alpha: 0.4)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],

                    // Chefs Around You (Mini Map Preview)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Chefs Around You',
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              FlutterMap(
                                options: MapOptions(
                                  initialCenter: _baseLocation,
                                  initialZoom: 12.5,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none, // Static in modal for easy scrolling
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                                    subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                                    userAgentPackageName: 'com.astroboomin.gochef',
                                  ),
                                  TileLayer(
                                    urlTemplate: 'https://{s}.google.com/vt/lyrs=h&x={x}&y={y}&z={z}',
                                    subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                                    userAgentPackageName: 'com.astroboomin.gochef',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: _baseLocation,
                                        width: 36,
                                        height: 36,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.primary.withValues(alpha: 0.3),
                                          ),
                                          child: Center(
                                            child: Container(
                                              width: 14,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.primary,
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Overlay Button to open full map
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MapScreen()),
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    alignment: Alignment.bottomRight,
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.map_outlined, color: Colors.white, size: 13),
                                          const SizedBox(width: 5),
                                          Text(
                                            'View Full Map',
                                            style: AppTextStyles.labelSm(color: Colors.white)
                                                .copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Recommended Foods Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Recommended For You',
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _isLoadingRecommendations 
                      ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.primary)))
                      : _recommendedFoods.isEmpty 
                          ? const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('No recommendations available.', style: TextStyle(color: Colors.white60)))
                          : SizedBox(
                              height: 155,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _recommendedFoods.length,
                                itemBuilder: (context, index) {
                                  final food = _recommendedFoods[index];
                                  return GestureDetector(
                                    onTap: () => _submitSearch(food.name),
                                    child: Container(
                                      width: 130,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                            child: Image.network(
                                              food.image,
                                              height: 85,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                height: 85,
                                                color: AppColors.surfaceContainer,
                                                child: const Icon(Icons.fastfood, color: Colors.white30),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  food.name,
                                                  style: AppTextStyles.labelSm(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '\$${food.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
