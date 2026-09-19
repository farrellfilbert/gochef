import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import '../legal/terms_of_service_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../auth/login_screen.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings', style: AppTextStyles.headlineMd(color: Colors.white)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.2), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings
            _buildSectionTitle('Account Settings'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2029).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.person, 'Personal Information', null),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.security, 'Password & Security', null),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.share, 'Social Accounts', null),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.delete_forever, 'Delete Account', () => _showDeleteAccountDialog(context), isError: true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preferences
            _buildSectionTitle('Preferences'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2029).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  // Notifications Custom Block
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.notifications, color: Colors.white),
                            const SizedBox(width: 12),
                            Text('Notification Settings', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 36),
                          child: Column(
                            children: [
                              _buildToggleRow('Push Notifications', true),
                              const SizedBox(height: 16),
                              _buildToggleRow('Email Notifications', true),
                              const SizedBox(height: 16),
                              _buildToggleRow('SMS Alerts', false),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.lock, 'Privacy & Data', null),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTileWithValue(Icons.language, 'Language', 'English', null),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTileWithValue(Icons.dark_mode, 'Appearance', 'Dark', null),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // App Settings
            _buildSectionTitle('App Settings'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2029).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildListTileWithValue(Icons.storage, 'Storage & Cache', '124 MB', null, valueIsMono: true),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTileWithValue(Icons.info, 'Version Info', 'v2.4.0', null, valueIsMono: true),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.history, 'Clear Search History', null, trailingIcon: Icons.delete),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Legal & Support
            _buildSectionTitle('Legal & Support'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2029).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  _buildListTileNoLeading('Terms of Service', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()));
                  }, trailingIcon: Icons.chevron_right),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTileNoLeading('Privacy Policy', () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                  }, trailingIcon: Icons.chevron_right),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTileNoLeading('Licenses', () {
                    showLicensePage(
                      context: context,
                      applicationName: 'The GRUB Next Door!',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2026 GoChef Technologies. All rights reserved.',
                    );
                  }, trailingIcon: Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout
            ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                  side: const BorderSide(color: Colors.white30),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'GoChef x The GRUB Next Door!',
                style: AppTextStyles.labelSm(color: Colors.white60).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E232E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account? All your personal information, active orders, and favorites will be permanently removed. This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleting account...')),
              );
              final success = await ApiService.deleteAccount();
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted successfully.')),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete account. Please try again.')),
                  );
                }
              }
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1E232E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await ApiService.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSm(color: Colors.white70).copyWith(letterSpacing: 1.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback? onTap, {bool isError = false, IconData trailingIcon = Icons.chevron_right}) {
    Color color = isError ? AppColors.error : Colors.white;
    Color textColor = isError ? AppColors.error : Colors.white;
    Color iconColor = isError ? AppColors.error.withValues(alpha: 0.15) : Colors.white12;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMd(color: textColor),
              ),
            ),
            Icon(trailingIcon, color: Colors.white30, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildListTileWithValue(IconData icon, String title, String value, VoidCallback? onTap, {bool valueIsMono = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMd(color: Colors.white),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodySm(color: Colors.white60).copyWith(
                fontFamily: valueIsMono ? 'monospace' : null,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white30, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildListTileNoLeading(String title, VoidCallback? onTap, {IconData trailingIcon = Icons.chevron_right}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.bodyMd(color: Colors.white)),
            Icon(trailingIcon, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool initialValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMd(color: Colors.white70)),
        Switch(
          value: initialValue,
          onChanged: (val) {},
          activeColor: Colors.white,
          activeTrackColor: AppColors.primaryContainer,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.surfaceContainerHighest,
        )
      ],
    );
  }
}
