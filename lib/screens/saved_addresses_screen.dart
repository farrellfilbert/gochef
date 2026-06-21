import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Addresses',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildAddressCard(
            title: 'Home',
            address: 'Jl. Sudirman No. 123, South Jakarta, 12190',
            isPrimary: true,
            icon: LucideIcons.home,
          ),
          const SizedBox(height: 16),
          _buildAddressCard(
            title: 'Office',
            address: 'Tokopedia Tower Building Fl. 14, Kuningan, South Jakarta',
            isPrimary: false,
            icon: LucideIcons.briefcase,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.fuchsiaPrimary,
        icon: const Icon(LucideIcons.plus, color: Colors.white),
        label: const Text('Add Address', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAddressCard({
    required String title,
    required String address,
    required bool isPrimary,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary ? AppTheme.fuchsiaPrimary.withValues(alpha: 0.5) : AppTheme.surfaceLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPrimary ? AppTheme.fuchsiaPrimary.withValues(alpha: 0.2) : AppTheme.surfaceLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isPrimary ? AppTheme.fuchsiaPrimary : AppTheme.textSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Primary',
                          style: TextStyle(
                            color: AppTheme.fuchsiaPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  address,
                  style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.8), height: 1.5),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.moreVertical, color: AppTheme.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
