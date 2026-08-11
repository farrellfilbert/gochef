import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../chef_dashboard/chef_main_navigation.dart';
import 'dart:io';

class BecomeChefScreen extends StatefulWidget {
  final String userId;

  const BecomeChefScreen({super.key, required this.userId});

  @override
  State<BecomeChefScreen> createState() => _BecomeChefScreenState();
}

class _BecomeChefScreenState extends State<BecomeChefScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kitchenNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  File? _kitchenImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _kitchenImage = File(picked.path));
    }
  }

  Future<void> _upgradeToChef() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String kitchenImageUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_kitchenNameController.text)}';
      
      if (_kitchenImage != null) {
        String? uploadedUrl = await ApiService.uploadImage(_kitchenImage!);
        if (uploadedUrl != null) {
          kitchenImageUrl = uploadedUrl;
        }
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/upgrade_to_chef.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'kitchen_name': _kitchenNameController.text,
          'kitchen_description': _descriptionController.text,
          'kitchen_avatar': kitchenImageUrl,
          'kitchen_cover': kitchenImageUrl,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // Update stored role and kitchenId
        await ApiService.saveUserId(
          widget.userId, 
          role: 'chef', 
          kitchenId: data['kitchen_id'].toString()
        );
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ChefMainNavigation()),
            (route) => false,
          );
        }
      } else {
        throw Exception(data['error'] ?? 'Failed to upgrade');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        title: const Text('Become a Chef'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Open Your Kitchen',
                style: AppTextStyles.headlineLgMobile(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'Turn your passion into a business. Set up your kitchen details below.',
                style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                      image: _kitchenImage != null
                          ? DecorationImage(image: FileImage(_kitchenImage!), fit: BoxFit.cover)
                          : null,
                    ),
                    child: _kitchenImage == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: AppColors.primary, size: 32),
                              SizedBox(height: 4),
                              Text('Add Photo', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _kitchenNameController,
                style: const TextStyle(color: AppColors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Kitchen Name',
                  labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.store, color: AppColors.primary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Kitchen name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.onSurface),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Kitchen Description',
                  labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.description, color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _upgradeToChef,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.onPrimary)
                      : Text('Open Kitchen', style: AppTextStyles.labelLg(color: AppColors.onPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
