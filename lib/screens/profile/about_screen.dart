import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        title: const Text('About GoChef'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/GoCheflogo.png',
                  height: 90,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, size: 64, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'The GRUB Next Door!',
                style: AppTextStyles.headlineLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'GoChef • Version 1.0.0',
                style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                'The GRUB Next Door connects you with the best private chefs, artisan home cooks, and boutique catering services right in your neighborhood. Enjoy authentic gourmet culinary experiences delivered fresh to your doorstep or booked for private dine-in.',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _buildLink('Terms of Service'),
              const SizedBox(height: 16),
              _buildLink('Privacy Policy'),
              const SizedBox(height: 32),
              Text(
                '© 2026 GoChef x The GRUB Next Door! All rights reserved.',
                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLink(String text) {
    return InkWell(
      onTap: () {},
      child: Text(
        text,
        style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
