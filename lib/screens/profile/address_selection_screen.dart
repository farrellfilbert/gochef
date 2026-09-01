import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/address_model.dart';
import '../../services/api_service.dart';

class AddressSelectionScreen extends StatefulWidget {
  final bool isSelectionMode;
  final AddressModel? currentAddress;

  const AddressSelectionScreen({
    super.key,
    this.isSelectionMode = true,
    this.currentAddress,
  });

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  List<AddressModel> _addresses = [];
  bool _isLoading = true;
  AddressModel? _selectedAddress;

  // Base location (defaults to Jakarta, updated by GPS)
  LatLng _baseLocation = const LatLng(-6.200000, 106.816666);
  bool _hasRealLocation = false;
  bool _isMapReady = false;

  void _safeMove(LatLng target, double zoom) {
    if (_isMapReady) {
      try {
        _mapController.move(target, zoom);
      } catch (e) {
        debugPrint('Address selection map move ignored: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.currentAddress;
    _initData();
  }

  Future<void> _initData() async {
    await _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      final addresses = await ApiService.getAddresses();
      setState(() {
        _addresses = addresses;
        if (_selectedAddress == null && addresses.isNotEmpty) {
          _selectedAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
        }
      });
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onAddressSelected(AddressModel address) {
    if (widget.isSelectionMode) {
      Navigator.pop(context, address);
    } else {
      setState(() {
        _selectedAddress = address;
      });
    }
  }

  void _addNewAddress({LatLng? latLng}) {
    final labelController = TextEditingController(text: latLng != null ? 'Pinpoint Location' : '');
    final addressController = TextEditingController(
      text: latLng != null ? 'Location (${latLng.latitude.toStringAsFixed(5)}, ${latLng.longitude.toStringAsFixed(5)})' : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add New Address', style: AppTextStyles.headlineMd(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: 'Label (e.g., Home, Office)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Full Address',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (addressController.text.isNotEmpty) {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  final success = await ApiService.addAddress(
                    addressController.text,
                    label: labelController.text.isEmpty ? 'Home' : labelController.text,
                    isDefault: _addresses.isEmpty,
                  );
                  if (success) {
                    await _loadAddresses();
                    if (widget.isSelectionMode && _addresses.isNotEmpty) {
                      final added = _addresses.firstWhere((a) => a.address == addressController.text, orElse: () => _addresses.first);
                      if (mounted) Navigator.pop(context, added);
                    }
                  } else {
                    setState(() => _isLoading = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _editAddress(AddressModel address) {
    final labelController = TextEditingController(text: address.label);
    final addressController = TextEditingController(text: address.address);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit Address', style: AppTextStyles.headlineMd(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: 'Label (e.g., Home, Office)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Full Address',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (addressController.text.isNotEmpty) {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  final success = await ApiService.updateAddress(
                    address.id,
                    addressController.text,
                    labelController.text.isEmpty ? 'Home' : labelController.text,
                  );
                  if (success) {
                    await _loadAddresses();
                    if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat berhasil diupdate', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                    }
                  } else {
                    setState(() => _isLoading = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=5');
      final response = await http.get(url, headers: {'User-Agent': 'GoChefApp'});
      
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (data.isNotEmpty) {
          if (mounted) {
            showModalBottomSheet(
              context: context,
              backgroundColor: AppColors.surface,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
              builder: (context) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Pilih Hasil Pencarian', style: AppTextStyles.headlineMd(color: Colors.white)),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          return ListTile(
                            leading: const Icon(Icons.location_on, color: Colors.white70),
                            title: Text(item['display_name'] ?? '', style: const TextStyle(color: Colors.white)),
                            onTap: () {
                              Navigator.pop(context);
                              final lat = double.parse(item['lat'].toString());
                              final lon = double.parse(item['lon'].toString());
                              final newPos = LatLng(lat, lon);
                              setState(() {
                                _baseLocation = newPos;
                              });
                              _safeMove(newPos, 15.0);
                              _addNewAddress(latLng: newPos);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lokasi tidak ditemukan', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mencari lokasi', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari lokasi',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                onPressed: () {
                  _searchLocation(_searchController.text);
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(color: Colors.white),
            onSubmitted: (val) {
              _searchLocation(val);
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt, color: Colors.white),
            onPressed: () => _addNewAddress(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                // Warning Banner
                Container(
                  color: const Color(0xFF3A3520),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active, color: Color(0xFFFFD54F), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap anywhere on the map or select from your saved addresses below to set your delivery location.',
                          style: AppTextStyles.labelSm(color: const Color(0xFFFFD54F)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Map Container (Tap to choose location)
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _baseLocation,
                          initialZoom: 15.0,
                          onMapReady: () {
                            _isMapReady = true;
                          },
                          onTap: (tapPosition, point) {
                            setState(() {
                              _baseLocation = point;
                            });
                            _addNewAddress(latLng: point);
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
                              Marker(
                                point: _baseLocation,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Tap map to pinpoint', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Deliver To
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
                    border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Deliver To: ', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    _selectedAddress?.label ?? 'Select Location',
                                    style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedAddress?.address ?? 'Set your delivery location',
                              style: AppTextStyles.labelSm(color: Colors.white70),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          _addNewAddress();
                        },
                        icon: const Icon(Icons.my_location, size: 16, color: Colors.white),
                        label: Text('Use Pin', style: AppTextStyles.labelSm(color: Colors.white)),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),

                // Saved Addresses
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('My Addresses', style: AppTextStyles.headlineMd(color: Colors.white)),
                              TextButton.icon(
                                onPressed: _addNewAddress,
                                icon: const Icon(Icons.add_circle, color: Colors.white, size: 18),
                                label: Text('Add New Address', style: AppTextStyles.labelSm(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _addresses.length,
                            separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                            itemBuilder: (context, index) {
                              final address = _addresses[index];
                              final isSelected = _selectedAddress?.id == address.id;
                              
                              return InkWell(
                                onTap: () => _onAddressSelected(address),
                                child: Container(
                                  color: isSelected ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Distance placeholder
                                      Column(
                                        children: [
                                          Icon(
                                            isSelected ? Icons.bookmark : Icons.bookmark_border,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${(1.5 + index * 0.9).toStringAsFixed(1)} mi', 
                                            style: AppTextStyles.labelSm(color: Colors.white70)
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    address.label,
                                                    style: AppTextStyles.bodyMd(color: Colors.white)
                                                        .copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(color: Colors.white24),
                                                    ),
                                                    child: const Text(
                                                      'Last Used',
                                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              address.address,
                                              style: AppTextStyles.labelSm(color: Colors.white70),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'User Name | (+62) 812-3456-7890',
                                              style: AppTextStyles.labelSm(color: Colors.white60),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.white70, size: 18),
                                        onPressed: () {
                                          _editAddress(address);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
}
