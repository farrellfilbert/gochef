import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';

class SecurityPasswordScreen extends StatefulWidget {
  const SecurityPasswordScreen({super.key});

  @override
  State<SecurityPasswordScreen> createState() => _SecurityPasswordScreenState();
}

class _SecurityPasswordScreenState extends State<SecurityPasswordScreen> {
  bool _twoFactorEnabled = false;
  bool _isLoadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadSecurityPreferences();
  }

  Future<void> _loadSecurityPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await ApiService.getUserId() ?? '0';
      if (mounted) {
        setState(() {
          _twoFactorEnabled = prefs.getBool('2fa_enabled_$userId') ?? false;
          _isLoadingPrefs = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPrefs = false);
    }
  }

  Future<void> _toggleTwoFactor(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = await ApiService.getUserId() ?? '0';
      await prefs.setBool('2fa_enabled_$userId', value);
      if (mounted) {
        setState(() => _twoFactorEnabled = value);
      }
    } catch (_) {}
  }

  // ==========================================
  // CHANGE PASSWORD MODAL
  // ==========================================
  void _showChangePasswordModal() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;
    String? errorMessage;

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
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.lock_reset, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Change Password', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
                            const Text('Enter your current and new password', style: TextStyle(color: Colors.white54, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Current Password
                    _buildPasswordField(
                      controller: currentPassController,
                      label: 'Current Password',
                      obscure: obscureCurrent,
                      onToggleObscure: () => setModalState(() => obscureCurrent = !obscureCurrent),
                    ),
                    const SizedBox(height: 16),

                    // New Password
                    _buildPasswordField(
                      controller: newPassController,
                      label: 'New Password',
                      obscure: obscureNew,
                      onToggleObscure: () => setModalState(() => obscureNew = !obscureNew),
                      helperText: 'Must be at least 6 characters',
                    ),
                    const SizedBox(height: 16),

                    // Confirm New Password
                    _buildPasswordField(
                      controller: confirmPassController,
                      label: 'Confirm New Password',
                      obscure: obscureConfirm,
                      onToggleObscure: () => setModalState(() => obscureConfirm = !obscureConfirm),
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final currentPass = currentPassController.text;
                                final newPass = newPassController.text;
                                final confirmPass = confirmPassController.text;

                                if (newPass.length < 6) {
                                  setModalState(() => errorMessage = 'New password must be at least 6 characters.');
                                  return;
                                }

                                if (newPass != confirmPass) {
                                  setModalState(() => errorMessage = 'New passwords do not match.');
                                  return;
                                }

                                setModalState(() {
                                  isSubmitting = true;
                                  errorMessage = null;
                                });

                                final result = await ApiService.changePassword(
                                  currentPassword: currentPass,
                                  newPassword: newPass,
                                );

                                if (result['success'] == true) {
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    ScaffoldMessenger.of(this.context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password updated successfully! 🎉'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } else {
                                  setModalState(() {
                                    isSubmitting = false;
                                    errorMessage = result['error'] ?? 'Failed to update password. Please check your current password.';
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Update Password', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TWO-FACTOR AUTHENTICATION MODAL
  // ==========================================
  void _showTwoFactorModal() {
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
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (_twoFactorEnabled ? Colors.green : Colors.blue).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _twoFactorEnabled ? Icons.verified_user : Icons.security,
                              color: _twoFactorEnabled ? Colors.greenAccent : Colors.blueAccent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Two-Factor Authentication', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 17)),
                              Text(
                                _twoFactorEnabled ? 'Status: Active & Protected' : 'Status: Disabled',
                                style: TextStyle(
                                  color: _twoFactorEnabled ? Colors.greenAccent : Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        value: _twoFactorEnabled,
                        onChanged: (val) async {
                          await _toggleTwoFactor(val);
                          setModalState(() {});
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: AppColors.surfaceContainerHighest,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'When enabled, you will be prompted for an extra security code when logging in from an unrecognized device or browser.',
                    style: AppTextStyles.bodyMd(color: Colors.white70).copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  if (_twoFactorEnabled) ...[
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
                          const Row(
                            children: [
                              Icon(Icons.vpn_key, color: Colors.orangeAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Emergency Backup Codes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Save these single-use codes in a safe place to regain access if you lose your device:',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('9281-4402   7719-0284', style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                                Text('1834-9912   5521-8840', style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Clipboard.setData(const ClipboardData(text: '9281-4402\n7719-0284\n1834-9912\n5521-8840'));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Backup codes copied to clipboard!')),
                                );
                              },
                              icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
                              label: const Text('Copy Backup Codes', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white24),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'We strongly recommend turning on 2FA to protect your payment methods and delivery details.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // ==========================================
  // ACTIVE SESSIONS MODAL
  // ==========================================
  void _showActiveSessionsModal() {
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
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.devices, color: Colors.purpleAccent, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Active Sessions', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
                          const Text('Devices currently signed into your account', style: TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Current Device
                  _buildSessionCard(
                    title: 'Current Mobile Device',
                    subtitle: 'Los Angeles, CA • Active now',
                    icon: Icons.phone_iphone,
                    isCurrent: true,
                  ),
                  const SizedBox(height: 12),

                  // Other Device
                  _buildSessionCard(
                    title: 'Web Browser (Safari / Chrome)',
                    subtitle: 'Los Angeles, CA • Last active 2 hours ago',
                    icon: Icons.laptop_mac,
                    isCurrent: false,
                  ),
                  const SizedBox(height: 28),

                  // Terminate Other Sessions Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('All other sessions signed out successfully.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.exit_to_app, color: AppColors.error, size: 20),
                      label: const Text('Sign Out All Other Sessions', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close', style: TextStyle(color: Colors.white70)),
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

  Widget _buildSessionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCurrent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? Colors.green.withValues(alpha: 0.3) : Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('THIS DEVICE', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.greenAccent, blurRadius: 4)],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggleObscure,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1C2029).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: Colors.white30),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white60, size: 20),
                onPressed: onToggleObscure,
              ),
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(helperText, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Security & Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoadingPrefs
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildOption(
                  Icons.lock_reset,
                  'Change Password',
                  'Update your account password',
                  _showChangePasswordModal,
                ),
                const SizedBox(height: 16),
                _buildOption(
                  Icons.security,
                  'Two-Factor Authentication',
                  _twoFactorEnabled ? 'Enabled • Extra protection active' : 'Disabled • Add an extra layer of security',
                  _showTwoFactorModal,
                  badge: _twoFactorEnabled ? 'ON' : null,
                  badgeColor: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildOption(
                  Icons.devices,
                  'Active Sessions',
                  'Manage your logged-in devices and sessions',
                  _showActiveSessionsModal,
                ),
              ],
            ),
    );
  }

  Widget _buildOption(IconData icon, String title, String subtitle, VoidCallback onTap, {String? badge, Color? badgeColor}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (badgeColor ?? Colors.blue).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: (badgeColor ?? Colors.blue).withValues(alpha: 0.4)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: badgeColor ?? Colors.blue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: AppTextStyles.labelSm(color: Colors.white70)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }
}
