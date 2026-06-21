import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/menu_provider.dart';
import '../widgets/premium/glass_container.dart';
import '../widgets/premium/bouncing_tap.dart';
import 'dummy_detail_screen.dart';
import 'menu_detail_screen.dart';

class MapSearchScreen extends ConsumerStatefulWidget {
  const MapSearchScreen({super.key});

  @override
  ConsumerState<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends ConsumerState<MapSearchScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';
  
  final List<LatLng> _dummyChefs = [];
  Timer? _animationTimer;

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    // Auto focus the search bar after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _errorMessage = 'Location access denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Permissions permanently denied');
      } 

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
          _generateDummyChefs();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Fallback to Jakarta
          _currentPosition = const LatLng(-6.200000, 106.816666);
          _isLoading = false;
          _generateDummyChefs();
        });
      }
    }
  }

  void _generateDummyChefs() {
    if (_currentPosition == null) return;
    final random = Random();
    for (int i = 0; i < 6; i++) {
      double latOffset = (random.nextDouble() - 0.5) * 0.015;
      double lngOffset = (random.nextDouble() - 0.5) * 0.015;
      _dummyChefs.add(LatLng(
        _currentPosition!.latitude + latOffset,
        _currentPosition!.longitude + lngOffset,
      ));
    }

    _animationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _dummyChefs.length; i++) {
          double latOffset = (random.nextDouble() - 0.5) * 0.0005;
          double lngOffset = (random.nextDouble() - 0.5) * 0.0005;
          _dummyChefs[i] = LatLng(
            _dummyChefs[i].latitude + latOffset,
            _dummyChefs[i].longitude + lngOffset,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(menuProvider);
    
    // Fallback empty list if data is loading or error
    final menuItems = menuAsync.maybeWhen(
      data: (items) => items,
      orElse: () => <MenuItem>[],
    );

    List<MenuItem> filteredResults = _searchQuery.isEmpty
        ? []
        : menuItems.where((item) => 
            item.name.toLowerCase().contains(_searchQuery) ||
            item.category.toLowerCase().contains(_searchQuery) ||
            item.cuisine.toLowerCase().contains(_searchQuery)).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // 1. BACKGROUND MAP
          _buildMapLayer(),

          // 2. SEARCH BAR OVERLAY
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceColor.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassContainer(
                          color: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 52,
                          borderRadius: BorderRadius.circular(26),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.search, color: AppTheme.fuchsiaPrimary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocus,
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Search food or chefs around you...',
                                    hintStyle: TextStyle(
                                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    _searchFocus.requestFocus();
                                  },
                                  child: const Icon(LucideIcons.x, color: AppTheme.textSecondary, size: 20),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // 3. SEARCH RESULTS DROPDOWN / LIST
                  if (_searchQuery.isNotEmpty)
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        child: filteredResults.isEmpty
                            ? Center(
                                child: GlassContainer(
                                  child: Text(
                                    'No results found for "$_searchQuery"',
                                    style: const TextStyle(color: AppTheme.textSecondary),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 24),
                                itemCount: filteredResults.length,
                                itemBuilder: (context, index) {
                                  final item = filteredResults[index];
                                  
                                  return BouncingTap(
                                    onTap: () {
                                      _searchFocus.unfocus();
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MenuDetailScreen(item: item)));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceColor.withValues(alpha: 0.95),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                      ),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(12),
                                        leading: Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            shape: BoxShape.rectangle,
                                            image: DecorationImage(
                                              image: NetworkImage(item.image),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          item.name,
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 4),
                                            Text(
                                              '${item.cuisine} • ${item.category}',
                                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(LucideIcons.mapPin, color: AppTheme.fuchsiaPrimary, size: 12),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'Nearby',
                                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: Text(
                                          item.price,
                                          style: const TextStyle(
                                            color: AppTheme.fuchsiaPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapLayer() {
    if (_isLoading) {
      return Container(
        color: AppTheme.backgroundDark,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.fuchsiaPrimary),
        ),
      );
    }

    if (_currentPosition == null) {
      return Container(color: AppTheme.backgroundDark);
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition!,
        initialZoom: 15.0,
        maxZoom: 18.0,
        minZoom: 5.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.gochef',
          // A dark tile layer or styling would be nice, but standard OSM is fine for now
        ),
        MarkerLayer(
          markers: [
            // Current Location Marker
            Marker(
              point: _currentPosition!,
              width: 60,
              height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Dummy Chefs Markers
            ..._dummyChefs.map((pos) => Marker(
                  point: pos,
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () {
                      _searchFocus.unfocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chef Location Selected!')),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.fuchsiaPrimary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.chefHat, color: Colors.white, size: 20),
                    ),
                  ),
                )),
          ],
        ),
      ],
    );
  }
}
