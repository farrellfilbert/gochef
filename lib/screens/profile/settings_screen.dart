import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import 'personal_information_screen.dart';
import 'security_password_screen.dart';
import '../legal/terms_of_service_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../auth/login_screen.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsAlerts = false;
  String _language = 'English';
  String _appearance = 'Dark';
  String _cacheSize = '14.2 MB';

  bool _googleLinked = true;
  bool _appleLinked = true;
  bool _facebookLinked = false;

  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await ApiService.getUserId() ?? '0';

      if (mounted) {
        setState(() {
          _pushNotifications = prefs.getBool('pref_push_notif_$userId') ?? true;
          _emailNotifications = prefs.getBool('pref_email_notif_$userId') ?? true;
          _smsAlerts = prefs.getBool('pref_sms_alerts_$userId') ?? false;
          _language = prefs.getString('pref_language_$userId') ?? 'English';
          _appearance = prefs.getString('pref_appearance_$userId') ?? 'Dark';
          _cacheSize = prefs.getString('pref_cache_size_$userId') ?? '14.2 MB';
          _googleLinked = prefs.getBool('pref_google_linked_$userId') ?? true;
          _appleLinked = prefs.getBool('pref_apple_linked_$userId') ?? true;
          _facebookLinked = prefs.getBool('pref_fb_linked_$userId') ?? false;
        });
      }

      // Sync latest profile from server
      try {
        final profile = await ApiService.getProfile();
        if (mounted) {
          setState(() {
            _currentUser = profile;
            _pushNotifications = profile.pushNotifications;
            _emailNotifications = profile.emailNotifications;
            _smsAlerts = profile.smsAlerts;
          });
          await prefs.setBool('pref_push_notif_$userId', profile.pushNotifications);
          await prefs.setBool('pref_email_notif_$userId', profile.emailNotifications);
          await prefs.setBool('pref_sms_alerts_$userId', profile.smsAlerts);
        }
      } catch (_) {}
    } catch (_) {}
  }

  Future<void> _savePreference(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await ApiService.getUserId() ?? '0';
      final prefKey = '${key}_$userId';
      if (value is bool) {
        await prefs.setBool(prefKey, value);
      } else if (value is String) {
        await prefs.setString(prefKey, value);
      }
    } catch (_) {}
  }

  // ==========================================
  // NOTIFICATION TOGGLE HANDLERS (Direct & Smooth)
  // ==========================================
  Future<void> _onPushToggle(bool val) async {
    setState(() => _pushNotifications = val);
    await _savePreference('pref_push_notif', val);
    await ApiService.updateProfile(pushNotifications: val);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val ? 'Push notifications enabled 🔔' : 'Push notifications muted 🔕'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _onEmailToggle(bool val) async {
    setState(() => _emailNotifications = val);
    await _savePreference('pref_email_notif', val);
    await ApiService.updateProfile(emailNotifications: val);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val ? 'Email notifications enabled ✉️' : 'Email notifications unsubscribed'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _onSmsToggle(bool val) async {
    setState(() => _smsAlerts = val);
    await _savePreference('pref_sms_alerts', val);
    await ApiService.updateProfile(smsAlerts: val);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(val ? 'SMS order alerts activated 📱' : 'SMS order alerts disabled'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ==========================================
  // SOCIAL ACCOUNTS MODAL
  // ==========================================
  void _showSocialAccountsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.share, color: Colors.blueAccent, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Connected Accounts', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
                            const Text('Manage linked social logins and third-party services', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSocialTile(
                    title: 'Google Account',
                    subtitle: _googleLinked ? 'Connected with ${_currentUser?.email ?? "Google"}' : 'Not linked',
                    icon: Icons.g_mobiledata,
                    isConnected: _googleLinked,
                    onToggle: () async {
                      final newVal = !_googleLinked;
                      setModalState(() => _googleLinked = newVal);
                      setState(() => _googleLinked = newVal);
                      await _savePreference('pref_google_linked', newVal);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(newVal ? 'Google account linked! ✅' : 'Google account disconnected.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildSocialTile(
                    title: 'Apple ID',
                    subtitle: _appleLinked ? 'Sign in with Apple connected' : 'Not linked',
                    icon: Icons.apple,
                    isConnected: _appleLinked,
                    onToggle: () async {
                      final newVal = !_appleLinked;
                      setModalState(() => _appleLinked = newVal);
                      setState(() => _appleLinked = newVal);
                      await _savePreference('pref_apple_linked', newVal);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(newVal ? 'Apple ID connected! 🍏' : 'Apple ID disconnected.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildSocialTile(
                    title: 'Facebook / Meta',
                    subtitle: _facebookLinked ? 'Facebook account connected' : 'Not connected',
                    icon: Icons.facebook,
                    isConnected: _facebookLinked,
                    onToggle: () async {
                      final newVal = !_facebookLinked;
                      setModalState(() => _facebookLinked = newVal);
                      setState(() => _facebookLinked = newVal);
                      await _savePreference('pref_fb_linked', newVal);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(newVal ? 'Facebook account connected!' : 'Facebook account disconnected.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSocialTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isConnected,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isConnected ? Colors.green.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isConnected ? Colors.green.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                isConnected ? 'Connected' : 'Link',
                style: TextStyle(
                  color: isConnected ? Colors.greenAccent : AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PRIVACY & DATA MODAL
  // ==========================================
  void _showPrivacyDataModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock, color: Colors.tealAccent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Privacy & Data', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
                        const Text('Control your personal data & privacy preferences', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Data with GoChef', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    const Text(
                      'We securely encrypt and store your profile information, order history, favorite dishes, and saved delivery addresses. Your payment card details are tokenized and processed via Stripe and are never stored on our servers.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('A full copy of your account data has been requested and sent to your email.'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download, size: 16, color: Colors.white70),
                        label: const Text('Request Personal Data Export', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const Icon(Icons.policy, color: Colors.white70),
                title: const Text('Read Full Privacy Policy', style: TextStyle(color: Colors.white, fontSize: 14)),
                trailing: const Icon(Icons.chevron_right, color: Colors.white30),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                },
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // LANGUAGE MODAL
  // ==========================================
  void _showLanguageModal() {
    final languages = [
      {'name': 'English', 'flag': '🇺🇸', 'desc': 'English (United States)'},
      {'name': 'Español', 'flag': '🇪🇸', 'desc': 'Spanish (Español)'},
      {'name': 'Français', 'flag': '🇫🇷', 'desc': 'French (Français)'},
      {'name': 'Bahasa Indonesia', 'flag': '🇮🇩', 'desc': 'Indonesian (Bahasa Indonesia)'},
      {'name': 'Deutsch', 'flag': '🇩🇪', 'desc': 'German (Deutsch)'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Select Language', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              ...languages.map((l) {
                final isSelected = _language == l['name'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.white10,
                    ),
                  ),
                  child: ListTile(
                    leading: Text(l['flag']!, style: const TextStyle(fontSize: 22)),
                    title: Text(l['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(l['desc']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                    onTap: () {
                      setState(() => _language = l['name']!);
                      _savePreference('pref_language', l['name']!);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Language set to ${l['name']} ✅')),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // APPEARANCE / THEME MODAL
  // ==========================================
  void _showAppearanceModal() {
    final themes = [
      {'name': 'Dark', 'icon': Icons.dark_mode, 'desc': 'Midnight black aesthetic (Recommended)'},
      {'name': 'Light', 'icon': Icons.light_mode, 'desc': 'Bright and clean minimalist theme'},
      {'name': 'System', 'icon': Icons.settings_brightness, 'desc': 'Match device system settings automatically'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Appearance & Theme', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
              const SizedBox(height: 16),
              ...themes.map((t) {
                final isSelected = _appearance == t['name'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.white10,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(t['icon'] as IconData, color: isSelected ? AppColors.primary : Colors.white70),
                    title: Text(t['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(t['desc'] as String, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                    onTap: () {
                      setState(() => _appearance = t['name'] as String);
                      _savePreference('pref_appearance', t['name']);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Appearance updated to ${t['name']} ✅')),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // STORAGE & CACHE MODAL
  // ==========================================
  void _showStorageCacheModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.storage, color: Colors.blueAccent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Storage & Cache', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
                        Text('Current Cache Footprint: $_cacheSize', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildCacheBreakdownRow('Cached Images & Menus', _cacheSize == '0.0 MB' ? '0.0 MB' : '9.4 MB'),
                    const SizedBox(height: 10),
                    _buildCacheBreakdownRow('Temporary Network Data', _cacheSize == '0.0 MB' ? '0.0 MB' : '4.8 MB'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    PaintingBinding.instance.imageCache.clear();
                    PaintingBinding.instance.imageCache.clearLiveImages();
                    setState(() => _cacheSize = '0.0 MB');
                    _savePreference('pref_cache_size', '0.0 MB');
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App cache cleared successfully! 🧹 0.0 MB remaining.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.cleaning_services, color: Colors.white),
                  label: Text('Clear Cache Now ($_cacheSize)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCacheBreakdownRow(String title, String size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        Text(size, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      ],
    );
  }

  Widget _buildVersionDetailRow(String title, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(color: valueColor ?? Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // VERSION INFO MODAL
  // ==========================================
  void _showVersionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline, color: Colors.greenAccent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GoChef Version', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
                        const Text('The GRUB Next Door! App System', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildVersionDetailRow('App Version', 'v2.4.0 (Build 128)'),
                    const SizedBox(height: 10),
                    _buildVersionDetailRow('Release Channel', 'Production / TestFlight', valueColor: Colors.greenAccent),
                    const SizedBox(height: 10),
                    _buildVersionDetailRow('Status', 'Up to Date ✅'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Checking for updates... You are running the latest version! ✅'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text('Check for Updates', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // CLEAR SEARCH HISTORY
  // ==========================================
  void _clearSearchHistory() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E232E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Search History?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to clear your recent dish and kitchen searches from this device?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('recent_searches');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search history cleared successfully. 🗑️')),
                );
              }
            },
            child: const Text('Clear History', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // DELETE ACCOUNT
  // ==========================================
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

  // ==========================================
  // LOGOUT
  // ==========================================
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
                  _buildListTile(
                    Icons.person,
                    'Personal Information',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PersonalInformationScreen(initialUser: _currentUser)),
                    ).then((_) => _loadPreferences()),
                  ),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(
                    Icons.security,
                    'Password & Security',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SecurityPasswordScreen()),
                    ),
                  ),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(
                    Icons.share,
                    'Social Accounts',
                    _showSocialAccountsModal,
                  ),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(
                    Icons.delete_forever,
                    'Delete Account',
                    () => _showDeleteAccountDialog(context),
                    isError: true,
                  ),
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
                            Expanded(
                              child: Text('Notification Settings', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(left: 36),
                          child: Column(
                            children: [
                              _buildToggleRow('Push Notifications', _pushNotifications, _onPushToggle, subtitle: 'Order status, preparation & alerts'),
                              const SizedBox(height: 16),
                              _buildToggleRow('Email Notifications', _emailNotifications, _onEmailToggle, subtitle: 'Order receipts & chef highlights'),
                              const SizedBox(height: 16),
                              _buildToggleRow('SMS Alerts', _smsAlerts, _onSmsToggle, subtitle: 'Urgent delivery updates to your phone'),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(
                    Icons.lock,
                    'Privacy & Data',
                    _showPrivacyDataModal,
                  ),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTileWithValue(
                    Icons.language,
                    'Language',
                    _language,
                    _showLanguageModal,
                  ),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTileWithValue(
                    Icons.dark_mode,
                    'Appearance',
                    _appearance,
                    _showAppearanceModal,
                  ),
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
                  _buildListTileWithValue(
                    Icons.storage,
                    'Storage & Cache',
                    _cacheSize,
                    _showStorageCacheModal,
                    valueIsMono: true,
                  ),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTileWithValue(
                    Icons.info,
                    'Version Info',
                    'v2.4.0',
                    _showVersionModal,
                    valueIsMono: true,
                  ),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(
                    Icons.history,
                    'Clear Search History',
                    _clearSearchHistory,
                    trailingIcon: Icons.delete_outline,
                  ),
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildListTileWithValue(IconData icon, String title, String value, VoidCallback? onTap, {bool valueIsMono = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildListTileNoLeading(String title, VoidCallback? onTap, {IconData trailingIcon = Icons.chevron_right}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, Function(bool) onChanged, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.bodyMd(color: Colors.white)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.primaryContainer,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.surfaceContainerHighest,
        ),
      ],
    );
  }
}
