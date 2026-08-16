import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'settings_screen.dart';
import '../cart/cart_screen.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../orders/order_history_screen.dart';
import '../chat/inbox_screen.dart';
import '../../models/order_model.dart';
import 'address_selection_screen.dart';
import 'payment_methods_screen.dart';
import 'security_password_screen.dart';
import 'help_center_screen.dart';
import 'contact_support_screen.dart';
import 'about_screen.dart';
import 'become_chef_screen.dart';
import '../chef_dashboard/chef_main_navigation.dart';
import '../admin/admin_dashboard_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class ProfileData {
  final UserModel user;
  final List<OrderModel> orders;
  final int bonusCoins;
  final int totalVouchers;
  ProfileData(this.user, this.orders, {this.bonusCoins = 0, this.totalVouchers = 25});
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<ProfileData> _profileFuture;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _loadData();
    });
  }

  Future<ProfileData> _loadData() async {
    final user = await ApiService.getProfile();
    final orders = await ApiService.getOrders();
    
    int bonusCoins = 0;
    int totalVouchers = 25;
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = user.id;
      bonusCoins = prefs.getInt('user_coins_$userId') ?? 0;
      totalVouchers = prefs.getInt('user_vouchers_$userId') ?? 25;
    } catch (_) {}

    return ProfileData(user, orders, bonusCoins: bonusCoins, totalVouchers: totalVouchers);
  }

  // ==========================================
  // EDIT PROFILE DIALOG
  // ==========================================
  Future<void> _showEditProfileDialog(UserModel user) async {
    final nameController = TextEditingController(text: user.name);
    final phoneController = TextEditingController(text: user.phone);
    XFile? selectedImage;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Edit Profile', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picked = await _picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          if (kIsWeb) {
                            setDialogState(() {
                              selectedImage = picked;
                            });
                            return;
                          }
                          final croppedFile = await ImageCropper().cropImage(
                            sourcePath: picked.path,
                            uiSettings: [
                              WebUiSettings(
                                context: context,
                                presentStyle: WebPresentStyle.dialog,
                              ),
                            ],
                          );
                          if (croppedFile != null) {
                            setDialogState(() {
                              selectedImage = XFile(croppedFile.path);
                            });
                          }
                        }
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryContainer,
                        backgroundImage: selectedImage != null
                            ? NetworkImage(selectedImage!.path)
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
                  onPressed: isSaving ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          setDialogState(() => isSaving = true);
                          try {
                            final success = await ApiService.updateProfile(
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                              avatarImage: selectedImage,
                            );
                            setDialogState(() => isSaving = false);
                            if (success && mounted) {
                              Navigator.pop(ctx);
                              _refreshProfile();
                            } else if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(content: Text('Failed to update profile')),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSaving = false);
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(content: Text(e.toString()), duration: const Duration(seconds: 4)),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================
  // LOYALTY HISTORY & DETAILS MODAL
  // ==========================================
  void _showLoyaltyHistoryModal({
    required int loyaltyPoints,
    required int orderPoints,
    required int bonusCoins,
    required List<OrderModel> orders,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Loyalty Points Activity', style: AppTextStyles.headlineMd(color: Colors.white)),
                          Text('Total: $loyaltyPoints pts available', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.stars, color: AppColors.primary, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Points Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('From Orders', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text('$orderPoints pts', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 32, color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Daily & Bonuses', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Text('$bonusCoins pts', style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(fontSize: 16)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Recent Point Transactions', style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: orders.isNotEmpty
                        ? ListView.separated(
                            controller: scrollController,
                            itemCount: orders.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final order = orders[idx];
                              final earned = (order.totalAmount * 10).toInt();
                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.add, color: Colors.greenAccent, size: 16),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(order.kitchenName, style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                                            Text(order.date, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 11)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text('+$earned pts', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.receipt_long, color: AppColors.onSurfaceVariant, size: 40),
                                  const SizedBox(height: 12),
                                  Text('No order activity yet', style: AppTextStyles.bodyMd(color: Colors.white)),
                                  const SizedBox(height: 4),
                                  Text('Order food or claim daily coins to earn loyalty points!', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
                                ],
                              ),
                            ),
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
  // TIER BENEFITS MODAL
  // ==========================================
  void _showTierBenefitsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gourmet Membership Tiers', style: AppTextStyles.headlineMd(color: Colors.white)),
                      Text('Your Status: Gold Member', style: AppTextStyles.labelSm(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTierCard('Silver Tier', '0 - 499 pts', 'Standard Delivery, 1x Points per \$1', false),
              const SizedBox(height: 10),
              _buildTierCard('Gold Tier (Current)', '500 - 1,499 pts', 'Free Delivery > \$20, 1.25x Points, Priority Prep', true),
              const SizedBox(height: 10),
              _buildTierCard('Platinum Tier', '1,500+ pts', 'Unlimited Free Delivery, 1.5x Points, VIP Concierge', false),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Got it!', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTierCard(String title, String pts, String perks, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primary.withValues(alpha: 0.1) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isCurrent ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTextStyles.bodyLg(color: isCurrent ? AppColors.primary : Colors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                    if (isCurrent) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle, color: AppColors.primary, size: 14),
                    ]
                  ],
                ),
                const SizedBox(height: 2),
                Text(perks, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 11)),
              ],
            ),
          ),
          Text(pts, style: AppTextStyles.labelSm(color: Colors.white70).copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ==========================================
  // REWARDS GALLERY MODAL & CLAIM PERK
  // ==========================================
  void _showRewardsGalleryModal(int currentPoints) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rewards Catalog', style: AppTextStyles.headlineMd(color: Colors.white)),
                  Text('$currentPoints pts balance', style: AppTextStyles.labelSm(color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 16),
              _buildPerkRow('Free Delivery Voucher', 'Valid for next 3 days', 0, Icons.delivery_dining, Colors.orange, currentPoints),
              const SizedBox(height: 12),
              _buildPerkRow('10% Off Entire Order', 'Redeem with 500 points', 500, Icons.percent, Colors.pinkAccent, currentPoints),
              const SizedBox(height: 12),
              _buildPerkRow('Free Chef Mocktail', 'With any gourmet entree', 0, Icons.wine_bar, Colors.purpleAccent, currentPoints),
              const SizedBox(height: 12),
              _buildPerkRow('\$15 Chef Special Voucher', 'Redeem with 1,000 points', 1000, Icons.card_giftcard, Colors.greenAccent, currentPoints),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Close', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerkRow(String title, String subtitle, int cost, IconData icon, Color color, int currentPoints) {
    final canClaim = currentPoints >= cost;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _claimPerk(title, cost, currentPoints: currentPoints);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: canClaim ? AppColors.primary : AppColors.surfaceContainerHighest,
              foregroundColor: canClaim ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(cost > 0 ? '$cost pts' : 'Claim', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _claimPerk(String perkTitle, int cost, {int currentPoints = 0}) async {
    if (cost > 0 && currentPoints < cost) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.lock, color: Colors.orangeAccent),
              const SizedBox(width: 10),
              Text('Points Needed', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
            ],
          ),
          content: Text(
            'You need $cost loyalty points to redeem "$perkTitle".\n\nYou currently have $currentPoints pts.',
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final user = await ApiService.getProfile();
      final prefs = await SharedPreferences.getInstance();
      final userId = user.id;

      if (cost > 0) {
        final currentBonus = prefs.getInt('user_coins_$userId') ?? 0;
        await prefs.setInt('user_coins_$userId', (currentBonus - cost).clamp(0, 999999));
      }

      final currentVouchers = prefs.getInt('user_vouchers_$userId') ?? 25;
      await prefs.setInt('user_vouchers_$userId', currentVouchers + 1);

      _refreshProfile();
    } catch (_) {}

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.celebration, color: AppColors.primary),
            const SizedBox(width: 10),
            Text('Perk Unlocked! 🎉', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
          ],
        ),
        content: Text(
          '"$perkTitle" has been claimed and added to your vouchers wallet!',
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MAIN BUILD
  // ==========================================
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
            Image.asset(
              'assets/images/GoCheflogo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('GoChef', style: AppTextStyles.headlineLgMobile(color: Colors.white).copyWith(fontSize: 20)),
                Text(
                  'Your Profile',
                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
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
      body: FutureBuilder<ProfileData>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load profile:\n${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await ApiService.logout();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Logout & Relogin'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Failed to load profile: No data', style: TextStyle(color: Colors.white)));
          }
          final user = snapshot.data!.user;
          final orders = snapshot.data!.orders;
          final bonusCoins = snapshot.data!.bonusCoins;

          double totalSpent = 0;
          for (var o in orders) {
            totalSpent += o.totalAmount;
          }
          int orderPoints = (totalSpent * 10).toInt();
          int loyaltyPoints = orderPoints + bonusCoins;

          OrderModel? lastOrder;
          if (orders.isNotEmpty) {
            lastOrder = orders.first;
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            onRefresh: () async => _refreshProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                      // Gourmet Gold Member Badge (Tap to view tier perks)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(32),
                          onTap: _showTierBenefitsModal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                                Text('GOURMET GOLD MEMBER', style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(letterSpacing: 1, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Loyalty Dashboard Card (100% Clickable)
                  Material(
                    color: const Color(0xFF1C2029).withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showLoyaltyHistoryModal(
                        loyaltyPoints: loyaltyPoints,
                        orderPoints: orderPoints,
                        bonusCoins: bonusCoins,
                        orders: orders,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
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
                                    Text('LOYALTY POINTS', style: AppTextStyles.labelSm(color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('$loyaltyPoints', style: AppTextStyles.displayLgMobile(color: Colors.white).copyWith(height: 1)),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 4, left: 4),
                                          child: Text('pts', style: AppTextStyles.bodyMd(color: Colors.white70)),
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
                            // Progress to Platinum (Clickable)
                            GestureDetector(
                              onTap: _showTierBenefitsModal,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Progress to Platinum', style: AppTextStyles.labelSm(color: Colors.white70)),
                                      Text('250 pts left', style: AppTextStyles.labelSm(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
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
                                      widthFactor: (loyaltyPoints / 1500).clamp(0.1, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [AppColors.primaryContainer, AppColors.tertiaryContainer]),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Recent Activity Row (Clickable)
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
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Recent Activity', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                        const SizedBox(height: 4),
                                        if (lastOrder != null)
                                          Text('+${(lastOrder.totalAmount * 10).toInt()} pts from "${lastOrder.kitchenName}"', style: AppTextStyles.bodyMd(color: AppColors.onSurface), overflow: TextOverflow.ellipsis)
                                        else if (bonusCoins > 0)
                                          Text('+$bonusCoins pts from Daily Check-ins', style: AppTextStyles.bodyMd(color: AppColors.onSurface))
                                        else
                                          Text('No recent activity', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 16),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Rewards Gallery
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rewards Gallery', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      GestureDetector(
                        onTap: () => _showRewardsGalleryModal(loyaltyPoints),
                        child: Text('View All', style: AppTextStyles.labelSm(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                      ),
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
                          onTap: () => _claimPerk('Free Delivery', 0, currentPoints: loyaltyPoints),
                        ),
                        const SizedBox(width: 16),
                        _buildRewardCard(
                          icon: Icons.percent,
                          color: AppColors.tertiary,
                          title: '10% Off Order',
                          subtitle: '500 Points',
                          buttonText: loyaltyPoints >= 500 ? 'Claim' : '500 pts',
                          isLocked: loyaltyPoints < 500,
                          onTap: () => _claimPerk('10% Off Order', 500, currentPoints: loyaltyPoints),
                        ),
                        const SizedBox(width: 16),
                        _buildRewardCard(
                          icon: Icons.wine_bar,
                          color: AppColors.primary,
                          title: 'Free Mocktail',
                          subtitle: 'With any entree',
                          buttonText: 'Claim',
                          isLocked: false,
                          onTap: () => _claimPerk('Free Mocktail', 0, currentPoints: loyaltyPoints),
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
                        _buildListTile(Icons.inbox, 'Messages / Inbox', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const InboxScreen()));
                        }),
                        Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                        _buildListTile(Icons.credit_card, 'Payment Methods', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()));
                        }),
                        Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                        _buildListTile(Icons.location_on, 'Delivery Addresses', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddressSelectionScreen(isSelectionMode: false)));
                        }),
                        Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                        _buildListTile(Icons.receipt_long, 'Order History', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistoryScreen()));
                        }),
                        Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                        _buildListTile(Icons.security, 'Security & Password', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPasswordScreen()));
                        }),
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
                        _buildListTile(Icons.help_outline, 'Help Center', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen()));
                        }),
                        Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                        _buildListTile(Icons.chat_bubble_outline, 'Contact Support', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactSupportScreen()));
                        }),
                        Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
                        _buildListTile(Icons.description_outlined, 'About GoChef', () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Switch to Admin Dashboard / Switch to Chef Dashboard / Become a Chef
                  if (user.role == 'admin')
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shield, color: Colors.white),
                            const SizedBox(width: 8),
                            Text('Open Admin Control Panel', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  else if (user.role == 'chef')
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          await ApiService.saveUserId(user.id, role: 'chef', kitchenId: user.kitchenId);
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const ChefMainNavigation()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.storefront, color: AppColors.onPrimary),
                            const SizedBox(width: 8),
                            Text('Switch to Chef Dashboard', style: AppTextStyles.bodyMd(color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => BecomeChefScreen(userId: user.id)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.storefront, color: AppColors.onPrimary),
                            const SizedBox(width: 8),
                            Text('Become a Chef', style: AppTextStyles.bodyMd(color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () async {
                        await ApiService.logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
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
            ),
          );
        },
      ),
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
    required VoidCallback onTap,
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
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLocked ? AppColors.surfaceContainerHighest : color,
                foregroundColor: isLocked ? AppColors.onSurfaceVariant : Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(buttonText, style: AppTextStyles.labelSm(color: isLocked ? AppColors.onSurfaceVariant : Colors.white).copyWith(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
