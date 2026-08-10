import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_text_styles.dart';

class SecurityPasswordScreen extends StatelessWidget {
  const SecurityPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        title: const Text('Security & Password'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildOption(Icons.lock_reset, 'Change Password', 'Update your account password'),
          const SizedBox(height: 16),
          _buildOption(Icons.security, 'Two-Factor Authentication', 'Add an extra layer of security'),
          const SizedBox(height: 16),
          _buildOption(Icons.devices, 'Active Sessions', 'Manage your logged-in devices'),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        onTap: () {},
      ),
    );
  }
}
