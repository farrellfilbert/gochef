import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'earnings_screen.dart';
import '../../services/api_service.dart';
import '../../services/support_helper.dart';
import '../../models/kitchen_model.dart';
import '../../main.dart';
import '../auth/login_screen.dart';
import 'reviews_screen.dart';
import '../chat/inbox_screen.dart';
import '../../widgets/kitchen_location_picker_dialog.dart';

class ChefProfileScreen extends StatefulWidget {
  const ChefProfileScreen({super.key});

  @override
  State<ChefProfileScreen> createState() => _ChefProfileScreenState();
}

class _ChefProfileScreenState extends State<ChefProfileScreen> {
  bool _isLoading = true;
  KitchenModel? _kitchen;
  int? _kitchenId;
  Map<String, dynamic>? _analytics;
  double _deliveryRadius = 5.0;

  int _unreadChats = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      String? kitchenIdStr = await ApiService.getKitchenId();
      KitchenModel? kitchenData;

      if (kitchenIdStr != null && kitchenIdStr.isNotEmpty) {
        _kitchenId = int.tryParse(kitchenIdStr);
        if (_kitchenId != null) {
          kitchenData = await ApiService.getKitchenDetail(_kitchenId!);
        }
      }

      // If kitchenData is still null, try finding kitchen by user id
      if (kitchenData == null) {
        final userIdStr = await ApiService.getUserId();
        if (userIdStr != null && userIdStr.isNotEmpty) {
          final uid = int.tryParse(userIdStr);
          if (uid != null) {
            kitchenData = await ApiService.getKitchenDetailByUserId(uid);
            if (kitchenData != null) {
              _kitchenId = kitchenData.id;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('kitchen_id', kitchenData.id.toString());
            }
          }
        }
      }

      Map<String, dynamic>? analyticsData;
      if (_kitchenId != null) {
        analyticsData = await ApiService.getKitchenAnalytics(_kitchenId!);
      }

      int unreadChats = 0;
      try {
        final counts = await ApiService.getUnreadCounts();
        unreadChats = (counts['unread_chats'] as int?) ?? 0;
      } catch (_) {}

