import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
  List<AddressModel> _addresses = [];
  bool _isLoading = true;
  AddressModel? _selectedAddress;

  // Base location (defaults to Jakarta, updated by GPS)
  LatLng _baseLocation = const LatLng(-6.200000, 106.816666);
  bool _hasRealLocation = false;

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
            decoration: InputDecoration(
              hintText: 'Search location',
              hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            style: const TextStyle(color: Colors.white),
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
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
                                  color: AppColors.primary,
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
                      const Icon(Icons.location_on, color: AppColors.primary),
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
                              Text('My Addresses', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                              TextButton.icon(
                                onPressed: _addNewAddress,
                                icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 18),
                                label: Text('Add New Address', style: AppTextStyles.labelSm(color: AppColors.primary)),
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
                                  color: isSelected ? AppColors.primaryContainer.withValues(alpha: 0.1) : Colors.transparent,
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Distance placeholder
                                      Column(
                                        children: [
                                          Icon(
                                            isSelected ? Icons.bookmark : Icons.bookmark_border,
                                            color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                                            size: 20,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${(1.5 + index * 0.9).toStringAsFixed(1)} mi', 
                                            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)
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
                                                    style: AppTextStyles.bodyMd(color: AppColors.onSurface)
                                                        .copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                                if (isSelected)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: const Text(
                                                      'Last Used',
                                                      style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              address.address,
                                              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'User Name | (+62) 812-3456-7890',
                                              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: AppColors.onSurfaceVariant, size: 20),
                                        onPressed: () {
                                          // Edit functionality
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
