import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';

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
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Settings', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
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
                  _buildListTile(Icons.no_accounts, 'Deactivate Account', null, isError: true),
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
                            const Icon(Icons.notifications, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text('Notification Settings', style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
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
                  _buildListTileNoLeading('Terms of Service', null, trailingIcon: Icons.open_in_new),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTileNoLeading('Privacy Policy', null, trailingIcon: Icons.open_in_new),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTileNoLeading('Licenses', null, trailingIcon: Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'GoChef Gourmet v2.4.0 build 4829',
                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)).copyWith(letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback? onTap, {bool isError = false, IconData trailingIcon = Icons.chevron_right}) {
    Color color = isError ? AppColors.error : AppColors.primary;
    Color textColor = isError ? AppColors.error : AppColors.onSurface;
    Color iconColor = isError ? AppColors.error.withValues(alpha: 0.4) : AppColors.onSurfaceVariant.withValues(alpha: 0.4);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: AppTextStyles.bodyMd(color: textColor))),
            Icon(trailingIcon, color: iconColor),
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
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface))),
            Text(
              value,
              style: valueIsMono
                  ? AppTextStyles.labelMono(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6))
                  : AppTextStyles.bodyMd(color: AppColors.primary),
            ),
            if (!valueIsMono) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildListTileNoLeading(String title, VoidCallback? onTap, {required IconData trailingIcon}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
            Icon(trailingIcon, color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(String label, bool initialValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
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
