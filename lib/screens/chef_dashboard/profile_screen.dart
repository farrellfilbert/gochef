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
import '../../utils/kitchen_compliance.dart';

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

  TimeOfDay? _parseTimeString(String rawTime) {
    try {
      final clean = rawTime.trim().toUpperCase();
      final isPM = clean.contains('PM');
      final isAM = clean.contains('AM');
      final timeOnly = clean.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = timeOnly.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0].trim());
        int minute = int.parse(parts[1].trim());
        if (isPM && hour < 12) hour += 12;
        if (isAM && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _toggleKitchenStatus(bool newStatus) async {
    if (_kitchenId == null) return;
    setState(() {
      if (_kitchen != null) {
        _kitchen = _kitchen!.copyWith(isOpen: newStatus);
      }
    });
    final success = await ApiService.updateKitchen({
      'kitchen_id': _kitchenId,
      'is_open': newStatus ? 1 : 0,
    });
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                newStatus ? Icons.check_circle : Icons.pause_circle_outline,
                color: newStatus ? const Color(0xFF10B981) : Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  newStatus ? 'Kitchen is now OPEN and accepting orders!' : 'Kitchen is now CLOSED / PAUSED',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1E232E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      _loadProfile();
    }
  }

  void _showBusinessHoursDialog() {
    TimeOfDay openTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay closeTime = const TimeOfDay(hour: 22, minute: 0);
    bool isOpen = _kitchen?.isOpen ?? true;

    if (_kitchen != null && _kitchen!.businessHours.contains('-')) {
      final parts = _kitchen!.businessHours.split('-');
      if (parts.length == 2) {
        final parsedOpen = _parseTimeString(parts[0]);
        final parsedClose = _parseTimeString(parts[1]);
        if (parsedOpen != null) openTime = parsedOpen;
        if (parsedClose != null) closeTime = parsedClose;
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Business Hours', style: AppTextStyles.headlineMd(color: Colors.white)),
                      const Text(
                        'Pacific Standard Time (PST)',
                        style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
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
                          activeThumbColor: AppColors.primary,
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
                    final formattedHours = '${openTime.format(context)} - ${closeTime.format(context)} PST';
                    if (_kitchenId != null) {
                      setState(() {
                        if (_kitchen != null) {
                          _kitchen = KitchenModel(
                            id: _kitchen!.id,
                            userId: _kitchen!.userId,
                            name: _kitchen!.name,
                            chefName: _kitchen!.chefName,
                            description: _kitchen!.description,
                            avatar: _kitchen!.avatar,
                            coverImage: _kitchen!.coverImage,
                            rating: _kitchen!.rating,
                            totalReviews: _kitchen!.totalReviews,
                            cuisineType: _kitchen!.cuisineType,
                            deliveryTime: _kitchen!.deliveryTime,
                            businessHours: formattedHours,
                            isOpen: isOpen,
                            location: _kitchen!.location,
                            latitude: _kitchen!.latitude,
                            longitude: _kitchen!.longitude,
                            isVerified: _kitchen!.isVerified,
                            isFeatured: _kitchen!.isFeatured,
                            createdAt: _kitchen!.createdAt,
                            atmosphereImages: _kitchen!.atmosphereImages,
                            certificates: _kitchen!.certificates,
                            menuItems: _kitchen!.menuItems,
                            reviews: _kitchen!.reviews,
                            hasPurchased: _kitchen!.hasPurchased,
                          );
                        }
                      });
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

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: AppColors.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
      }
    }
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
    final items = _kitchen != null ? KitchenComplianceHelper.getComplianceItems(_kitchen!) : <KitchenComplianceItem>[];
    final verifiedCount = _kitchen != null ? KitchenComplianceHelper.countSubmitted(_kitchen!) : 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user, color: Colors.greenAccent, size: 24),
                      const SizedBox(width: 8),
                      Text('Kitchen Inspection & Permits', style: AppTextStyles.headlineMd(color: Colors.white)),
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
                          Text('Grade A (Score: 98/100) • $verifiedCount/10 Credentials Verified', style: AppTextStyles.labelSm(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Action Buttons Row (Upload New Document + Request Re-Inspection)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.upload_file, size: 18),
                      label: const Text('Upload Document', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () {
                        Navigator.pop(context);
                        _showUploadDocumentModal();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Re-Inspection', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Re-inspection request submitted to health inspector.'), backgroundColor: Colors.green),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Visible Verification Checklist (Foodies see this)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.isSubmitted ? Colors.greenAccent.withValues(alpha: 0.3) : Colors.white10,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(item.icon, color: item.isSubmitted ? Colors.greenAccent : Colors.white38, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                                const SizedBox(height: 2),
                                Text(item.description, style: const TextStyle(color: Colors.white60, fontSize: 11.5)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item.isSubmitted)
                            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20)
                          else
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _showUploadDocumentModal(item.title);
                              },
                              child: const Text('Upload', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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

  void _showUploadDocumentModal([String? initialType]) {
    final List<String> docTypes = [
      'MEHKO Permit',
      'Safe Serv Certification',
      'Health Permit',
      'Cottage Food Permit',
      'Business License (Biz License)',
      'Insurance Certificate',
      'Latest Inspection Report',
      'Commissioners Agreement',
      'Kitchen Verified Document',
      'Other Credential',
    ];

    String selectedType = initialType ?? docTypes.first;
    if (!docTypes.contains(selectedType)) {
      final match = docTypes.firstWhere(
        (t) => t.toLowerCase().contains(selectedType.toLowerCase()),
        orElse: () => docTypes.first,
      );
      selectedType = match;
    }

    final titleController = TextEditingController(text: selectedType);
    XFile? pickedDocument;
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.upload_file, color: Colors.greenAccent, size: 22),
                      const SizedBox(width: 8),
                      Text('Upload Credential / Document', style: AppTextStyles.headlineMd(color: Colors.white)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Submit documents to earn your verified green dot on your profile.',
                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),

              // Dropdown
              const Text('Document Type', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                dropdownColor: AppColors.surfaceContainerHigh,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: docTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setModalState(() {
                      selectedType = val;
                      titleController.text = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Custom Title
              const Text('Document Name / Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  hintText: 'e.g. Los Angeles County MEHKO #12345',
                  hintStyle: const TextStyle(color: Colors.white38),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // File / Photo Picker
              const Text('Photo / Document Scan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setModalState(() => pickedDocument = picked);
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: pickedDocument != null ? Colors.greenAccent : Colors.white24,
                      width: pickedDocument != null ? 2 : 1,
                    ),
                  ),
                  child: pickedDocument != null
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: kIsWeb
                                  ? Image.network(pickedDocument!.path, fit: BoxFit.cover, width: double.infinity, height: 120)
                                  : Image.file(File(pickedDocument!.path), fit: BoxFit.cover, width: double.infinity, height: 120),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(16)),
                              child: const Text('Tap to Change Photo', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined, color: Colors.white70, size: 36),
                            const SizedBox(height: 6),
                            const Text('Select Certificate Photo or Document Scan', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text('Supports JPG, PNG (Max 10MB)', style: AppTextStyles.labelSm(color: Colors.white38)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Upload Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: isUploading
                      ? null
                      : () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a document title')),
                            );
                            return;
                          }
                          if (pickedDocument == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please select a photo or document scan to upload')),
                            );
                            return;
                          }

                          setModalState(() => isUploading = true);
                          try {
                            String? uploadedUrl = await ApiService.uploadImage(pickedDocument!);
                            if (uploadedUrl == null || uploadedUrl.isEmpty) {
                              throw Exception('Failed to upload document image.');
                            }

                            final newCert = {
                              'title': titleController.text.trim(),
                              'type': selectedType,
                              'url': uploadedUrl,
                              'issue_date': DateTime.now().toString().substring(0, 10),
                            };

                            List<Map<String, dynamic>> updatedList = [];
                            if (_kitchen != null) {
                              for (var c in _kitchen!.certificates) {
                                updatedList.add(c.toJson());
                              }
                            }
                            updatedList.add(newCert);

                            final success = await ApiService.updateKitchen({
                              'kitchen_id': _kitchenId,
                              'certificates': jsonEncode(updatedList),
                            });

                            if (success) {
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${titleController.text.trim()} uploaded! Green dot verification updated.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _loadProfile();
                              }
                            } else {
                              throw Exception('Server rejected kitchen update.');
                            }
                          } catch (e) {
                            setModalState(() => isUploading = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Upload failed: $e')),
                              );
                            }
                          }
                        },
                  child: isUploading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit & Upload Document', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteDocument(ChefCertificate cert) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Document?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "${cert.title}"? Your green dot verification for this document will be removed.', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        List<Map<String, dynamic>> updatedList = [];
        for (var c in _kitchen!.certificates) {
          if (c.title != cert.title || c.url != cert.url) {
            updatedList.add(c.toJson());
          }
        }

        await ApiService.updateKitchen({
          'kitchen_id': _kitchenId,
          'certificates': jsonEncode(updatedList),
        });
        _loadProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Document deleted.'), backgroundColor: Colors.orange),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  void _viewDocumentImage(String url, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.9), blurRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      child: Image.network(
                        url,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Colors.black26,
                          child: const Center(child: Text('Document image not available', style: TextStyle(color: Colors.white54))),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text('Verified by GoChef Compliance Team', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChefComplianceRow(KitchenComplianceItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: item.isSubmitted
            ? Colors.greenAccent.withValues(alpha: 0.05)
            : AppColors.surfaceContainerLowest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.isSubmitted
              ? Colors.greenAccent.withValues(alpha: 0.3)
              : Colors.white12,
        ),
      ),
      child: Row(
        children: [
          // Icon with Dot Indicator
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.isSubmitted
                      ? Colors.greenAccent.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.isSubmitted ? Colors.greenAccent : Colors.white38,
                  size: 20,
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: item.isSubmitted ? Colors.greenAccent : Colors.grey.shade600,
                    shape: BoxShape.circle,
                    boxShadow: item.isSubmitted
                        ? [
                            BoxShadow(
                              color: Colors.greenAccent.withValues(alpha: 0.9),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Title & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: item.isSubmitted ? Colors.greenAccent : Colors.grey.shade500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.isSubmitted ? item.statusText : 'Not Submitted (Action Required)',
                        style: TextStyle(
                          color: item.isSubmitted ? Colors.greenAccent : Colors.white54,
                          fontSize: 11,
                          fontWeight: item.isSubmitted ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          if (item.isSubmitted) ...[
            if (item.documentUrl != null && item.documentUrl!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 20),
                tooltip: 'View Document',
                onPressed: () => _viewDocumentImage(item.documentUrl!, item.title),
              ),
            if (item.certificate != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                tooltip: 'Delete Document',
                onPressed: () => _confirmDeleteDocument(item.certificate!),
              ),
          ] else ...[
            TextButton.icon(
              onPressed: () {
                if (item.id == 'kitchen_photos') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please upload at least 3 photos in the Atmosphere Photos section above.')),
                  );
                } else {
                  _showUploadDocumentModal(item.title);
                }
              },
              icon: const Icon(Icons.add, size: 14, color: AppColors.primary),
              label: const Text('Upload', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
            ),
          ],
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

  void _showEditAboutDialog() {
    final controller = TextEditingController(text: _kitchen?.description ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: const [
                Icon(Icons.edit_note, color: Colors.white),
                SizedBox(width: 8),
                Text('Edit About The Kitchen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tell foodie customers about your kitchen, cooking background, specialty meals, and passion.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g. Authentic homemade culinary creations crafted with love...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final newAbout = controller.text.trim();
                        setDialogState(() => isSaving = true);
                        try {
                          final success = await ApiService.updateKitchen({
                            'kitchen_id': _kitchenId,
                            'description': newAbout,
                          });
                          if (success && mounted) {
                            setState(() {
                              if (_kitchen != null) {
                                _kitchen = _kitchen!.copyWith(description: newAbout);
                              }
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('About The Kitchen updated successfully! 🎉'), backgroundColor: Colors.green),
                            );
                          } else {
                            throw Exception('Failed to update kitchen description');
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEarningsCard() {
    final revenue = double.tryParse(_analytics?['revenue']?.toString() ?? '0') ?? 0.0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E293B),
            AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.greenAccent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'KITCHEN EARNINGS',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Live', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${revenue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total made from completed orders',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChefEarningsScreen(initialKitchen: _kitchen),
                    ),
                  ).then((_) => _loadProfile());
                },
                icon: const Icon(Icons.payments_outlined, size: 16, color: Colors.black),
                label: const Text(
                  'Withdraw Money',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
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
                              ),
                              if (_kitchen!.certificates.isNotEmpty || _kitchen!.isVerified)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.greenAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.surface, width: 2.5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.greenAccent.withValues(alpha: 0.9),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        )
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.check, size: 11, color: Colors.black),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(_kitchen!.name, style: AppTextStyles.headlineLgMobile(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  if (_kitchen!.certificates.isNotEmpty || _kitchen!.isVerified) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.9), blurRadius: 4),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Verified',
                                            style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
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
                const SizedBox(height: 20),

                // Kitchen Earnings & Payout Card
                _buildEarningsCard(),
                const SizedBox(height: 24),

                // About Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('About the Kitchen', style: AppTextStyles.headlineMd(color: Colors.white)),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: _showEditAboutDialog,
                      icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                      label: const Text('Edit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
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

                // Documents & Credentials Section (Green Dot Uploads & Compliance)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user, color: Colors.greenAccent, size: 20),
                        const SizedBox(width: 8),
                        Text('Documents & Credentials', style: AppTextStyles.headlineMd(color: Colors.white)),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showUploadDocumentModal(),
                      icon: const Icon(Icons.upload_file, size: 16, color: Colors.white),
                      label: const Text('Upload', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.greenAccent.withValues(alpha: 0.9), blurRadius: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${KitchenComplianceHelper.countSubmitted(_kitchen!)}/10 Verified • Green dot indicates provided credentials',
                      style: AppTextStyles.labelSm(color: Colors.greenAccent).copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    children: KitchenComplianceHelper.getComplianceItems(_kitchen!).map((item) {
                      return _buildChefComplianceRow(item);
                    }).toList(),
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
                      ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (_kitchen?.isOpen == true ? const Color(0xFF10B981) : Colors.redAccent).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _kitchen?.isOpen == true ? Icons.storefront : Icons.storefront_outlined,
                            color: _kitchen?.isOpen == true ? const Color(0xFF10B981) : Colors.redAccent,
                            size: 20,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text('Store Open / Closed', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (_kitchen?.isOpen == true ? const Color(0xFF10B981) : Colors.redAccent).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _kitchen?.isOpen == true ? const Color(0xFF10B981) : Colors.redAccent, width: 1),
                              ),
                              child: Text(
                                _kitchen?.isOpen == true ? 'OPEN' : 'CLOSED',
                                style: TextStyle(
                                  color: _kitchen?.isOpen == true ? const Color(0xFF10B981) : Colors.redAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          _kitchen?.isOpen == true 
                            ? 'Currently open & accepting orders. Tap switch to close.'
                            : 'Currently closed. Tap switch to open & accept orders anytime.',
                          style: AppTextStyles.labelSm(color: Colors.white54),
                        ),
                        trailing: Switch(
                          value: _kitchen?.isOpen == true,
                          activeThumbColor: const Color(0xFF10B981),
                          onChanged: _toggleKitchenStatus,
                        ),
                      ),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(context, Icons.schedule, 'Business Hours', 'Pacific Standard Time (PST)', onTap: _showBusinessHoursDialog),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(context, Icons.payments, 'Payout Method & Earnings', 'Withdraw money & manage bank direct deposit', destination: ChefEarningsScreen(initialKitchen: _kitchen)),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(context, Icons.local_shipping, 'Delivery Radius', 'Set your service area (currently ${_deliveryRadius.toStringAsFixed(0)}mi)', onTap: _showDeliveryRadiusDialog),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(context, Icons.shield, 'Kitchen Inspection & Permits', 'Upload documents & view verification details (${KitchenComplianceHelper.countSubmitted(_kitchen!)}/10 verified)', onTap: _showKitchenInspectionDialog),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      ListTile(
                        leading: const Icon(Icons.person, color: Colors.white),
                        title: Text('Switch to Foodie Mode', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.white60),
                        onTap: () async {
                          final currentUserId = _kitchen?.userId != 0 ? _kitchen!.userId : (await ApiService.getUserId() ?? 1);
                          await ApiService.saveUserId(currentUserId.toString(), role: 'foodie', kitchenId: _kitchen?.id.toString());
                          if (mounted) {
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Separate card for Logout to prevent accidental tapping
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: Text('Log Out', style: AppTextStyles.bodyMd(color: AppColors.error).copyWith(fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white60),
                    onTap: _confirmLogout,
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
                '$badgeCount',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(subtitle, style: AppTextStyles.labelSm(color: Colors.white70)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white60),
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}
