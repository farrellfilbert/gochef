import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'reviews_ratings_screen.dart';
import '../food/food_details_screen.dart';
import '../../services/api_service.dart';
import '../../models/kitchen_model.dart';
import '../../models/menu_item_model.dart';
import '../chat/chat_screen.dart';
import '../cart/cart_screen.dart';

class KitchenProfileScreen extends StatefulWidget {
  final int kitchenId;
  const KitchenProfileScreen({super.key, required this.kitchenId});
  @override
  State<KitchenProfileScreen> createState() => _KitchenProfileScreenState();
}

class _KitchenProfileScreenState extends State<KitchenProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  bool _isFollowing = false;
  int _cartCount = 0;
  late Future<KitchenModel?> _kitchenFuture;

  @override
  void initState() {
    super.initState();
    _kitchenFuture = ApiService.getKitchenDetail(widget.kitchenId);
    _loadCartCount();
    ApiService.getFavorites(type: 'kitchen').then((favs) {
      if (mounted) {
        setState(() {
          _isFollowing = favs.any((f) => f['id'] == widget.kitchenId);
        });
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 50 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  Future<void> _loadCartCount() async {
    final cart = await ApiService.getCart();
    if (mounted) {
      setState(() => _cartCount = cart.length);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleFavorite(KitchenModel kitchen) async {
    setState(() => _isFollowing = !_isFollowing);
    final success = await ApiService.addFavorite(kitchenId: kitchen.id, type: 'kitchen');
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isFollowing ? 'Added to favorites' : 'Removed from favorites'), backgroundColor: AppColors.primary),
      );
    } else if (!success && mounted) {
      setState(() => _isFollowing = !_isFollowing);
    }
  }

  void _openFullscreenImage(BuildContext context, String imageUrl, String tag) {
    Navigator.push(context, PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      pageBuilder: (ctx, animation, _) => FadeTransition(
        opacity: animation,
        child: _FullscreenImageViewer(imageUrl: imageUrl, heroTag: tag),
      ),
    ));
  }

  void _shareKitchen(BuildContext context, KitchenModel kitchen) {
    final desc = kitchen.description.length > 100
        ? kitchen.description.substring(0, 100)
        : kitchen.description;
    final parts = [
      'Check out ' + kitchen.name + ' on GoChef!',
      '',
      'Location: ' + kitchen.location,
      'Rating: ' + kitchen.rating.toStringAsFixed(1) + ' (' + kitchen.totalReviews.toString() + ' reviews)',
      'Cuisine: ' + kitchen.cuisineType,
      '',
      if (desc.isNotEmpty) desc,
      '',
      'Order now on GoChef!',
    ];
    final box = context.findRenderObject() as RenderBox?;
    Share.share(parts.join('\n'), sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null);
  }

  void _shareMenuItem(BuildContext context, MenuItemModel menuItem, String kitchenName) {
    final desc = menuItem.description.length > 100
        ? menuItem.description.substring(0, 100)
        : menuItem.description;
    final parts = [
      'Check out ' + menuItem.name + ' from ' + kitchenName + ' on GoChef!',
      '',
      if (desc.isNotEmpty) desc,
      '',
      'Price: \$' + menuItem.price.toStringAsFixed(2),
      'Rating: ' + menuItem.rating.toString(),
      '',
      'Order now on GoChef!',
    ];
    final box = context.findRenderObject() as RenderBox?;
    Share.share(parts.join('\n'), sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null);
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
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load kitchen', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text('Go Back', style: AppTextStyles.labelSm(color: AppColors.onPrimary)),
              ),
            ]));
          }
          final kitchen = snapshot.data!;
          return Stack(children: [
            SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Hero / Cover Section
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: Stack(clipBehavior: Clip.none, children: [
                    // Cover Image - tap to fullscreen
                    GestureDetector(
                      onTap: () {
                        final coverUrl = kitchen.coverImage.isNotEmpty ? kitchen.coverImage : kitchen.avatar;
                        _openFullscreenImage(context, coverUrl, 'cover_' + kitchen.id.toString());
                      },
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Hero(
                          tag: 'cover_' + kitchen.id.toString(),
                          child: Image.network(
                            kitchen.coverImage.isNotEmpty ? kitchen.coverImage : kitchen.avatar,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // Gradient overlay
                    Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.midnight.withValues(alpha: 0.5), AppColors.midnight],
                        stops: const [0.5, 0.8, 1.0],
                      ),
                    )))),
                    // Tap to view hint
                    Positioned(
                      top: 60, right: 12,
                      child: IgnorePointer(child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.45), borderRadius: BorderRadius.circular(12)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.zoom_out_map, color: Colors.white70, size: 14),
                          const SizedBox(width: 4),
                          Text('Tap to view', style: AppTextStyles.labelSm(color: Colors.white70)),
                        ]),
                      )),
                    ),
                    // Profile Card
                    Positioned(
                      bottom: -40, left: 20, right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.glassBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.glassBorder),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: Column(children: [
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            // Avatar - tap to fullscreen
                            Transform.translate(
                              offset: const Offset(0, -30),
                              child: GestureDetector(
                                onTap: () => _openFullscreenImage(context, kitchen.avatar, 'avatar_' + kitchen.id.toString()),
                                child: Hero(
                                  tag: 'avatar_' + kitchen.id.toString(),
                                  child: Container(
                                    width: 80, height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.primaryContainer, width: 3),
                                      image: DecorationImage(image: NetworkImage(kitchen.avatar), fit: BoxFit.cover),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        width: 22, height: 22,
                                        margin: const EdgeInsets.only(bottom: 2, right: 2),
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.zoom_in, size: 13, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(kitchen.cuisineType.toUpperCase(), style: AppTextStyles.labelMono(color: AppColors.primary).copyWith(letterSpacing: 1)),
                              Text(kitchen.name, style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface).copyWith(height: 1.1), maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (kitchen.location.isNotEmpty)
                                Text(kitchen.location, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                            ])),
                          ]),
                          const SizedBox(height: 8),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            GestureDetector(
                              onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewsRatingsScreen(kitchenId: kitchen.id))); },
                              child: Row(children: [
                                const Icon(Icons.star, color: AppColors.primary, size: 20),
                                const SizedBox(width: 4),
                                Text(kitchen.rating.toStringAsFixed(1), style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Text('\ reviews', style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(decoration: TextDecoration.underline)),
                              ]),
                            ),
                            Row(children: [
                              ElevatedButton(
                                onPressed: () => _toggleFavorite(kitchen),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isFollowing ? AppColors.surfaceContainerHigh : AppColors.primaryContainer,
                                  foregroundColor: _isFollowing ? AppColors.onSurface : AppColors.onPrimaryContainer,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                ),
                                child: Text(_isFollowing ? 'Following' : 'Follow', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              _iconCircleButton(icon: Icons.chat_bubble_outline, onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(
                                  otherParticipantId: kitchen.userId.toString(),
                                  otherParticipantName: kitchen.name,
                                  otherParticipantAvatar: kitchen.avatar,
                                  isOnline: true,
                                )));
                              }),
                              const SizedBox(width: 8),
                              Builder(
                                builder: (btnContext) => _iconCircleButton(
                                  icon: Icons.share, 
                                  onTap: () => _shareKitchen(btnContext, kitchen),
                                ),
                              ),
                            ]),
                          ]),
                        ]),
                      ),
                    ),
                  ]),
                ),
                // Our Story
                Padding(
                  padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Our Story', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    if (kitchen.cuisineType.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        kitchen.cuisineType,
                        style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.w500),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      kitchen.description,
                      style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(height: 1.6, fontSize: 15),
                    ),
                  ]),
                ),
                const SizedBox(height: 32),
                // Atmosphere Gallery
                if (kitchen.atmosphereImages.isNotEmpty) ...[
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('Atmosphere', style: AppTextStyles.headlineMd(color: AppColors.onSurface))),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: kitchen.atmosphereImages.map((img) => _buildPhotoItem(context, img)).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                // Menu
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Text('Signature Menu', style: AppTextStyles.headlineMd(color: AppColors.onSurface))),
                const SizedBox(height: 16),
                if (kitchen.menuItems != null)
                  ...kitchen.menuItems!.map((item) => Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                    child: _buildMenuCard(context: context, menuItem: item, kitchenName: kitchen.name),
                  )),
              ]),
            ),
            // Top Navigation Bar
            Positioned(
              top: 0, left: 0, right: 0,
              child: ClipRRect(child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _isScrolled ? 10 : 0, sigmaY: _isScrolled ? 10 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 20, right: 20),
                  decoration: BoxDecoration(color: _isScrolled ? AppColors.surface.withValues(alpha: 0.8) : Colors.transparent),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: 0.5), shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CartScreen()),
                            ).then((_) => _loadCartCount());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                                if (_cartCount > 0)
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                      child: Text(
                                        '$_cartCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Share.share('Check out ${kitchen.name} on The Grub Next Door: https://thegrubnextdoor.com');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              )),
            ),
          ]);
        },
      ),
    );
  }

  Widget _iconCircleButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5))),
      child: IconButton(icon: Icon(icon, size: 20, color: AppColors.onSurface), onPressed: onTap, padding: EdgeInsets.zero),
    );
  }

  Widget _buildPhotoItem(BuildContext context, String imageUrl) {
    return GestureDetector(
      onTap: () => _openFullscreenImage(context, imageUrl, 'atm_' + imageUrl.hashCode.toString()),
      child: Hero(
        tag: 'atm_' + imageUrl.hashCode.toString(),
        child: Container(
          width: 200,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.zoom_out_map, color: Colors.white, size: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required MenuItemModel menuItem,
    required String kitchenName,
  }) {
    return GestureDetector(
      onTap: () { Navigator.push(context, MaterialPageRoute(builder: (context) => FoodDetailsScreen(menuItemId: menuItem.id))); },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.glassBackground, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.glassBorder)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: NetworkImage(menuItem.image), fit: BoxFit.cover)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(menuItem.name, style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Text('\$' + menuItem.price.toStringAsFixed(2), style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            Text(menuItem.description, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                const Icon(Icons.star, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(menuItem.rating.toString(), style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
              ]),
              Row(children: [
                // Share menu button
                Builder(
                  builder: (btnContext) => GestureDetector(
                    onTap: () => _shareMenuItem(btnContext, menuItem, kitchenName),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(color: AppColors.outlineVariant.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.share, size: 13, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text('Share', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ),
                ),
                // Add to cart button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FoodDetailsScreen(menuItemId: menuItem.id)),
                    ).then((_) => _loadCartCount());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: AppColors.onPrimary, size: 14),
                        const SizedBox(width: 4),
                        Text('Add', style: AppTextStyles.labelSm(color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ]),
            ]),
          ])),
        ]),
      ),
    );
  }
}

// Fullscreen Image Viewer
class _FullscreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String heroTag;
  const _FullscreenImageViewer({required this.imageUrl, required this.heroTag});
  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  final TransformationController _transformationController = TransformationController();
  @override
  void dispose() { _transformationController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(children: [
          Positioned.fill(child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(color: Colors.black.withValues(alpha: 0.85)),
          )),
          Center(child: Hero(
            tag: widget.heroTag,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.8,
              maxScale: 5.0,
              child: Image.network(
                widget.imageUrl,
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return Center(child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes! : null,
                    color: AppColors.primary,
                  ));
                },
              ),
            ),
          )),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 22),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0, right: 0,
            child: Center(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.pinch, color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text('Pinch to zoom  *  Tap to close', style: AppTextStyles.labelSm(color: Colors.white70)),
              ]),
            )),
          ),
        ]),
      ),
    );
  }
}
