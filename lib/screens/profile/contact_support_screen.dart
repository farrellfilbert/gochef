import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_text_styles.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        title: const Text('Contact Support'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.support_agent, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                'How can we help you?',
                style: AppTextStyles.headlineMd(color: AppColors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Our support team is available 24/7 to help you with any issues or questions.',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildContactMethod(Icons.chat, 'Live Chat', 'Average wait time: 2 mins', () {}),
              const SizedBox(height: 16),
              _buildContactMethod(Icons.email, 'Email Us', 'support@gochef.com', () {}),
              const SizedBox(height: 16),
              _buildContactMethod(Icons.phone, 'Call Us', '+1 (555) 123-4567', () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactMethod(IconData icon, String title, String subtitle, VoidCallback onTap) {
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
        onTap: onTap,
      ),
    );
  }
}
