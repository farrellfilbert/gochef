import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import 'login_screen.dart';
import 'register_chef_screen.dart';
import '../widgets/premium/glass_container.dart';
import '../widgets/premium/bouncing_tap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'chef_mode/chef_main_screen.dart';
import 'main_screen.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.isLoading) return;
      if (next.hasError) return;

      final user = next.value;
      final prevUser = previous?.value;
      
      if (user != null && user.role != prevUser?.role) {
        if (user.role == 'pending_role') {
          // Show role selection bottom sheet
          Future.microtask(() => _showRoleSelectionBottomSheet(context));
        } else if (user.role == 'chef') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ChefMainScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundDark,
              AppTheme.fuchsiaPrimary.withOpacity(0.2),
              AppTheme.backgroundDark,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/gochef_logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'How would you like to continue?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  _buildRoleCard(
                    context: context,
                    title: 'Continue as User',
                    description: 'Order delicious food from top chefs around you.',
                    icon: LucideIcons.user,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  _buildRoleCard(
                    context: context,
                    title: 'Continue as Chef',
                    description: 'Share your culinary masterpiece and start earning.',
                    icon: LucideIcons.utensilsCrossed,
                    isPrimary: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterChefScreen()),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Google Login Button on first screen
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).loginWithGoogle();
                    },
                    icon: const Icon(LucideIcons.chrome, color: Colors.white),
                    label: const Text('Continue with Google', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: AppTheme.surfaceColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return BouncingTap(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPrimary ? AppTheme.fuchsiaPrimary.withOpacity(0.5) : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        color: isPrimary ? AppTheme.fuchsiaPrimary.withOpacity(0.1) : AppTheme.surfaceColor.withOpacity(0.4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPrimary ? AppTheme.fuchsiaPrimary : AppTheme.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const _GoogleRegistrationSheet(),
      ),
    );
  }
}

class _GoogleRegistrationSheet extends ConsumerStatefulWidget {
  const _GoogleRegistrationSheet();

  @override
  ConsumerState<_GoogleRegistrationSheet> createState() => _GoogleRegistrationSheetState();
}

class _GoogleRegistrationSheetState extends ConsumerState<_GoogleRegistrationSheet> {
  late final TextEditingController _nameController;
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).value;
    _nameController = TextEditingController(text: user?.fullName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _completeGoogleReg(String role) async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();

    if (name.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Address are required')),
      );
      return;
    }

    Navigator.pop(context); // close bottom sheet
    try {
      await ref.read(authProvider.notifier).completeGoogleRegistration(role, name, address);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(16),
          child: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleOptionSheet({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        border: Border.all(
          color: isPrimary ? AppTheme.fuchsiaPrimary.withOpacity(0.5) : Colors.white.withOpacity(0.1),
        ),
        color: isPrimary ? AppTheme.fuchsiaPrimary.withOpacity(0.1) : AppTheme.surfaceColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Icon(icon, color: isPrimary ? AppTheme.fuchsiaPrimary : Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Icon(LucideIcons.userCheck, size: 48, color: AppTheme.fuchsiaPrimary),
            const SizedBox(height: 16),
            const Text(
              'Complete Your Profile',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please confirm your details before joining.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              label: 'Full Name',
              controller: _nameController,
              icon: LucideIcons.user,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Delivery Address / Location',
              controller: _addressController,
              icon: LucideIcons.mapPin,
            ),
            const SizedBox(height: 32),
            const Text(
              'How would you like to join?',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildRoleOptionSheet(
              title: 'Join as a Foodie',
              description: 'Order delicious food from home chefs',
              icon: LucideIcons.user,
              onTap: () => _completeGoogleReg('user'),
            ),
            const SizedBox(height: 12),
            _buildRoleOptionSheet(
              title: 'Join as a Chef',
              description: 'Start cooking and earning money',
              icon: LucideIcons.utensilsCrossed,
              onTap: () => _completeGoogleReg('chef'),
              isPrimary: true,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
