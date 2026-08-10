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
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant, size: 64, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'GoChef',
                style: AppTextStyles.headlineLg(color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              Text(
                'GoChef connects you with the best private chefs and catering services in your area. Enjoy premium culinary experiences from the comfort of your home.',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _buildLink('Terms of Service'),
              const SizedBox(height: 16),
              _buildLink('Privacy Policy'),
              const SizedBox(height: 32),
              Text(
                '© 2026 GoChef Inc. All rights reserved.',
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
