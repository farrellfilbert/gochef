import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../models/user_model.dart';
import '../models/address_model.dart';
import '../screens/map_screen.dart';

class CustomAppBarTitle extends StatefulWidget {
  final String subtitle;
  final bool isChefMode;

  const CustomAppBarTitle({
    super.key,
    this.subtitle = '',
    this.isChefMode = false,
  });

  @override
  State<CustomAppBarTitle> createState() => _CustomAppBarTitleState();
}

class _CustomAppBarTitleState extends State<CustomAppBarTitle> {
  String _deviceLocation = '';
  String _dbLocation = 'Please set your address';
  String _name = 'GoChef';
  String _avatarUrl = 'https://ui-avatars.com/api/?name=User';

  @override
  void initState() {
    super.initState();
    if (widget.isChefMode) {
      _fetchKitchenProfile();
    } else {
      _fetchProfile();
    }
    _fetchAddresses();
    _fetchDeviceLocation();
  }

  void _fetchKitchenProfile() async {
    try {
      final kitchenIdStr = await ApiService.getKitchenId();
      if (kitchenIdStr != null) {
        final kitchenId = int.tryParse(kitchenIdStr);
        if (kitchenId != null) {
          final kitchen = await ApiService.getKitchenDetail(kitchenId);
          if (mounted && kitchen != null) {
            setState(() {
              if (kitchen.name.isNotEmpty) _name = kitchen.name;
              if (kitchen.avatar.isNotEmpty) _avatarUrl = kitchen.avatar;
            });
            return;
          }
        }
      }
      _fetchProfile();
    } catch (e) {
      _fetchProfile();
    }
  }

  void _fetchProfile() async {
    try {
      final profile = await ApiService.getProfile();
      if (mounted) {
        setState(() {
          if (profile.name.isNotEmpty) _name = profile.name;
          if (profile.avatar.isNotEmpty) _avatarUrl = profile.avatar;
        });
      }
    } catch (e) {
      // Fallback to default
    }
  }

  void _fetchAddresses() async {
    try {
      final addresses = await ApiService.getAddresses();
      if (mounted) {
        if (addresses.isNotEmpty) {
          final defaultAddress = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
          setState(() {
            _dbLocation = defaultAddress.address;
          });
        } else {
          setState(() {
            _dbLocation = 'Please set your address';
          });
        }
      }
    } catch (e) {
      // Fallback
    }
  }

  void _fetchDeviceLocation() async {
    try {
      final cached = await LocationService.getLastKnownAddress();
      if (cached != null && cached.isNotEmpty && mounted) {
        setState(() => _deviceLocation = cached);
      }

      final loc = await LocationService.getCurrentLocation();
      if (loc?.address != null && mounted) {
        setState(() => _deviceLocation = loc!.address!);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    String location = _dbLocation;
    
    // Override location with real device location if available
    if (_deviceLocation.isNotEmpty) {
      location = _deviceLocation;
    }
    

    if (location.length > 25) {
      location = '${location.substring(0, 25)}...';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MapScreen()));
      },
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              image: DecorationImage(
                image: NetworkImage(_avatarUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_name, style: AppTextStyles.headlineLgMobile(color: Colors.white).copyWith(fontSize: 20)),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    widget.subtitle.isNotEmpty ? widget.subtitle : location,
                    style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 14),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
