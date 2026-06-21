import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _promoNotif = true;
  bool _orderNotif = true;
  bool _chatNotif = true;
  bool _systemNotif = false;

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
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Notification Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set the types of notifications you want to receive.',
            style: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 24),
          _buildSwitchTile(
            title: 'Promos & Discounts',
            subtitle: 'Information on exciting offers and vouchers',
            icon: LucideIcons.tag,
            value: _promoNotif,
            onChanged: (val) => setState(() => _promoNotif = val),
          ),
          _buildSwitchTile(
            title: 'Order Status',
            subtitle: 'Latest updates regarding your order',
            icon: LucideIcons.shoppingBag,
            value: _orderNotif,
            onChanged: (val) => setState(() => _orderNotif = val),
          ),
          _buildSwitchTile(
            title: 'New Messages',
            subtitle: 'Chat notifications from chefs or drivers',
            icon: LucideIcons.messageCircle,
            value: _chatNotif,
            onChanged: (val) => setState(() => _chatNotif = val),
          ),
          _buildSwitchTile(
            title: 'System & Security',
            subtitle: 'Login notifications and account activity',
            icon: LucideIcons.shieldAlert,
            value: _systemNotif,
            onChanged: (val) => setState(() => _systemNotif = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.textSecondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.fuchsiaPrimary,
            activeTrackColor: AppTheme.fuchsiaPrimary.withValues(alpha: 0.3),
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.surfaceLight,
          ),
        ],
      ),
    );
  }
}
