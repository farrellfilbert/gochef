import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'search_results_screen.dart';
import '../map_screen.dart';

class SearchModal extends StatefulWidget {
  const SearchModal({super.key});

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // Base location for the mini-map (same as map_screen.dart)
  final LatLng _baseLocation = const LatLng(-6.3687, 106.8329);

  // Mock search history (in a real app, this would be fetched from shared_preferences or a database)
  final List<String> _searchHistory = [
    'Pasta',
    'Nasi Goreng',
    'Healthy Salad',
    'Spicy Chicken',
  ];

  // Mock recommended foods
  final List<Map<String, String>> _recommendedFoods = [
    {
      'name': 'Grilled Salmon Bowl',
      'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=300&auto=format&fit=crop'
    },
    {
      'name': 'Spicy Chicken Burger',
      'image': 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?q=80&w=300&auto=format&fit=crop'
    },
    {
      'name': 'Beef Steak',
      'image': 'https://images.unsplash.com/photo-1544025162-8111142c4baf?q=80&w=300&auto=format&fit=crop'
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto focus the search field when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;
    Navigator.pop(context); // Close modal
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(initialQuery: query.trim()),
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
            // Search Input
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                            onSubmitted: _submitSearch,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search student chefs or meals...',
                              hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, color: AppColors.onSurfaceVariant, size: 20),
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
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: AppTextStyles.labelSm(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search History
                  if (_searchHistory.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recent Searches', style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16)),
                          Text('Clear All', style: AppTextStyles.labelSm(color: AppColors.primary)),
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
                          return GestureDetector(
                            onTap: () => _submitSearch(query),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.history, size: 14, color: AppColors.onSurfaceVariant),
                                  const SizedBox(width: 6),
                                  Text(query, style: AppTextStyles.labelSm(color: AppColors.onSurface)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Mini Map
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Chefs Around You', style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16)),
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
                                initialZoom: 13.0,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none, // Make map static in the modal for easy scrolling
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.astroboomin.gochef',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _baseLocation,
                                      width: 30,
                                      height: 30,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary.withValues(alpha: 0.2),
                                        ),
                                        child: Center(
                                          child: Container(
                                            width: 12,
                                            height: 12,
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
                            // Overlay to act as a button
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
                                  padding: const EdgeInsets.all(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('View Full Map', style: AppTextStyles.labelMono(color: AppColors.primary).copyWith(fontSize: 10)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Recommended Foods
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Recommended For You', style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _recommendedFoods.length,
                      itemBuilder: (context, index) {
                        final food = _recommendedFoods[index];
                        return GestureDetector(
                          onTap: () => _submitSearch(food['name']!),
                          child: Container(
                            width: 120,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: Image.network(
                                    food['image']!,
                                    height: 80,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    food['name']!,
                                    style: AppTextStyles.labelSm(color: AppColors.onSurface),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40), // Bottom padding
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
