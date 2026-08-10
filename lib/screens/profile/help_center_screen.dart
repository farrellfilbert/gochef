import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_text_styles.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        title: const Text('Help Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for help...',
                hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                border: InputBorder.none,
              ),
              style: const TextStyle(color: AppColors.onSurface),
            ),
          ),
          const SizedBox(height: 24),
          Text('Frequently Asked Questions', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
          const SizedBox(height: 16),
          _buildFaqItem('How do I track my order?', 'You can track your order in the "Tracking" menu after placing an order.'),
          const SizedBox(height: 12),
          _buildFaqItem('Can I change my delivery address?', 'Yes, you can edit your address in the "Delivery Addresses" menu in your profile or directly at checkout.'),
          const SizedBox(height: 12),
          _buildFaqItem('What payment methods do you accept?', 'We accept credit cards, debit cards, and popular e-wallets.'),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Text(question, style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.onSurfaceVariant,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
