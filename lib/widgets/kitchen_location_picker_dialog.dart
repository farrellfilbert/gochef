import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class KitchenLocationPickerDialog extends StatefulWidget {
  final int kitchenId;
  final double initialLat;
  final double initialLng;
  final String initialAddress;

  const KitchenLocationPickerDialog({
    super.key,
    required this.kitchenId,
    required this.initialLat,
    required this.initialLng,
    required this.initialAddress,
  });

  @override
  State<KitchenLocationPickerDialog> createState() => _KitchenLocationPickerDialogState();
}

class _KitchenLocationPickerDialogState extends State<KitchenLocationPickerDialog> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  late LatLng _selectedLocation;
  late String _address;
  bool _isSearching = false;
  bool _isSaving = false;
  bool _isMapReady = false;
  List<Map<String, dynamic>> _searchResults = [];

  void _safeMove(LatLng target, double zoom) {
    if (_isMapReady) {
      try {
        _mapController.move(target, zoom);
      } catch (e) {
        debugPrint('Kitchen location picker map move ignored: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(
      widget.initialLat != 0 ? widget.initialLat : 34.1722,
      widget.initialLng != 0 ? widget.initialLng : -118.3765,
    );
    _address = widget.initialAddress.isNotEmpty ? widget.initialAddress : 'North Hollywood, CA';
    _searchController.text = _address;
  }

  @override
  void dispose() {
    _isMapReady = false;
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5');
      final res = await http.get(url, headers: {'User-Agent': 'GoChefApp/1.0 (contact@thegrubnextdoor.com)'});

      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        if (mounted) {
          setState(() {
            _searchResults = data.map((e) {
              return {
                'display_name': e['display_name'] ?? '',
                'lat': double.tryParse(e['lat'].toString()) ?? 0.0,
                'lon': double.tryParse(e['lon'].toString()) ?? 0.0,
              };
            }).toList();
            _isSearching = false;
          });
        }
      } else {
        if (mounted) setState(() => _isSearching = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _useCurrentGps() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📍 Detecting current GPS location...'), duration: Duration(seconds: 1)),
    );
    try {
      final loc = await LocationService.getCurrentLocation();
      if (loc != null && mounted) {
        setState(() {
          _selectedLocation = loc.coordinates;
          if (loc.address != null && loc.address!.isNotEmpty) {
            _address = loc.address!;
            _searchController.text = loc.address!;
          }
        });
        _safeMove(_selectedLocation, 15.0);
      }
    } catch (_) {}
  }

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json');
      final res = await http.get(url, headers: {'User-Agent': 'GoChefApp/1.0 (contact@thegrubnextdoor.com)'});
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final addr = data['display_name'] as String?;
        if (addr != null && mounted) {
          setState(() {
            _address = addr;
            _searchController.text = addr;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _saveLocation() async {
    setState(() => _isSaving = true);
    try {
      final success = await ApiService.updateKitchen({
        'kitchen_id': widget.kitchenId,
        'location': _address,
        'latitude': _selectedLocation.latitude,
        'longitude': _selectedLocation.longitude,
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Kitchen map pin location saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, {
            'latitude': _selectedLocation.latitude,
            'longitude': _selectedLocation.longitude,
            'location': _address,
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Failed to save kitchen location. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.85,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.pin_drop, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Set Kitchen Map Pin',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tap the map or search address to place pin',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),

            // Search Bar & GPS Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search address or landmark...',
                          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                          prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                          suffixIcon: _isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                                )
                              : (_searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchResults = []);
                                      },
                                    )
                                  : null),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (val) {
                          _searchAddress(val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location, color: Colors.greenAccent, size: 20),
                      tooltip: 'Use My Current Location',
                      onPressed: _useCurrentGps,
                    ),
                  ),
                ],
              ),
            ),

            // Autocomplete Search Results Overlay
            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                constraints: const BoxConstraints(maxHeight: 160),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _searchResults.length,
                  separatorBuilder: (_, __) => const Divider(color: Colors.white10, height: 1),
                  itemBuilder: (context, idx) {
                    final item = _searchResults[idx];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                      title: Text(item['display_name'], style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                      onTap: () {
                        setState(() {
                          _selectedLocation = LatLng(item['lat'], item['lon']);
                          _address = item['display_name'];
                          _searchController.text = item['display_name'];
                          _searchResults.clear();
                        });
                        _safeMove(_selectedLocation, 15.0);
                      },
                    );
                  },
                ),
              ),

            // Interactive Map View
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation,
                        initialZoom: 14.5,
                        onMapReady: () {
                          _isMapReady = true;
                        },
                        onTap: (tapPosition, point) {
                          setState(() {
                            _selectedLocation = point;
                          });
                          _reverseGeocode(point);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                          subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                          userAgentPackageName: 'com.astroboomin.gochef',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation,
                              width: 80,
                              height: 80,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
                                      ],
                                    ),
                                    child: const Text(
                                      '🍳 Kitchen Pin',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const Icon(Icons.location_on, color: AppColors.primary, size: 36),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Quick help overlay at top
                    Positioned(
                      top: 10,
                      left: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '💡 Tap anywhere on the map to place your kitchen pin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Coordinates Display & Save Button Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.place, color: AppColors.primary, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _address,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Lat: ${_selectedLocation.latitude.toStringAsFixed(5)}, Lon: ${_selectedLocation.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Save Kitchen Location Pin',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
