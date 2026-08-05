import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'reviews_ratings_screen.dart';
import '../food/food_details_screen.dart';
import '../../services/api_service.dart';
import '../../models/kitchen_model.dart';
import '../../models/menu_item_model.dart';
import '../../models/review_model.dart';

class KitchenProfileScreen extends StatefulWidget {
  final int kitchenId;

  const KitchenProfileScreen({super.key, required this.kitchenId});

  @override
  State<KitchenProfileScreen> createState() => _KitchenProfileScreenState();
}

class _KitchenProfileScreenState extends State<KitchenProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  late Future<KitchenModel?> _kitchenFuture;

  @override
  void initState() {
    super.initState();
    _kitchenFuture = ApiService.getKitchenDetail(widget.kitchenId);
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFavorite(KitchenModel kitchen) async {
    final success = await ApiService.addFavorite(kitchenId: kitchen.id, type: 'kitchen');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to favorites'), backgroundColor: AppColors.primary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: FutureBuilder<KitchenModel?>(
        future: _kitchenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 16),
                  Text('Failed to load kitchen', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text('Go Back', style: AppTextStyles.labelSm(color: AppColors.onPrimary)),
                  )
                ],
              ),
            );
          }

          final kitchen = snapshot.data!;

          return Stack(
            children: [
              // ─── Main Content ───
              SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Section
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Background Image
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.network(
                              kitchen.coverImage.isNotEmpty ? kitchen.coverImage : kitchen.avatar,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Gradient overlay
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    AppColors.midnight.withValues(alpha: 0.5),
                                    AppColors.midnight,
                                  ],
                                  stops: const [0.5, 0.8, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Profile Card
                          Positioned(
                            bottom: -40,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.glassBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.glassBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Avatar & Info
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        transform: Matrix4.translationValues(0, -30, 0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.primaryContainer, width: 3),
                                          image: DecorationImage(
                                            image: NetworkImage(kitchen.avatar),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              kitchen.cuisineType.toUpperCase(),
                                              style: AppTextStyles.labelMono(color: AppColors.primary)
                                                  .copyWith(letterSpacing: 1),
                                            ),
                                            Text(
                                              kitchen.name,
                                              style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)
                                                  .copyWith(height: 1.1),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                            if (kitchen.location.isNotEmpty)
                                              Text(
                                                kitchen.location,
                                                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Stats & Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => ReviewsRatingsScreen(kitchenId: kitchen.id)),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star, color: AppColors.primary, size: 20),
                                            const SizedBox(width: 4),
                                            Text(
                                              kitchen.rating.toStringAsFixed(1),
                                              style: AppTextStyles.bodyMd(color: AppColors.onSurface)
                                                  .copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${kitchen.totalReviews} reviews',
                                              style: AppTextStyles.labelSm(color: AppColors.primary)
                                                  .copyWith(decoration: TextDecoration.underline),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () => _toggleFavorite(kitchen),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryContainer,
                                              foregroundColor: AppColors.onPrimaryContainer,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 24),
                                            ),
                                            child: const Text('Follow', style: TextStyle(fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                                            ),
                                            child: IconButton(
                                              icon: const Icon(Icons.share, size: 20, color: AppColors.onSurface),
                                              onPressed: () {},
                                              padding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Story Section
                    Padding(
                      padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Our Story', style: AppTextStyles.headlineMd(color: AppColors.primary)),
                          const SizedBox(height: 8),
                          Text(
                            kitchen.description,
                            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Menu Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Signature Menu', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (kitchen.menuItems != null)
                      ...kitchen.menuItems!.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                          child: _buildMenuCard(
                            context: context,
                            menuItem: item,
                          ),
                        );
                      }),
                  ],
                ),
              ),

              // ─── Top Navigation ───
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: _isScrolled ? 10 : 0, sigmaY: _isScrolled ? 10 : 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: kToolbarHeight + MediaQuery.of(context).padding.top,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                        left: 20,
                        right: 20,
                      ),
                      decoration: BoxDecoration(
                        color: _isScrolled
                            ? AppColors.surface.withValues(alpha: 0.8)
                            : Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.more_vert, color: AppColors.onSurface),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required MenuItemModel menuItem,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FoodDetailsScreen(menuItemId: menuItem.id)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(menuItem.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(menuItem.name,
                            style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Text('\$${menuItem.price.toStringAsFixed(2)}',
                          style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(menuItem.description, 
                      style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text('${menuItem.rating}', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          final success = await ApiService.addToCart(menuItem.id);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart'), backgroundColor: AppColors.primary),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('Add',
                              style: AppTextStyles.labelSm(color: AppColors.primary)
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
