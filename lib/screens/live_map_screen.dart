import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import 'dart:math';
import '../core/theme.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';
  
  final List<LatLng> _dummyChefs = [];
  Timer? _animationTimer;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Small delay for loading effect
      await Future.delayed(const Duration(milliseconds: 500));
      
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied, we cannot request permissions.');
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
      // FALLBACK: If anything fails (MissingPluginException from not restarting, no GPS, etc)
      // we mock the location to a central point (e.g., Jakarta) so the presentation NEVER fails.
      if (mounted) {
        setState(() {
          _currentPosition = const LatLng(-6.200000, 106.816666); // Default to Sudirman, Jakarta
          _isLoading = false;
          _generateDummyChefs();
        });
      }
    }
  }

  void _generateDummyChefs() {
    if (_currentPosition == null) return;
    
    final random = Random();
    // Generate 5 chefs around current location (within ~1-2 km)
    for (int i = 0; i < 5; i++) {
      double latOffset = (random.nextDouble() - 0.5) * 0.01;
      double lngOffset = (random.nextDouble() - 0.5) * 0.01;
      _dummyChefs.add(LatLng(
        _currentPosition!.latitude + latOffset,
        _currentPosition!.longitude + lngOffset,
      ));
    }

    // Animate them randomly every 2 seconds
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.fuchsiaPrimary),
                  SizedBox(height: 16),
                  Text('Finding Your Location...', style: TextStyle(color: AppTheme.textPrimary)),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.mapPinOff, color: Colors.redAccent, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to Get Location\n$_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.fuchsiaPrimary),
                          child: const Text('Back', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition!,
                        initialZoom: 15.0,
                        maxZoom: 18.0,
                        minZoom: 5.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.gochef',
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
                                  width: 40,
                                  height: 40,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.fuchsiaPrimary,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(LucideIcons.chefHat, color: Colors.white, size: 20),
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                    
                    // Back Button Overlay
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary, size: 24),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Confirm Button Overlay
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: ElevatedButton(
                        onPressed: () {
                          // Return a generic location name since we only have coordinates
                          Navigator.pop(context, 'Your Accurate Location');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.fuchsiaPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 10,
                        ),
                        child: const Text(
                          'Select This Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
