import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../core/theme.dart';
import '../widgets/chef_card.dart';
import '../widgets/food_category_item.dart';
import '../screens/category_detail_screen.dart';
import '../screens/dummy_detail_screen.dart';
import '../screens/location_selection_screen.dart';
import '../screens/map_search_screen.dart';
import '../widgets/premium/glass_container.dart';
import '../widgets/premium/bouncing_tap.dart';
import '../providers/menu_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _currentLocation = 'Detecting location...';
  late PageController _promoPageController;
  Timer? _promoTimer;
  int _currentPromoPage = 0;

  final List<String> _promoImages = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=1000&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _promoPageController = PageController(initialPage: 0);
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_promoPageController.hasClients) {
        _currentPromoPage = (_currentPromoPage + 1) % _promoImages.length;
        _promoPageController.animateToPage(
          _currentPromoPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoPageController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _currentLocation = 'Location access denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _currentLocation = 'Location access permanently disabled');
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        setState(() {
          _currentLocation = '${placemark.street ?? ''}, ${placemark.locality ?? placemark.subAdministrativeArea ?? ''}';
          if (_currentLocation.startsWith(', ')) {
             _currentLocation = _currentLocation.substring(2);
          }
          if (_currentLocation.isEmpty || _currentLocation == ', ') {
            _currentLocation = 'Unknown location';
          }
        });
      }
    } catch (e) {
      setState(() => _currentLocation = 'Failed to load location');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildSearchBar(context),
                    const SizedBox(height: 32),
                    _buildCategories(),
                    const SizedBox(height: 32),
                    _buildPromoBanner(),
                    const SizedBox(height: 32),
                    _buildFeaturedChefs(context),
                    const SizedBox(height: 32),
                    _buildLiveMenu(context, ref),
                    const SizedBox(height: 120), // padding for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            final selectedLocation = await Navigator.push<String>(
              context,
              MaterialPageRoute(builder: (context) => const LocationSelectionScreen()),
            );
            if (selectedLocation != null) {
              setState(() {
                _currentLocation = selectedLocation;
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.mapPin, color: AppTheme.fuchsiaPrimary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Current Location',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(LucideIcons.chevronDown, color: AppTheme.textSecondary, size: 16),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _currentLocation,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _showProfileSettings(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surfaceLight,
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.fuchsiaPrimary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return BouncingTap(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MapSearchScreen()));
      },
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 64,
        borderRadius: BorderRadius.circular(32),
        child: Row(
          children: [
            const Icon(LucideIcons.search, color: AppTheme.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search chefs, restaurants, or cuisines...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.fuchsiaPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(LucideIcons.slidersHorizontal, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Special Promos For You',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _promoPageController,
            itemCount: _promoImages.length,
            onPageChanged: (index) {
              _currentPromoPage = index;
            },
            itemBuilder: (context, index) {
              return BouncingTap(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DummyDetailScreen(title: 'Special Discount ${index + 1}0%')));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(_promoImages[index]),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Special Discount ${index + 1}0%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'image': 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=200&q=80', 'name': 'Nusantara'},
      {'image': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=200&q=80', 'name': 'Italian'},
      {'image': 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=200&q=80', 'name': 'Japanese'},
      {'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=200&q=80', 'name': 'Healthy'},
      {'image': 'https://images.unsplash.com/photo-1550617931-e17a7b70dce2?w=200&q=80', 'name': 'Pastry'},
      {'image': 'https://images.unsplash.com/photo-1544025162-d76694265947?w=200&q=80', 'name': 'Western'},
      {'image': 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=200&q=80', 'name': 'Asian'},
      {'image': 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=200&q=80', 'name': 'Dessert'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What do you want to eat today?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final categoryName = categories[index]['name'] as String;
            return FoodCategoryItem(
              imageUrl: categories[index]['image'] as String,
              name: categoryName,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailScreen(
                      categoryName: categoryName,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeaturedChefs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Best Chefs Around You',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DummyDetailScreen(title: 'All Chefs')));
              },
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.fuchsiaPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 1,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              return const ChefCard();
            },
          ),
        ),
      ],
    );
  }

  void _showProfileSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withValues(alpha: 0.8),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.fuchsiaPrimary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Budi Santoso',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'budi.santoso@email.com',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),
                _buildProfileMenuItem(LucideIcons.user, 'Edit Profile'),
                _buildProfileMenuItem(LucideIcons.creditCard, 'Payment Methods'),
                _buildProfileMenuItem(LucideIcons.settings, 'App Settings'),
                _buildProfileMenuItem(LucideIcons.helpCircle, 'Help Center'),
                const SizedBox(height: 16),
                _buildProfileMenuItem(LucideIcons.logOut, 'Logout', isDestructive: true),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isDestructive 
                  ? null
                  : AppTheme.glassGradient,
              color: isDestructive 
                  ? Colors.red.withOpacity(0.1) 
                  : null,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDestructive 
                    ? Colors.red.withOpacity(0.2) 
                    : Colors.white.withOpacity(0.05),
              ),
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.redAccent : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDestructive ? Colors.redAccent : AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMenu(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(menuProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Fresh from Chefs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  color: AppTheme.fuchsiaPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        menuAsync.when(
          data: (menuItems) {
            final availableItems = menuItems.where((item) => item.isAvailable).take(5).toList();
            if (availableItems.isEmpty) {
              return const Center(child: Text('No fresh menu available', style: TextStyle(color: AppTheme.textSecondary)));
            }
            return SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: availableItems.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final item = availableItems[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          item.image,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.price,
                                style: const TextStyle(
                                  color: AppTheme.fuchsiaPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.fuchsiaPrimary)),
          error: (err, stack) => const Center(child: Text('Error loading menu', style: TextStyle(color: Colors.red))),
        ),
      ],
    );
  }
}