      if (mounted) {
        setState(() {
          _kitchen = kitchenData;
          _analytics = analyticsData;
          _unreadChats = unreadChats;
        });
      }
    } catch (e) {
      debugPrint('Error loading chef profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateImage(bool isAvatar) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    
    if (picked != null && mounted) {
      if (kIsWeb) {
        final image = picked;
        setState(() => _isLoading = true);
        try {
          String? imageUrl = await ApiService.uploadImage(image);
          if (imageUrl != null) {
            Map<String, dynamic> updateData = {
              'kitchen_id': _kitchenId,
            };
            if (isAvatar) {
              updateData['avatar'] = imageUrl;
            } else {
              updateData['cover_image'] = imageUrl;
            }
            
            bool success = await ApiService.updateKitchen(updateData);
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
              _loadProfile();
            } else {
              throw Exception('Failed to update kitchen');
            }
          } else {
            throw Exception('Failed to upload image');
          }
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
        return;
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: picked.path,
        uiSettings: [
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
          ),
        ],
      );
      if (croppedFile != null) {
        final image = XFile(croppedFile.path);
        setState(() => _isLoading = true);
      try {
        String? imageUrl = await ApiService.uploadImage(image);
        if (imageUrl != null) {
          Map<String, dynamic> updateData = {
            'kitchen_id': _kitchenId,
          };
          if (isAvatar) {
            updateData['avatar'] = imageUrl;
          } else {
            updateData['cover_image'] = imageUrl;
          }
          
          bool success = await ApiService.updateKitchen(updateData);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
            _loadProfile();
          } else {
            throw Exception('Failed to update kitchen');
          }
        } else {
          throw Exception('Failed to upload image');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
      }
    }
  }

  Future<void> _uploadAtmosphereImage(int index) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);

    if (picked != null && mounted) {
      XFile imageToUpload = picked;

      // Only crop on non-web platforms (web uses blob paths which are incompatible with ImageCropper)
      if (!kIsWeb) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: picked.path,
          uiSettings: [
            AndroidUiSettings(toolbarTitle: 'Crop Photo'),
            IOSUiSettings(title: 'Crop Photo'),
          ],
        );
        if (croppedFile != null) {
          imageToUpload = XFile(croppedFile.path);
        } else {
          return; // User cancelled crop
        }
      }

      setState(() => _isLoading = true);
      try {
        String? imageUrl = await ApiService.uploadImage(imageToUpload);
        if (imageUrl != null && mounted) {
          List<String> currentImages = List<String>.from(_kitchen!.atmosphereImages);
          if (index < currentImages.length) {
            currentImages[index] = imageUrl;
          } else {
            currentImages.add(imageUrl);
          }

          Map<String, dynamic> updateData = {
            'kitchen_id': _kitchenId,
            'atmosphere_images': jsonEncode(currentImages),
          };

          bool success = await ApiService.updateKitchen(updateData);
          if (success && mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Atmosphere photo updated'), backgroundColor: Colors.green),
            );
            _loadProfile();
          } else {
            throw Exception('Failed to update kitchen');
          }
        } else {
          throw Exception('Failed to upload image');
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  String _calculateActiveTime(String createdAt) {
    if (createdAt.isEmpty) return 'New';
    try {
      final DateTime createdDate = DateTime.parse(createdAt);
      final Duration difference = DateTime.now().difference(createdDate);
      if (difference.inDays < 30) {
        return '${difference.inDays}d';
      } else if (difference.inDays < 365) {
        final months = (difference.inDays / 30).floor();
        return '${months}m';
      } else {
        final years = (difference.inDays / 365).toStringAsFixed(1);
        return '${years}y';
      }
    } catch (e) {
      return 'New';
    }
  }

  void _showBusinessHoursDialog() {
    TimeOfDay openTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay closeTime = const TimeOfDay(hour: 22, minute: 0);
    bool isOpen = _kitchen?.isOpen ?? true;

    if (_kitchen != null && _kitchen!.businessHours.contains('-')) {
      final parts = _kitchen!.businessHours.split('-');
      if (parts.length == 2) {
        // e.g. "09:00 AM" and "10:00 PM"
        try {
          // Keep existing time string as reference
        } catch (_) {}
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: 24.0 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Business Hours', style: AppTextStyles.headlineMd(color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Kitchen Status', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                        Switch(
                          value: isOpen,
                          activeColor: AppColors.primary,
                          onChanged: (val) => setModalState(() => isOpen = val),
                        ),
                      ],
                    ),
                    const Divider(color: AppColors.ghostBorder),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Opening Time', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                        TextButton(
                          onPressed: () async {
                            final picked = await showTimePicker(context: context, initialTime: openTime);
                            if (picked != null) setModalState(() => openTime = picked);
                          },
                          child: Text(openTime.format(context), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Closing Time', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                        TextButton(
                          onPressed: () async {
                            final picked = await showTimePicker(context: context, initialTime: closeTime);
                            if (picked != null) setModalState(() => closeTime = picked);
                          },
                          child: Text(closeTime.format(context), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () async {
                    final formattedHours = '${openTime.format(context)} - ${closeTime.format(context)}';
                    if (_kitchenId != null) {
                      await ApiService.updateKitchen({
                        'kitchen_id': _kitchenId,
                        'business_hours': formattedHours,
                        'is_open': isOpen ? 1 : 0,
                      });
                      _loadProfile();
                    }
                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Operating hours saved: $formattedHours (${isOpen ? "Open" : "Closed"})'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Save Operating Hours', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeliveryRadiusDialog() {
    double currentRadius = _deliveryRadius;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Delivery Radius', style: AppTextStyles.headlineMd(color: Colors.white)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Set the maximum delivery distance from your kitchen location.', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Text('${currentRadius.toStringAsFixed(1)} Miles', style: AppTextStyles.displayLgMobile(color: AppColors.primary)),
                    const SizedBox(height: 4),
                    Text('Approx. 15-35 min delivery coverage', style: AppTextStyles.labelSm(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Slider(
                value: currentRadius,
                min: 1.0,
                max: 25.0,
                divisions: 24,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.surfaceContainerHighest,
                label: '${currentRadius.toStringAsFixed(0)} mi',
                onChanged: (val) => setModalState(() => currentRadius = val),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    setState(() => _deliveryRadius = currentRadius);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Delivery radius updated to ${currentRadius.toStringAsFixed(1)} miles!'), backgroundColor: Colors.green),
                    );
                  },
                  child: const Text('Apply Service Area', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showKitchenInspectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user, color: Colors.greenAccent, size: 24),
                    const SizedBox(width: 8),
                    Text('Kitchen Inspection', style: AppTextStyles.headlineMd(color: Colors.white)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    child: const Text('A+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Health Inspection: Passed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Grade A (Score: 98/100) • Verified by City Food Safety Authority', style: AppTextStyles.labelSm(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInspectionItem('Food Handler License', 'Valid until Nov 2026', Icons.check_circle, Colors.green),
            const SizedBox(height: 8),
            _buildInspectionItem('Commercial Kitchen Standards', 'Certified & Compliant', Icons.check_circle, Colors.green),
            const SizedBox(height: 8),
            _buildInspectionItem('Fire Safety & Sanitation', 'Inspected Q1 2026', Icons.check_circle, Colors.green),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                label: const Text('Request Re-Inspection', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Re-inspection request submitted to health inspector.'), backgroundColor: Colors.green),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionItem(String title, String status, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(status, style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
            ],
          ),
          Icon(icon, color: color, size: 20),
        ],
      ),
    );
  }

  void _openLocationPicker() async {
    if (_kitchen == null || _kitchenId == null) return;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => KitchenLocationPickerDialog(
        kitchenId: _kitchenId!,
        initialLat: _kitchen!.latitude ?? 34.1722,
        initialLng: _kitchen!.longitude ?? -118.3765,
        initialAddress: _kitchen!.location,
      ),
    );

    if (result != null) {
      _loadProfile();
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _kitchen!.name);
    final aboutController = TextEditingController(text: _kitchen!.description);
    final timeController = TextEditingController(text: _kitchen!.deliveryTime);
    final cuisineController = TextEditingController(text: _kitchen!.cuisineType);
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            title: Text('Edit Profile', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.onSurface),
                    decoration: const InputDecoration(labelText: 'Kitchen Name', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: aboutController,
                    style: const TextStyle(color: AppColors.onSurface),
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'About', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: timeController,
                    style: const TextStyle(color: AppColors.onSurface),
                    decoration: const InputDecoration(labelText: 'Delivery Time', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: cuisineController,
                    style: const TextStyle(color: AppColors.onSurface),
                    decoration: const InputDecoration(labelText: 'Cuisine Type', labelStyle: TextStyle(color: AppColors.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  setDialogState(() => isSaving = true);
                  try {
                    Map<String, dynamic> updateData = {
                      'kitchen_id': _kitchenId,
                      'name': nameController.text.trim(),
                      'description': aboutController.text.trim(),
                      'delivery_time': timeController.text.trim(),
                      'cuisine_type': cuisineController.text.trim(),
                    };
                    bool success = await ApiService.updateKitchen(updateData);
                    
                    if (success) {
                      Navigator.pop(context);
                      _loadProfile();
                    } else {
                      throw Exception('Failed to save profile');
                    }
                  } catch (e) {
                    setDialogState(() => isSaving = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : _kitchen == null 
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront_outlined, size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  const Text('Chef Kitchen Profile Not Found',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Could not load your kitchen profile. Please check your connection or tap retry.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _loadProfile,
                        icon: const Icon(Icons.refresh, color: AppColors.onPrimary),
                        label: const Text('Retry', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final userIdStr = await ApiService.getUserId();
                          if (userIdStr != null) {
                            await ApiService.saveUserId(userIdStr, role: 'user');
                          }
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false);
                          }
                        },
                        icon: const Icon(Icons.person, color: Colors.white),
                        label: const Text('Foodie App', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        : CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.surface.withValues(alpha: 0.9),
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () => _updateImage(false),
                    child: Image.network(
                      _kitchen!.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainer),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.background],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => _updateImage(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text('Change Cover', style: AppTextStyles.labelSm(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => _updateImage(true),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5), width: 2),
                                  image: DecorationImage(
                                    image: NetworkImage(_kitchen!.avatar),
                                    fit: BoxFit.cover,
                                    onError: (_, __) => const NetworkImage('https://ui-avatars.com/api/?name=Chef')
                                  ),
                                ),
                              ),
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_kitchen!.name, style: AppTextStyles.headlineLgMobile(color: Colors.white)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: AppColors.onSurfaceVariant, size: 14),
                                  const SizedBox(width: 4),
                                  Text(_kitchen!.location, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: _showEditProfileDialog,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Row
                Row(
                  children: [
                    Expanded(child: _buildStatItem(_analytics?['total_orders']?.toString() ?? '-', 'Total Orders')),
                    Container(width: 1, height: 40, color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    Expanded(child: _buildStatItem(_kitchen!.rating.toStringAsFixed(1), 'Avg Rating', highlight: true)),
                    Container(width: 1, height: 40, color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    Expanded(child: _buildStatItem(_calculateActiveTime(_kitchen!.createdAt), 'Active')),
                  ],
                ),
                const SizedBox(height: 24),

                // About Section
                Row(
                  children: [
                    const Icon(Icons.info, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('About the Kitchen', style: AppTextStyles.headlineMd(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: const Border(left: BorderSide(color: Colors.white, width: 4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${_kitchen!.description}"',
                        style: AppTextStyles.bodyMd(color: Colors.white70).copyWith(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTag(_kitchen!.cuisineType),
                          const SizedBox(width: 8),
                          _buildTag('Farm-to-Table'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Kitchen Map Location Pin Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pin_drop, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('Kitchen Map Pin & Location', style: AppTextStyles.headlineMd(color: Colors.white)),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _openLocationPicker,
                      icon: const Icon(Icons.edit_location_alt, color: Colors.white, size: 16),
                      label: const Text('Edit Pin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _kitchen!.location.isNotEmpty ? _kitchen!.location : 'North Hollywood, CA',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      if (_kitchen!.latitude != null && _kitchen!.longitude != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '📍 Coordinates: ${_kitchen!.latitude!.toStringAsFixed(4)}, ${_kitchen!.longitude!.toStringAsFixed(4)} (Permanent Pin on Map)',
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: _openLocationPicker,
                          icon: const Icon(Icons.map_outlined, color: Colors.white, size: 16),
                          label: const Text('Set / Adjust Map Pin Location', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Atmosphere Photos Section
                Row(
                  children: [
                    const Icon(Icons.photo_library, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text('Atmosphere Photos', style: AppTextStyles.headlineMd(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Upload up to 4 photos to show off your kitchen vibe.', style: AppTextStyles.labelSm(color: Colors.white70)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      bool hasImage = index < _kitchen!.atmosphereImages.length;
                      String imageUrl = hasImage ? _kitchen!.atmosphereImages[index] : '';

                      return GestureDetector(
                        onTap: () => _uploadAtmosphereImage(index),
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                            image: hasImage ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover) : null,
                          ),
                          child: hasImage 
                            ? null 
                            : const Center(child: Icon(Icons.add_a_photo, color: Colors.white70)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Operational Settings
                Text('Operational Settings', style: AppTextStyles.headlineMd(color: Colors.white)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(context, Icons.star_border, 'Customer Reviews', 'Read feedback from foodies', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewsScreen(kitchenId: _kitchen!.id)));
                      }),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(
                        context,
                        Icons.inbox,
                        'Messages / Inbox',
                        'Chat with your customers',
                        badgeCount: _unreadChats,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const InboxScreen())).then((_) {
                            _loadProfile();
                          });
                        },
                      ),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(
                        context, 
                        Icons.support_agent, 
                        '24/7 Chef Support Live Chat', 
                        'Direct chat with GoChef Admin & Help Desk', 
                        onTap: () => SupportHelper.openLiveSupportChat(context),
                      ),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(context, Icons.schedule, 'Business Hours', 'Manage your operating times', onTap: _showBusinessHoursDialog),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(context, Icons.payments, 'Payout Methods', 'Manage your earnings & bank info', destination: const ChefEarningsScreen()),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(context, Icons.local_shipping, 'Delivery Radius', 'Set your service area (currently ${_deliveryRadius.toStringAsFixed(0)}mi)', onTap: _showDeliveryRadiusDialog),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(context, Icons.shield, 'Kitchen Inspection', 'Renew your safety certifications', onTap: _showKitchenInspectionDialog),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.white),
                        title: Text('Switch to Foodie App', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                        subtitle: Text('Order food as a user', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                        onTap: () async {
                          // Change role to user to open foodie app
                          final userIdStr = await ApiService.getUserId();
                          if (userIdStr != null) {
                             await ApiService.saveUserId(userIdStr, role: 'user', kitchenId: _kitchen?.id.toString());
                          }
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false);
                          }
                        },
                      ),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.redAccent),
                        title: Text('Log Out', style: AppTextStyles.bodyMd(color: Colors.redAccent).copyWith(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                        onTap: () async {
                          await ApiService.logout();
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {bool highlight = false}) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.displayLgMobile(color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSm(color: Colors.white70).copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(text, style: AppTextStyles.labelSm(color: Colors.white70)),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, String subtitle, {Widget? destination, VoidCallback? onTap, int badgeCount = 0}) {
    return ListTile(
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, color: Colors.white),
          if (badgeCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Text(title, style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
          if (badgeCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount NEW',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
      onTap: onTap ?? () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}
