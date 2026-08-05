import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'earnings_screen.dart';
import '../../services/api_service.dart';
import '../../models/kitchen_model.dart';

class ChefProfileScreen extends StatefulWidget {
  const ChefProfileScreen({super.key});

  @override
  State<ChefProfileScreen> createState() => _ChefProfileScreenState();
}

class _ChefProfileScreenState extends State<ChefProfileScreen> {
  bool _isLoading = true;
  KitchenModel? _kitchen;
  final int _kitchenId = 1; // Assuming 1 for demo purposes

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final kitchenData = await ApiService.getKitchenDetail(_kitchenId);
      setState(() {
        _kitchen = kitchenData;
      });
    } catch (e) {
      debugPrint('Error loading chef profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateImage(bool isAvatar) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null && mounted) {
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

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _kitchen!.name);
    final aboutController = TextEditingController(text: _kitchen!.description);
    final timeController = TextEditingController(text: _kitchen!.deliveryTime);
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
                    bool success = await ApiService.updateKitchen({
                      'kitchen_id': _kitchenId,
                      'name': nameController.text,
                      'description': aboutController.text,
                      'deliveryTime': timeController.text,
                    });
                    
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
        ? const Center(child: Text('Failed to load profile', style: TextStyle(color: Colors.white)))
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
                    Expanded(child: _buildStatItem('2.4k', 'Total Orders')),
                    Container(width: 1, height: 40, color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    Expanded(child: _buildStatItem(_kitchen!.rating.toStringAsFixed(1), 'Avg Rating', highlight: true)),
                    Container(width: 1, height: 40, color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    Expanded(child: _buildStatItem('3.5', 'Years Active')),
                  ],
                ),
                const SizedBox(height: 24),

                // About Section
                Row(
                  children: [
                    const Icon(Icons.info, color: AppColors.primary, size: 20),
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
                    border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${_kitchen!.description}"',
                        style: AppTextStyles.body(color: AppColors.onSurfaceVariant).copyWith(fontStyle: FontStyle.italic),
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
                      _buildSettingsTile(context, Icons.schedule, 'Business Hours', 'Manage your operating times'),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(context, Icons.payments, 'Payout Methods', 'Manage your earnings & bank info', destination: const ChefEarningsScreen()),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(context, Icons.local_shipping, 'Delivery Radius', 'Set your service area (currently 5mi)'),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                      _buildSettingsTile(context, Icons.shield, 'Kitchen Inspection', 'Renew your safety certifications'),
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
        Text(value, style: AppTextStyles.displayLgMobile(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, String subtitle, {Widget? destination}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}
