import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'settings_screen.dart';
import '../cart/cart_screen.dart';

import '../../services/api_service.dart';
import '../../models/user_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<UserModel> _profileFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = ApiService.getProfile();
    });
  }

  Future<void> _showEditProfileDialog(UserModel user) async {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    XFile? selectedImage;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: Text('Edit Profile', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picked = await _picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setDialogState(() {
                            selectedImage = picked;
                          });
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: selectedImage != null 
                            ? NetworkImage(selectedImage!.path) // works on web for preview if object URL, but XFile.path on web might just be blob URL
                            : NetworkImage(user.avatar.isNotEmpty ? user.avatar : 'https://via.placeholder.com/150'),
                        child: const Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.camera_alt, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outlineVariant)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.outlineVariant)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async {
                    setDialogState(() => isSaving = true);
                    final success = await ApiService.updateProfile(
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      avatarImage: selectedImage,
                    );
                    setDialogState(() => isSaving = false);
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      _refreshProfile();
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update profile')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: isSaving 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.menu, color: AppColors.primary),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('GoChef', style: AppTextStyles.headlineLgMobile(color: AppColors.primary).copyWith(fontSize: 20)),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'University District',
                      style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag, color: AppColors.primary),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.2), height: 1),
        ),
      ),
      body: FutureBuilder<UserModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load profile', style: TextStyle(color: Colors.white)));
          }
          final user = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 120),
            child: Column(
              children: [
                // Profile Header
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => _showEditProfileDialog(user),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryContainer, width: 2),
                              boxShadow: [BoxShadow(color: AppColors.primaryContainer.withValues(alpha: 0.3), blurRadius: 15)],
                              image: DecorationImage(
                                image: NetworkImage(user.avatar.isNotEmpty ? user.avatar : 'https://via.placeholder.com/150'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                            ),
                            child: const Icon(Icons.edit, color: AppColors.onPrimaryContainer, size: 16),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(user.name, style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)),
                    const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: AppColors.primaryContainer.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text('GOURMET GOLD MEMBER', style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Loyalty Dashboard Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2029).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LOYALTY POINTS', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('1,250', style: AppTextStyles.displayLgMobile(color: AppColors.primary).copyWith(height: 1)),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4, left: 4),
                                child: Text('pts', style: AppTextStyles.bodyMd(color: AppColors.primary.withValues(alpha: 0.7))),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.history, color: AppColors.onSurfaceVariant),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress to Platinum', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                      Text('250 pts left', style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.75,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.primaryContainer, AppColors.tertiaryContainer]),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Recent Activity', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Text('+150 pts from "Spicy Thai Kitchen"', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Rewards Gallery
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rewards Gallery', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                Text('View All', style: AppTextStyles.labelSm(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildRewardCard(
                    icon: Icons.delivery_dining,
                    color: AppColors.primary,
                    title: 'Free Delivery',
                    subtitle: 'Valid for 3 days',
                    buttonText: 'Claim',
                    isLocked: false,
                  ),
                  const SizedBox(width: 16),
                  _buildRewardCard(
                    icon: Icons.percent,
                    color: AppColors.tertiary,
                    title: '10% Off Order',
                    subtitle: '500 Points',
                    buttonText: 'Locked',
                    isLocked: true,
                  ),
                  const SizedBox(width: 16),
                  _buildRewardCard(
                    icon: Icons.wine_bar,
                    color: AppColors.primary,
                    title: 'Free Mocktail',
                    subtitle: 'With any entree',
                    buttonText: 'Claim',
                    isLocked: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Account Management List
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Account Management', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2029).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.person_outline, 'Personal Information', () => _showEditProfileDialog(user)),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.credit_card, 'Payment Methods', null),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.location_on, 'Delivery Addresses', null),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.receipt_long, 'Order History', null),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.security, 'Security & Password', null),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.settings, 'Settings', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Support & About
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Support & About', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2029).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.help_outline, 'Help Center', null),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.chat_bubble_outline, 'Contact Support', null),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                  _buildListTile(Icons.info_outline, 'About GoChef', null),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () async {
                  await ApiService.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/'); // Go to root/login
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text('Log Out', style: AppTextStyles.bodyMd(color: Colors.redAccent)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      }
      )
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback? onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.onSurfaceVariant),
      title: Text(title, style: AppTextStyles.bodyLg(color: AppColors.onSurface)),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.onSurfaceVariant, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }

  Widget _buildRewardCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String buttonText,
    required bool isLocked,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isLocked ? AppColors.surfaceContainerHighest : color,
                foregroundColor: isLocked ? AppColors.onSurfaceVariant : Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(buttonText, style: AppTextStyles.labelSm(color: isLocked ? AppColors.onSurfaceVariant : Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
