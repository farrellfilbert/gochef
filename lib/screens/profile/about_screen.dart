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
              Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Image.asset('assets/images/GoCheflogo.png', width: 120, height: 120),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: 0.9,
                child: Text(
                  'The Grub Next Door',
                  style: AppTextStyles.bodyMd(color: Colors.white).copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'GoChef • Version 1.0.0',
                style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Text(
                'The Grub Next Door connects you with the best private chefs, artisan home cooks, and boutique catering services right in your neighborhood. Enjoy authentic gourmet culinary experiences delivered fresh to your doorstep or booked for private dine-in.',
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
