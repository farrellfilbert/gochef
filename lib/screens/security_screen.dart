import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

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
          'Security',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2D3E), Color(0xFF1E1F2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(
                  LucideIcons.shieldCheck,
                  color: AppTheme.fuchsiaPrimary,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Account is Secure',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last updated today, 09:41',
                  style: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Security Options',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionTile(
            title: 'Change Password',
            icon: LucideIcons.key,
            onTap: () {},
          ),
          _buildActionTile(
            title: 'Transaction PIN',
            icon: LucideIcons.lock,
            onTap: () {},
          ),
          _buildActionTile(
            title: 'Biometric Authentication',
            icon: LucideIcons.fingerprint,
            onTap: () {},
            trailing: Switch(
              value: true,
              onChanged: (val) {},
              activeColor: AppTheme.fuchsiaPrimary,
              activeTrackColor: AppTheme.fuchsiaPrimary.withValues(alpha: 0.3),
            ),
          ),
          _buildActionTile(
            title: 'Connected Devices',
            icon: LucideIcons.smartphone,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.surfaceLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(
                LucideIcons.chevronRight,
                color: AppTheme.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
