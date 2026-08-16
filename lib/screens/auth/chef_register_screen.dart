import 'dart:ui';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../chef_dashboard/chef_main_navigation.dart';
import 'login_screen.dart';

class ChefRegisterScreen extends StatefulWidget {
  const ChefRegisterScreen({super.key});

  @override
  State<ChefRegisterScreen> createState() => _ChefRegisterScreenState();
}

class _ChefRegisterScreenState extends State<ChefRegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _kitchenController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  XFile? _selectedImage;
  XFile? _selectedChefImage;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        setState(() {
          _selectedImage = image;
        });
        return;
      }
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _selectedImage = XFile(croppedFile.path);
        });
      }
    }
  }

  Future<void> _pickChefImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        setState(() {
          _selectedChefImage = image;
        });
        return;
      }
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          _selectedChefImage = XFile(croppedFile.path);
        });
      }
    }
  }


  void _onRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final kitchenName = _kitchenController.text.trim();
    final description = _descriptionController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || kitchenName.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    if (_selectedImage == null || _selectedChefImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both a kitchen photo and a personal photo')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Upload images first
      String? kitchenImageUrl = await ApiService.uploadImage(_selectedImage!);
      String? chefImageUrl = await ApiService.uploadImage(_selectedChefImage!);
      
      if (kitchenImageUrl == null || chefImageUrl == null) {
        throw Exception('Failed to upload image. Please try again.');
      }

      // 2. Register chef
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'role': 'chef',
          'kitchen_name': kitchenName,
          'kitchen_description': description,
          'kitchen_cover': kitchenImageUrl,
          'kitchen_avatar': kitchenImageUrl, // Kitchen's avatar is the same as kitchen cover
          'avatar': chefImageUrl, // Chef's personal avatar
        }),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 48),
                  ),
                  const SizedBox(height: 16),
                  Text('Application Submitted!', style: AppTextStyles.headlineMd(color: Colors.white), textAlign: TextAlign.center),
                ],
              ),
              content: Text(
                'Thank you for registering as a Chef Partner!\n\nYour application has been received and is currently under review by the Admin team. You will be able to log in to the Chef Dashboard once your kitchen is approved.',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              actions: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Back to Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Registration failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.glassBackground,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Join as a Chef',
                          style: AppTextStyles.headlineLgMobile(color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fill in your details to start selling.',
                          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 32),
                        
                        _buildLabel('Kitchen Photo'),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: _selectedImage == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.storefront_outlined, color: AppColors.primary, size: 32),
                                      SizedBox(height: 8),
                                      Text('Tap to upload kitchen photo', style: TextStyle(color: AppColors.onSurfaceVariant)),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb 
                                        ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                                        : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildLabel('Personal Photo (Chef)'),
                        GestureDetector(
                          onTap: _pickChefImage,
                          child: Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: _selectedChefImage == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_outline, color: AppColors.primary, size: 32),
                                      SizedBox(height: 8),
                                      Text('Tap to upload your personal photo', style: TextStyle(color: AppColors.onSurfaceVariant)),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb 
                                        ? Image.network(_selectedChefImage!.path, fit: BoxFit.cover)
                                        : Image.file(File(_selectedChefImage!.path), fit: BoxFit.cover),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        _buildLabel('Full Name'),
                        _buildTextField(_nameController, 'Gordon Ramsay', Icons.person_outline),
                        const SizedBox(height: 16),
                        
                        _buildLabel('Email Address'),
                        _buildTextField(_emailController, 'gordon@kitchen.com', Icons.mail_outlined),
                        const SizedBox(height: 16),
                        
                        _buildLabel('Phone Number'),
                        _buildTextField(_phoneController, '+1 234 567 890', Icons.phone_outlined),
                        const SizedBox(height: 16),
                        
                        _buildLabel('Kitchen / Restaurant Name'),
                        _buildTextField(_kitchenController, "Hell's Kitchen", Icons.storefront_outlined),
                        const SizedBox(height: 16),

                        _buildLabel('About the Kitchen'),
                        _buildTextField(_descriptionController, "Describe your culinary style...", Icons.description_outlined, maxLines: 3),
                        const SizedBox(height: 16),

                        _buildLabel('Password'),
                        _buildTextField(_passwordController, '••••••••', Icons.lock_outline, isPassword: true),
                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: AppColors.magentaGloss,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: MaterialButton(
                              onPressed: _isLoading ? null : _onRegister,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                              child: _isLoading 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                    'Register as Chef',
                                    style: AppTextStyles.headlineMd(color: Colors.white),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.labelMono(color: AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: AppTextStyles.bodyMd(color: AppColors.onSurface),
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
          prefixIcon: maxLines == 1 ? Icon(icon, size: 20, color: AppColors.onSurfaceVariant) : Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.onSurfaceVariant),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }
}
