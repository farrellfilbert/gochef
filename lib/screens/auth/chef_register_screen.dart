import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

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
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _onRegister() {
    // TODO: Implement Chef Registration API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chef registration feature coming soon!')),
    );
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
                              child: Text(
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
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
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
          prefixIcon: Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
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
