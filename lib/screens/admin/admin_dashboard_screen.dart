import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../main.dart';
import '../auth/login_screen.dart';
import '../chat/chat_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingChefs = true;
  bool _isLoadingPromos = true;
  bool _isLoadingUsers = true;
  List<Map<String, dynamic>> _chefApplications = [];
  List<Map<String, dynamic>> _promotions = [];
  List<Map<String, dynamic>> _adminUsers = [];
  String _chefFilter = 'pending';
  String _userTypeFilter = 'all';
  final TextEditingController _userSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadChefs();
    _loadUsers();
    _loadPromotions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChefs() async {
    setState(() => _isLoadingChefs = true);
    final data = await ApiService.getAdminChefs(filter: _chefFilter);
    if (mounted) {
      setState(() {
        _chefApplications = data;
        _isLoadingChefs = false;
      });
    }
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    final data = await ApiService.getAdminUsers(
      type: _userTypeFilter,
      search: _userSearchController.text.trim(),
    );
    if (mounted) {
      setState(() {
        _adminUsers = data;
        _isLoadingUsers = false;
      });
    }
  }

  void _openChatWithUser(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          otherParticipantId: user['id'].toString(),
          otherParticipantName: user['name'] ?? user['kitchen_name'] ?? 'User',
          otherParticipantAvatar: ApiService.formatImageUrl(user['avatar'] ?? user['kitchen_avatar'] ?? ''),
          kitchenId: user['kitchen_id']?.toString(),
        ),
      ),
    );
  }

  Future<void> _confirmSuspendUser(Map<String, dynamic> user) async {
    final reasonController = TextEditingController(text: 'Violation of Community Guidelines');
    final isChef = user['role'] == 'chef' || user['kitchen_id'] != null;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.pause_circle_filled, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isChef ? 'Suspend Kitchen & Chef' : 'Suspend User Account', 
                style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to suspend "${user['name']}"? They will not be able to log in or make transactions.',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Reason for suspension',
                labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
            child: const Text('Suspend Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.adminSuspendUser(
        userId: user['id'].toString(),
        kitchenId: user['kitchen_id']?.toString(),
        reason: reasonController.text.trim(),
      );
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account suspended successfully ⏸️'), backgroundColor: Colors.orange),
          );
          _loadUsers();
          _loadChefs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to suspend account'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  Future<void> _unsuspendUser(Map<String, dynamic> user) async {
    final success = await ApiService.adminUnsuspendUser(
      userId: user['id'].toString(),
      kitchenId: user['kitchen_id']?.toString(),
    );
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account restored to active! ✅'), backgroundColor: Colors.green),
        );
        _loadUsers();
        _loadChefs();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to restore account'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _confirmDeleteUser(Map<String, dynamic> user) async {
    final isChef = user['role'] == 'chef' || user['kitchen_id'] != null;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.redAccent, size: 24),
            SizedBox(width: 8),
            Text('Permanent Deletion', style: TextStyle(color: Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${user['name']}"${isChef ? " and their kitchen data" : ""}? This action CANNOT be undone.',
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.adminDeleteUser(
        userId: user['id'].toString(),
        kitchenId: user['kitchen_id']?.toString(),
      );
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted permanently 🗑️'), backgroundColor: Colors.redAccent),
          );
          _loadUsers();
          _loadChefs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete account'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  Future<void> _loadPromotions() async {
    setState(() => _isLoadingPromos = true);
    final data = await ApiService.getAdminPromotions();
    if (mounted) {
      setState(() {
        _promotions = data;
        _isLoadingPromos = false;
      });
    }
  }

  Future<void> _approveChef(int kitchenId, String? userId) async {
    final success = await ApiService.approveChef(kitchenId, userId: userId);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chef application approved successfully! 🎉'), backgroundColor: Colors.green),
        );
        _loadChefs();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to approve chef'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _rejectChef(int kitchenId, String? userId) async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Reject Chef Application', style: AppTextStyles.headlineMd(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject this kitchen application?', 
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Reason for rejection',
                labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                hintText: 'e.g. Incomplete menu or unclear kitchen photo',
                hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Reject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.rejectChef(
        kitchenId, 
        userId: userId, 
        reason: reasonController.text.isNotEmpty ? reasonController.text : 'Requirements not met'
      );
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application rejected and user notified.'), backgroundColor: Colors.orange),
          );
          _loadChefs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to reject application'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  // ==========================================
  // CREATE / EDIT PROMOTION MODAL
  // ==========================================
  void _showAddPromotionModal() {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final codeController = TextEditingController();
    final imageController = TextEditingController();
    int discountPercent = 20;
    XFile? pickedImage;
    bool isUploading = false;

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
                left: 20,
                right: 20,
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
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Create Promo Banner', style: AppTextStyles.headlineMd(color: Colors.white)),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Banner Image Picker
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(source: ImageSource.gallery);
                        if (img != null) {
                          setModalState(() {
                            pickedImage = img;
                            isUploading = true;
                          });
                          final uploadedUrl = await ApiService.uploadImage(img);
                          setModalState(() {
                            isUploading = false;
                            if (uploadedUrl != null) {
                              imageController.text = uploadedUrl;
                            }
                          });
                        }
                      },
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                          image: imageController.text.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(ApiService.formatImageUrl(imageController.text)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageController.text.isEmpty
                            ? Center(
                                child: isUploading
                                    ? const CircularProgressIndicator(color: AppColors.primary)
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.add_photo_alternate, color: AppColors.primary, size: 36),
                                          const SizedBox(height: 8),
                                          Text('Upload Banner Image (16:9 recommended)',
                                              style: AppTextStyles.labelSm(color: AppColors.primary)),
                                        ],
                                      ),
                              )
                            : Container(
                                alignment: Alignment.topRight,
                                padding: const EdgeInsets.all(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Change Image', style: TextStyle(color: Colors.white, fontSize: 11)),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Promo Banner Title',
                        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                        hintText: 'e.g. 50% Off Gourmet Weekend',
                        hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    TextField(
                      controller: subtitleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Subtitle / Description',
                        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                        hintText: 'e.g. Exclusive discount on all artisan dishes',
                        hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        // Promo Code
                        Expanded(
                          child: TextField(
                            controller: codeController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: 'Promo Voucher Code',
                              labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                              hintText: 'e.g. WEEKEND50',
                              hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: AppColors.surfaceContainerLow,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Discount %
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Discount (%)',
                              labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                              hintText: '20',
                              suffixText: '%',
                              filled: true,
                              fillColor: AppColors.surfaceContainerLow,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            onChanged: (val) {
                              discountPercent = int.tryParse(val) ?? 0;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a banner title'), backgroundColor: AppColors.error),
                            );
                            return;
                          }

                          Navigator.pop(ctx);
                          final success = await ApiService.createPromotion(
                            title: titleController.text.trim(),
                            subtitle: subtitleController.text.trim(),
                            image: imageController.text.trim().isNotEmpty
                                ? imageController.text.trim()
                                : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?q=80&w=1000',
                            discountPercent: discountPercent,
                            code: codeController.text.trim().toUpperCase(),
                            isActive: true,
                          );

                          if (mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Promo banner published live! 🚀'), backgroundColor: Colors.green),
                              );
                              _loadPromotions();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to publish banner'), backgroundColor: AppColors.error),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Publish Banner Live', style: AppTextStyles.bodyLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.admin_panel_settings, color: Colors.amber.shade400, size: 20),
              ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.amber.shade900.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade600, width: 1),
              ),
              child: Text('ADMIN', style: TextStyle(color: Colors.amber.shade300, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text('GoChef Control', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
          ],
        ),
        actions: [
          // Switch to Customer/Foodie View
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigation()),
              );
            },
            icon: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 16),
            label: const Text('Foodie View', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          // Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
            tooltip: 'Logout Admin',
            onPressed: () async {
              await ApiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.how_to_reg, size: 20), text: 'Approvals'),
            Tab(icon: Icon(Icons.people_alt_outlined, size: 20), text: 'Users & Kitchens'),
            Tab(icon: Icon(Icons.campaign_outlined, size: 20), text: 'Banners'),
            Tab(icon: Icon(Icons.analytics_outlined, size: 20), text: 'Stats'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChefApprovalsTab(),
          _buildUsersAndKitchensTab(),
          _buildPromotionsTab(),
          _buildStatsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 2
          ? FloatingActionButton.extended(
              onPressed: _showAddPromotionModal,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Add Banner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  // ==========================================
  // TAB 1: CHEF APPROVALS
  // ==========================================
  Widget _buildChefApprovalsTab() {
    final pendingCount = _chefApplications.where((c) => c['is_verified']?.toString() == '0').length;

    return Column(
      children: [
        // Filter row
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
          child: Row(
            children: [
              _buildFilterChip('pending', 'Pending Review ($pendingCount)'),
              const SizedBox(width: 8),
              _buildFilterChip('approved', 'Active Chefs'),
              const SizedBox(width: 8),
              _buildFilterChip('all', 'All'),
            ],
          ),
        ),

        Expanded(
          child: _isLoadingChefs
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _chefApplications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.greenAccent.withValues(alpha: 0.6), size: 64),
                          const SizedBox(height: 16),
                          Text('No applications found', style: AppTextStyles.headlineMd(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text('All chef applications have been reviewed!', 
                              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadChefs,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _chefApplications.length,
                        itemBuilder: (context, index) {
                          final chef = _chefApplications[index];
                          final isPending = chef['is_verified']?.toString() == '0';
                          final kitchenId = int.tryParse(chef['kitchen_id']?.toString() ?? '0') ?? 0;
                          final userId = chef['user_id']?.toString();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isPending ? Colors.amber.shade700.withValues(alpha: 0.5) : AppColors.outlineVariant.withValues(alpha: 0.2),
                                width: isPending ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundImage: NetworkImage(
                                        ApiService.formatImageUrl(chef['kitchen_avatar'] ?? chef['user_avatar'] ?? ''),
                                      ),
                                      onBackgroundImageError: (_, __) {},
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  chef['kitchen_name'] ?? 'Untitled Kitchen',
                                                  style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: isPending ? Colors.amber.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  isPending ? 'PENDING' : 'APPROVED',
                                                  style: TextStyle(
                                                    color: isPending ? Colors.amber : Colors.greenAccent,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text('Applicant: ${chef['user_name'] ?? '-'} (${chef['user_email'] ?? '-'})',
                                              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                          if (chef['user_phone'] != null && chef['user_phone'].toString().isNotEmpty)
                                            Text('Phone: ${chef['user_phone']}',
                                                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.background.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    chef['kitchen_description'] ?? 'No description provided.',
                                    style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                  ),
                                ),
                                if (isPending) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      // Quick Chat button with applicant
                                      IconButton.filledTonal(
                                        onPressed: () {
                                          if (userId != null) {
                                            _openChatWithUser({
                                              'id': userId,
                                              'name': chef['user_name'] ?? 'Chef Applicant',
                                              'avatar': chef['user_avatar'] ?? chef['kitchen_avatar'],
                                              'kitchen_id': kitchenId.toString(),
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20),
                                        tooltip: 'Chat with Applicant',
                                        style: IconButton.styleFrom(
                                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                                          padding: const EdgeInsets.all(12),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _rejectChef(kitchenId, userId),
                                          icon: const Icon(Icons.close, color: Colors.redAccent, size: 18),
                                          label: const Text('Reject', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.redAccent),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => _approveChef(kitchenId, userId),
                                          icon: const Icon(Icons.check, color: Colors.white, size: 18),
                                          label: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green.shade700,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          if (userId != null) {
                                            _openChatWithUser({
                                              'id': userId,
                                              'name': chef['kitchen_name'] ?? chef['user_name'] ?? 'Chef',
                                              'avatar': chef['kitchen_avatar'] ?? chef['user_avatar'],
                                              'kitchen_id': kitchenId.toString(),
                                            });
                                          }
                                        },
                                        icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
                                        label: const Text('Chat Kitchen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filter, String label) {
    final isSelected = _chefFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() => _chefFilter = filter);
        _loadChefs();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: USERS & KITCHENS MODERATION
  // ==========================================
  Widget _buildUsersAndKitchensTab() {
    final suspendedCount = _adminUsers.where((u) => u['status'] == 'suspended' || u['kitchen_status'] == 'suspended').length;

    return Column(
      children: [
        // Search & Filter Header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
          child: Column(
            children: [
              // Search Field
              TextField(
                controller: _userSearchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by name, email, phone, or kitchen...',
                  hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                  suffixIcon: _userSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.onSurfaceVariant, size: 18),
                          onPressed: () {
                            _userSearchController.clear();
                            _loadUsers();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onSubmitted: (_) => _loadUsers(),
                onChanged: (val) {
                  // Debounced search
                  Future.delayed(const Duration(milliseconds: 400), () {
                    if (val == _userSearchController.text) {
                      _loadUsers();
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildUserFilterChip('all', 'All (${_adminUsers.length})'),
                    const SizedBox(width: 8),
                    _buildUserFilterChip('users', 'Foodies Only'),
                    const SizedBox(width: 8),
                    _buildUserFilterChip('kitchens', 'Chefs & Kitchens'),
                    const SizedBox(width: 8),
                    _buildUserFilterChip('suspended', 'Suspended ($suspendedCount)'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Users List
        Expanded(
          child: _isLoadingUsers
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _adminUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), size: 56),
                          const SizedBox(height: 12),
                          Text('No accounts found', style: AppTextStyles.headlineMd(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text('Try adjusting your search or filter keywords', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _adminUsers.length,
                        itemBuilder: (context, index) {
                          final user = _adminUsers[index];
                          final isChef = user['role'] == 'chef' || user['kitchen_id'] != null;
                          final isSuspended = user['status'] == 'suspended' || user['kitchen_status'] == 'suspended';
                          final kitchenName = user['kitchen_name'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSuspended
                                    ? Colors.orange.withValues(alpha: 0.6)
                                    : AppColors.outlineVariant.withValues(alpha: 0.2),
                                width: isSuspended ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Row: Avatar + Info + Badges
                                Row(
                                  children: [
                                    // Avatar with Status Ring
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSuspended ? Colors.orange : Colors.greenAccent,
                                          width: 2,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundImage: NetworkImage(
                                          ApiService.formatImageUrl(user['avatar'] ?? user['kitchen_avatar'] ?? ''),
                                        ),
                                        onBackgroundImageError: (_, __) {},
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Name & Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  user['name'] ?? 'Unknown User',
                                                  style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              // Role Badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isChef ? Colors.deepOrange.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isChef ? 'CHEF' : 'FOODIE',
                                                  style: TextStyle(
                                                    color: isChef ? Colors.deepOrangeAccent : Colors.lightBlueAccent,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              // Status Badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: isSuspended ? Colors.orange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  isSuspended ? 'SUSPENDED' : 'ACTIVE',
                                                  style: TextStyle(
                                                    color: isSuspended ? Colors.orange : Colors.greenAccent,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            user['email'] ?? '-',
                                            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (kitchenName != null && kitchenName.toString().isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Text(
                                                'Kitchen: $kitchenName',
                                                style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                const Divider(color: AppColors.outlineVariant, height: 1),
                                const SizedBox(height: 10),

                                // Bottom Action Buttons
                                Row(
                                  children: [
                                    // 💬 Chat Button
                                    ElevatedButton.icon(
                                      onPressed: () => _openChatWithUser(user),
                                      icon: const Icon(Icons.chat_bubble_outline, size: 15, color: Colors.white),
                                      label: const Text('Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // ⏸️ / ▶️ Suspend / Unsuspend Button
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        if (isSuspended) {
                                          _unsuspendUser(user);
                                        } else {
                                          _confirmSuspendUser(user);
                                        }
                                      },
                                      icon: Icon(
                                        isSuspended ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                        size: 16,
                                        color: isSuspended ? Colors.greenAccent : Colors.orange,
                                      ),
                                      label: Text(
                                        isSuspended ? 'Unsuspend' : 'Suspend',
                                        style: TextStyle(
                                          color: isSuspended ? Colors.greenAccent : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: isSuspended ? Colors.greenAccent : Colors.orange),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                    ),

                                    const Spacer(),

                                    // 🗑️ Permanent Delete Button
                                    IconButton(
                                      onPressed: () => _confirmDeleteUser(user),
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                      tooltip: 'Delete Account',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildUserFilterChip(String filter, String label) {
    final isSelected = _userTypeFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() => _userTypeFilter = filter);
        _loadUsers();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: PROMO BANNERS
  // ==========================================
  Widget _buildPromotionsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.surfaceContainerLow.withValues(alpha: 0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Home Banners', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                  Text('These banners appear below the Search bar', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddPromotionModal,
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Add Banner', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingPromos
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : _promotions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.campaign_outlined, color: AppColors.onSurfaceVariant, size: 64),
                          const SizedBox(height: 16),
                          Text('No promo banners yet', style: AppTextStyles.headlineMd(color: Colors.white)),
                          const SizedBox(height: 6),
                          Text('Tap "+ Add Banner" to create your first promo banner!',
                              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPromotions,
                      color: AppColors.primary,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _promotions.length,
                        itemBuilder: (context, index) {
                          final promo = _promotions[index];
                          final promoId = int.tryParse(promo['id']?.toString() ?? '0') ?? 0;
                          final isActive = promo['is_active']?.toString() == '1';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isActive ? AppColors.primary.withValues(alpha: 0.4) : AppColors.outlineVariant.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Banner Preview
                                Container(
                                  height: 150,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    image: DecorationImage(
                                      image: NetworkImage(ApiService.formatImageUrl(promo['image'] ?? '')),
                                      fit: BoxFit.cover,
                                      onError: (_, __) {},
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.8),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    alignment: Alignment.bottomLeft,
                                    child: Row(
                                      children: [
                                        if (promo['code'] != null && promo['code'].toString().isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'CODE: ${promo['code']}',
                                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                        if (promo['discount_percent'] != null && promo['discount_percent'].toString() != '0')
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade700,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '${promo['discount_percent']}% OFF',
                                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              promo['title'] ?? 'Untitled Promo',
                                              style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 17),
                                            ),
                                          ),
                                          Switch(
                                            value: isActive,
                                            activeColor: AppColors.primary,
                                            onChanged: (val) async {
                                              await ApiService.togglePromotion(promoId, val);
                                              _loadPromotions();
                                            },
                                          ),
                                        ],
                                      ),
                                      if (promo['subtitle'] != null && promo['subtitle'].toString().isNotEmpty)
                                        Text(
                                          promo['subtitle'],
                                          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                        ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            isActive ? 'Status: Live on App' : 'Status: Disabled',
                                            style: TextStyle(
                                              color: isActive ? Colors.greenAccent : AppColors.onSurfaceVariant,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  backgroundColor: AppColors.surface,
                                                  title: const Text('Delete Banner?', style: TextStyle(color: Colors.white)),
                                                  content: const Text('This will remove the promo banner permanently.', 
                                                      style: TextStyle(color: AppColors.onSurfaceVariant)),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.pop(ctx, true),
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                                                      child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                await ApiService.deletePromotion(promoId);
                                                _loadPromotions();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 3: PLATFORM STATS
  // ==========================================
  Widget _buildStatsTab() {
    final approvedChefs = _chefApplications.where((c) => c['is_verified']?.toString() == '1').length;
    final pendingChefs = _chefApplications.where((c) => c['is_verified']?.toString() == '0').length;
    final activePromos = _promotions.where((p) => p['is_active']?.toString() == '1').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Overview', style: AppTextStyles.headlineLgMobile(color: Colors.white)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Active Kitchens', '$approvedChefs', Icons.restaurant, Colors.greenAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Pending Chefs', '$pendingChefs', Icons.pending_actions, Colors.amberAccent),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Live Banners', '$activePromos', Icons.campaign, Colors.blueAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Total Applicants', '${_chefApplications.length}', Icons.groups, Colors.purpleAccent),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('Admin Actions Quick Links', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          _buildQuickActionTile(Icons.how_to_reg, 'Review Pending Applications', 'Approve or reject new chefs', () {
            setState(() {
              _chefFilter = 'pending';
              _tabController.animateTo(0);
            });
            _loadChefs();
          }),
          const SizedBox(height: 10),
          _buildQuickActionTile(Icons.add_photo_alternate, 'Create New Promo Banner', 'Add discounts for home screen', () {
            _showAddPromotionModal();
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.headlineLg(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      tileColor: AppColors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.onSurfaceVariant, size: 16),
    );
  }
}
