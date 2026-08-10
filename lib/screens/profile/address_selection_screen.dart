import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:html' as html;
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
    // Try to get real-time location first
    if (html.window.navigator.geolocation != null) {
      try {
        final position = await html.window.navigator.geolocation.getCurrentPosition();
        final lat = position.coords?.latitude?.toDouble();
        final lon = position.coords?.longitude?.toDouble();
        if (lat != null && lon != null) {
          _baseLocation = LatLng(lat, lon);
          _hasRealLocation = true;
        }
      } catch (e) {
        // Fallback to default
      }
    }
    
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

  void _addNewAddress() {
    final labelController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Add New Address', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label (e.g., Home, Office)'),
                style: const TextStyle(color: AppColors.onSurface),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Full Address'),
                maxLines: 3,
                style: const TextStyle(color: AppColors.onSurface),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
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
                  } else {
                    setState(() => _isLoading = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save'),
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
        iconTheme: const IconThemeData(color: AppColors.onSurface),
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
            style: const TextStyle(color: AppColors.onSurface),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: AppColors.primary),
            onPressed: () {},
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
                          'Please verify your pin location. We will deliver your order to the pinned location.',
                          style: AppTextStyles.labelSm(color: const Color(0xFFFFD54F)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Map Container
                SizedBox(
                  height: 180,
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _baseLocation,
                      initialZoom: 15.0,
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
                                Text('Deliver To: ', style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    _selectedAddress?.label ?? 'Select Location',
                                    style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedAddress?.address ?? 'Set your delivery location',
                              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.my_location, size: 16, color: AppColors.primary),
                        label: Text('Current Location', style: AppTextStyles.labelSm(color: AppColors.primary)),
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
                                            '${(2.5 + index * 1.5).toStringAsFixed(1)}km', 
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
