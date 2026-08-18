import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';
import 'dart:async';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../models/kitchen_model.dart';
import 'kitchen/kitchen_profile_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  List<KitchenModel> _kitchens = [];
  bool _isLoading = true;
  bool _isLocating = false;

  // Base location (defaults to North Hollywood / Los Angeles area matching screenshot)
  LatLng _baseLocation = const LatLng(34.1722, -118.3765);
  bool _hasRealLocation = false;
  String? _userAddress;

  // Fixed static coordinates table across North Hollywood / San Fernando Valley (5-8 mi range)
  static const List<LatLng> _defaultFixedCoords = [
    LatLng(34.1722, -118.3765), // North Hollywood (1.0 mi)
    LatLng(34.1610, -118.3920), // Valley Village (2.0 mi)
    LatLng(34.1480, -118.3890), // Studio City (3.0 mi)
    LatLng(34.1810, -118.4280), // Valley Glen (4.0 mi)
    LatLng(34.1520, -118.4480), // Sherman Oaks (5.0 mi)
    LatLng(34.2050, -118.3980), // Sun Valley (3.0 mi)
    LatLng(34.2270, -118.4480), // Panorama City (5.0 mi)
    LatLng(34.1380, -118.3550), // Toluca Lake/Burbank (4.0 mi)
    LatLng(34.1350, -118.4120), // Coldwater Canyon (5.0 mi)
    LatLng(34.1660, -118.4550), // Los Angeles Valley College (5.0 mi)
    LatLng(34.1560, -118.4650), // Sherman Oaks (6.0 mi)
    LatLng(34.1470, -118.4720), // Sherman Oaks South (6.0 mi)
    LatLng(34.1200, -118.4800), // Beverly Glen (7.0 mi)
    LatLng(34.0950, -118.4120), // Greystone Mansion (7.0 mi)
    LatLng(34.0880, -118.4050), // Beverly Hills (8.0 mi)
  ];

  // Store coordinates so they remain permanently fixed
  final Map<int, LatLng> _kitchenLocations = {};
  final Distance _distanceCalculator = const Distance();

  @override
  void initState() {
    super.initState();
    _initLocationAndFetch();
  }

  Future<void> _initLocationAndFetch() async {
    // 1. Check if we have cached last known location
    final cachedLoc = await LocationService.getLastKnownLocation();
    if (cachedLoc != null && mounted) {
      _baseLocation = cachedLoc;
      _hasRealLocation = true;
    }
    _userAddress = await LocationService.getLastKnownAddress();

    // 2. Fetch kitchens from API
    await _fetchKitchens();

    // 3. Request fresh Real GPS location in parallel
    _requestRealGPS(flyToLocation: false);
  }

  Future<void> _requestRealGPS({bool flyToLocation = false, bool showFeedback = false}) async {
    if (!mounted) return;
    setState(() => _isLocating = true);

    try {
      final locResult = await LocationService.getCurrentLocation();
      if (locResult != null && mounted) {
        setState(() {
          _baseLocation = locResult.coordinates;
          _hasRealLocation = true;
          _userAddress = locResult.address;
          _isLocating = false;
        });

        if (flyToLocation) {
          _mapController.move(_baseLocation, 12.8);
        }

        if (showFeedback && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.my_location, color: Colors.greenAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _userAddress != null
                          ? '📍 Location locked: $_userAddress'
                          : '📍 GPS Location locked (${_baseLocation.latitude.toStringAsFixed(4)}, ${_baseLocation.longitude.toStringAsFixed(4)})',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.surface,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() => _isLocating = false);
          if (showFeedback) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Unable to access GPS. Please allow location permissions in your browser.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _fetchKitchens() async {
    try {
      final kitchens = await ApiService.getKitchens();
      _kitchens = kitchens;
      _updateKitchenPositions();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _updateKitchenPositions() {
    // Ensure all kitchens have permanent, fixed coordinates that NEVER move
    for (int i = 0; i < _kitchens.length; i++) {
      final k = _kitchens[i];
      if (k.latitude != null && k.longitude != null && k.latitude != 0 && k.longitude != 0) {
        _kitchenLocations[k.id] = LatLng(k.latitude!, k.longitude!);
      } else {
        // Deterministic fixed coordinate assignment by kitchen ID
        final fixedIndex = (k.id - 1).abs() % _defaultFixedCoords.length;
        _kitchenLocations[k.id] = _defaultFixedCoords[fixedIndex];
      }
    }
  }

  double _getDistanceMiles(LatLng kitchenLoc) {
    return _distanceCalculator.as(LengthUnit.Mile, _baseLocation, kitchenLoc);
  }

  void _showKitchenDetails(KitchenModel kitchen) {
    final loc = _kitchenLocations[kitchen.id] ?? _baseLocation;
    final distanceMiles = _getDistanceMiles(loc);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(kitchen.avatar),
                    backgroundColor: AppColors.surfaceContainerHighest,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kitchen.name, style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.primary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${kitchen.rating} (${kitchen.totalReviews} reviews)',
                              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.near_me, color: AppColors.primary, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${distanceMiles.toStringAsFixed(1)} mi away',
                                    style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                kitchen.cuisineType.isNotEmpty ? kitchen.cuisineType : 'Gourmet Homemade Kitchen',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KitchenProfileScreen(kitchenId: kitchen.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'View Kitchen Profile',
                    style: AppTextStyles.labelSm(color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      final results = await LocationService.searchLocations(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _selectLocation(Map<String, dynamic> item) {
    final lat = item['lat'] as double;
    final lon = item['lon'] as double;
    final name = item['display_name'] as String;

    setState(() {
      _baseLocation = LatLng(lat, lon);
      _userAddress = name;
      _searchController.text = name;
      _searchResults.clear();
      _hasRealLocation = true;
    });

    _mapController.move(_baseLocation, 12.8);
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '📍 Location set to: $name',
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Stack(
              children: [
                // 1. Map Layer
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _baseLocation,
                    initialZoom: 12.5,
                    minZoom: 3.0,
                    maxZoom: 19.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.scrollWheelZoom |
                          InteractiveFlag.doubleTapZoom,
                    ),
                    onTap: (tapPosition, point) {
                      setState(() {
                        _baseLocation = point;
                        _searchResults.clear();
                      });
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  children: [
                    // Clean Satellite Layer
                    TileLayer(
                      urlTemplate: 'https://{s}.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                      subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                      userAgentPackageName: 'com.astroboomin.gochef',
                    ),
                    // Clean Roads, Streets & City Labels Layer (WITHOUT competitor business POIs)
                    TileLayer(
                      urlTemplate: 'https://{s}.google.com/vt/lyrs=h&x={x}&y={y}&z={z}',
                      subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                      userAgentPackageName: 'com.astroboomin.gochef',
                    ),
                    MarkerLayer(
                      markers: [
                        // User's own real GPS location marker (pulsating glow circle)
                        Marker(
                          point: _baseLocation,
                          width: 70,
                          height: 70,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer pulse wave
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withValues(alpha: 0.25),
                                ),
                              ),
                              // Inner circle
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.6),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Kitchen markers
                        ..._kitchens.map((k) {
                          final loc = _kitchenLocations[k.id] ?? _baseLocation;
                          final distanceMiles = _getDistanceMiles(loc);

                          return Marker(
                            point: loc,
                            width: 70,
                            height: 70,
                            child: GestureDetector(
                              onTap: () => _showKitchenDetails(k),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primary, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundImage: NetworkImage(k.avatar),
                                      backgroundColor: AppColors.surface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${distanceMiles.toStringAsFixed(1)} mi',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),

                // 2. Top Floating Search Bar & Autocomplete
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search Bar Card
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.glassBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                onPressed: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  }
                                },
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: _onSearchChanged,
                                  style: AppTextStyles.bodyMd(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Search city, area, or address...',
                                    hintStyle: AppTextStyles.bodyMd(
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              if (_isSearching)
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                  ),
                                )
                              else if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchResults = []);
                                  },
                                ),
                              IconButton(
                                icon: _isLocating
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                      )
                                    : const Icon(Icons.my_location, color: AppColors.primary),
                                tooltip: 'My GPS Location',
                                onPressed: _isLocating ? null : () => _requestRealGPS(flyToLocation: true, showFeedback: true),
                              ),
                            ],
                          ),
                        ),

                        // Autocomplete Search Results Dropdown
                        if (_searchResults.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            constraints: const BoxConstraints(maxHeight: 240),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.96),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.glassBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _searchResults.length,
                                separatorBuilder: (context, index) => Divider(
                                  color: AppColors.outlineVariant.withValues(alpha: 0.1),
                                  height: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final item = _searchResults[index];
                                  final displayName = item['display_name']?.toString() ?? '';
                                  return ListTile(
                                    leading: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                                    title: Text(
                                      displayName,
                                      style: AppTextStyles.bodyMd(color: Colors.white),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () => _selectLocation(item),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 3. Bottom Location Info Pill
                if (_userAddress != null)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 80,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.glassBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.near_me, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Area: $_userAddress',
                              style: AppTextStyles.labelSm(color: Colors.white).copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 4. Floating Zoom In / Zoom Out Controls
                Positioned(
                  right: 16,
                  bottom: 140,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            onTap: () {
                              final currentZoom = _mapController.camera.zoom;
                              if (currentZoom < 19.0) {
                                _mapController.move(_mapController.camera.center, (currentZoom + 1).clamp(3.0, 19.0));
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.add, color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 1,
                          color: AppColors.ghostBorder,
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                            onTap: () {
                              final currentZoom = _mapController.camera.zoom;
                              if (currentZoom > 3.0) {
                                _mapController.move(_mapController.camera.center, (currentZoom - 1).clamp(3.0, 19.0));
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(Icons.remove, color: Colors.white, size: 22),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _isLocating ? null : () => _requestRealGPS(flyToLocation: true, showFeedback: true),
        icon: _isLocating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
              )
            : const Icon(Icons.my_location, color: AppColors.onPrimary),
        label: Text(
          _hasRealLocation ? 'My GPS Location' : 'Locate Me',
          style: AppTextStyles.labelSm(color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
