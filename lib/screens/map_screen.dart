import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

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
  List<KitchenModel> _kitchens = [];
  bool _isLoading = true;
  bool _isLocating = false;

  // Base location (defaults to Jakarta if GPS is loading/denied, updated by real GPS)
  LatLng _baseLocation = const LatLng(-6.2088, 106.8456);
  bool _hasRealLocation = false;
  String? _userAddress;

  // Store coordinates so they remain consistent once mapped
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
    _requestRealGPS(flyToLocation: true);
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

        // Re-anchor kitchen relative positions if needed
        _updateKitchenPositions();

        if (flyToLocation) {
          _mapController.move(_baseLocation, 14.5);
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
    // Generate organic relative distances around real user location
    final random = Random(42); // Deterministic seed per kitchen id
    for (var k in _kitchens) {
      if (!_kitchenLocations.containsKey(k.id)) {
        // Spread kitchens within a realistic 1.5 - 6 km radius around the user
        final angle = (k.id * 73.0) * (pi / 180);
        final distanceKm = 1.0 + (random.nextDouble() * 4.5);
        // ~111km per degree
        final latOffset = (distanceKm / 111.0) * cos(angle);
        final lngOffset = (distanceKm / (111.0 * cos(_baseLocation.latitude * pi / 180))) * sin(angle);

        _kitchenLocations[k.id] = LatLng(
          _baseLocation.latitude + latOffset,
          _baseLocation.longitude + lngOffset,
        );
      }
    }
  }

  double _getDistanceKm(LatLng kitchenLoc) {
    return _distanceCalculator.as(LengthUnit.Kilometer, _baseLocation, kitchenLoc);
  }

  void _showKitchenDetails(KitchenModel kitchen) {
    final loc = _kitchenLocations[kitchen.id] ?? _baseLocation;
    final distanceKm = _getDistanceKm(loc);

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
                                    '${distanceKm.toStringAsFixed(1)} km away',
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nearby Kitchens', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
            if (_userAddress != null)
              Text(
                _userAddress!,
                style: AppTextStyles.labelSm(color: AppColors.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        actions: [
          IconButton(
            icon: _isLocating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Icon(Icons.refresh, color: AppColors.onSurface),
            tooltip: 'Refresh GPS Location',
            onPressed: _isLocating ? null : () => _requestRealGPS(flyToLocation: true, showFeedback: true),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _baseLocation,
                initialZoom: 14.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _baseLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
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
                      final distanceKm = _getDistanceKm(loc);

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
                                  '${distanceKm.toStringAsFixed(1)}km',
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
