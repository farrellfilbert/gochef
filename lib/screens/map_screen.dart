import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';
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

  // Base location (defaults to Jakarta/Depok, updated by GPS)
  LatLng _baseLocation = const LatLng(-6.3687, 106.8329);
  bool _hasRealLocation = false;

  // Store generated coordinates so they don't change on rebuild
  final Map<int, LatLng> _kitchenLocations = {};

  @override
  void initState() {
    super.initState();
    _initLocationAndFetch();
  }

  Future<void> _initLocationAndFetch() async {
    // Geolocation disabled for web compatibility. 
    // Just fetch kitchens using the default base location.
    await _fetchKitchens();
  }

  Future<void> _fetchKitchens() async {
    try {
      final kitchens = await ApiService.getKitchens();
      
      // Generate dummy coordinates around the base location
      final random = Random();
      for (var k in kitchens) {
        // +/- 0.05 degrees is roughly +/- 5.5km
        double latOffset = (random.nextDouble() - 0.5) * 0.1;
        double lngOffset = (random.nextDouble() - 0.5) * 0.1;
        _kitchenLocations[k.id] = LatLng(
          _baseLocation.latitude + latOffset,
          _baseLocation.longitude + lngOffset,
        );
      }

      setState(() {
        _kitchens = kitchens;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showKitchenDetails(KitchenModel kitchen) {
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                kitchen.cuisineType,
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
                    'View Kitchen',
                    style: AppTextStyles.labelMono(color: AppColors.onPrimary),
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
        title: Text('Nearby Chefs', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _baseLocation,
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.astroboomin.gochef',
                ),
                MarkerLayer(
                  markers: [
                    // User's own location marker
                    if (_hasRealLocation)
                      Marker(
                        point: _baseLocation,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withValues(alpha: 0.2),
                          ),
                          child: Center(
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Kitchen markers
                    ..._kitchens.map((k) {
                      final loc = _kitchenLocations[k.id] ?? _baseLocation;
                      return Marker(
                        point: loc,
                        width: 60,
                        height: 60,
                        child: GestureDetector(
                          onTap: () => _showKitchenDetails(k),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.primary, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundImage: NetworkImage(k.avatar),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.outlineVariant),
                                ),
                                child: Text(
                                  k.name,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          _mapController.move(_baseLocation, 13.0);
        },
        child: const Icon(Icons.my_location, color: AppColors.onPrimary),
      ),
    );
  }
}
