import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'deals_map_screen.dart';
import 'kitchen_profile_screen.dart';
import 'recipe_details_screen.dart';
import 'category_details_screen.dart';
import '../../widgets/premium/bouncing_tap.dart';
import 'package:geolocator/geolocator.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/kitchen_provider.dart';
import '../../providers/auth_provider.dart';

class ExploreKitchensScreen extends ConsumerStatefulWidget {
  const ExploreKitchensScreen({super.key});

  @override
  ConsumerState<ExploreKitchensScreen> createState() => _ExploreKitchensScreenState();
}

class _ExploreKitchensScreenState extends ConsumerState<ExploreKitchensScreen> {
  final List<Map<String, String>> _recipesOfDay = [
    {
      'dishName': 'Slow-Cooker Chicken Tortilla Soup',
      'heroImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAr5qKm1I8ymb9-3M_aSlxJv0IlNjFf6TIozHiTcd6k7HYjxa0o_Q38QgZQoTa047_G5ow-UtbsT_XXP4Gn65V-efP_nyaIBkJqF3R4IFzfF5PJhTwbCKzMVE6k2qHCo_UKGfk2Ds6q2B9a8J0gb8b8mj16enLZr3lDNoO7vM1Ws7A0Z2DXArmb_dNz3FyoiekbYUktT45lgrjj58zoI7hpb_yjFmrp_uGQuGYLJExiQg01nOYJyU8h4aAgaU0n0Uxs5UerLJRUi2DK',
      'chefName': 'Chef Isabella Martinez',
      'duration': '4h 10min',
    },
    {
      'dishName': 'Truffle Butter Gnocchi',
      'heroImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBc9gLMczedlElKDOtOAUdKRimrvmRWcN1t7IMbSzZDVduH8RojTZWmpbZAwo_FnM3ri4GJb2Cljb5yQy2JqLo9RsBhQEjBX5MxaEbeGvSVEwxoNYYelgiuntqKdhRjSPx83zPnr1emNh4ukHeZ8kB3AG3-nmm8p5jzz67cZ_ZgmbpCmP4xIpVZOp156N6n56qC8HNYGO9W2REncLxouJEckM-Oe9JIEj53CYapSHETlPjWzXOT_jpPWNulMJZBq7hIi7LUlhU2Qz1c',
      'chefName': 'Chef Marco Rossi',
      'duration': '45min',
    },
    {
      'dishName': 'Trio de Al Pastor',
      'heroImage': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDFdoasnFuNqJYcimxW6FDtpR1ynulVhUDizLn2L8VMiGkd81vvnaGXwgm7NmVysHdm_tfe4wf8Ha4QjmFMBAtF_9vb-VTZ8fg9pKkrRhbSnFg2ZDcBDpB4-_GjEhdG9uxkbYE9VJqmi1fNUE39Iv1paHoVgD71gSYav9QIx85qiF5Tss6r9RVhEwQ6ZCPrzM3xGYNvwdFrwZUOJC09uRtREUB4MHxpMs367SldvKnVsXEWXD2v3zLlxY98m0nIYm1CrAN7WzxXs5Af',
      'chefName': 'Chef Isabella Martinez',
      'duration': '30min',
    },
    {
      'dishName': 'Grilled Tomahawk Steak',
      'heroImage': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      'chefName': 'Chef Nico',
      'duration': '1h 20min',
    }
  ];
  int _currentRecipeIndex = 0;
  
  final MapController _mapController = MapController();
  bool _isGettingLocation = false;
  LatLng? _currentLocation;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      } 

      Position position = await Geolocator.getCurrentPosition();
      final newLoc = LatLng(position.latitude, position.longitude);
      _mapController.move(newLoc, 15.0);
      
      if (mounted) {
        setState(() {
          _currentLocation = newLoc;
        });
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
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
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildHeroSection(context),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildRandomRecipe(context),
                    ),
                    const SizedBox(height: 32),
                    _buildCategories(context),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildLiveKitchens(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    final user = ref.watch(authProvider).value;
    
    return SliverAppBar(
      backgroundColor: AppTheme.backgroundDark.withValues(alpha: 0.8),
      elevation: 0,
      pinned: true,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.fuchsiaPrimary, width: 2),
              image: DecorationImage(
                image: NetworkImage(user?.avatarUrl ?? 'https://ui-avatars.com/api/?name=${user?.fullName ?? "User"}&background=ff3366&color=fff'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Santiago >',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                'GoChef',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.fuchsiaPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppTheme.fuchsiaPrimary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search clicked!')));
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppTheme.fuchsiaPrimary),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications clicked!')));
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final currentRecipe = _recipesOfDay[_currentRecipeIndex];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 4 / 5, // Portrait orientation
              child: Image.network(
                currentRecipe['heroImage']!,
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.fuchsiaPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'RECIPE OF THE DAY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentRecipe['dishName']!,
                    style: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Row(
                        children: List.generate(4, (index) => Icon(
                          Icons.bolt,
                          color: index < 3 ? Colors.orange : Colors.grey,
                          size: 16,
                        )),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${currentRecipe['duration']}',
                        style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailsScreen(
                            dishName: currentRecipe['dishName']!,
                            heroImage: currentRecipe['heroImage']!,
                            chefName: currentRecipe['chefName']!,
                          )));
                        },
                        icon: const Text('Start cooking!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        label: const Icon(Icons.play_circle, size: 20),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.fuchsiaPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRandomRecipe(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentRecipeIndex = (_currentRecipeIndex + 1) % _recipesOfDay.length;
        });
      },
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.casino, color: AppTheme.fuchsiaPrimary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Random recipe', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text('Don\'t know what to cook?', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.fuchsiaPrimary, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'name': 'Lunch', 'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCDTuvPrtfvJqKn5Z5cf5QBKAHPU4uve20N2xj-KwNDbrN3RihaL_2j8OgUNPBqbbfwuOuaeNPDeB4dM8QbZzIYC7cNjAcnY08D9aeq8V0XRIoUVClgOtCjlBY5fUUWEz913hzAu9R8290W16isRL2zXpUWhlLEE0snuAnI9kkzqa-ld9Gqf9U3WeUOiZo78qOvwQhf-45mke5FCA8WuHZZ9OCK9Y1LhnzihkGktxRSqj1GyjCnFpdzgTSx-iXo-2ZealFn7niPeLqX'},
      {'name': 'Salads', 'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCMSDSssiu6w_GALH7yUldOad32y3e63Uirl7mCbXtDgHrr9_qUKmGjOfGn2fHNwQvjiwUjDMdLVJTQd0hjOEs-e-bVtdmZtIF5jVorWOLLIgU5FnB00SSP2DTHDGwR1EfLbwTk-4HZeHmmuWQUvSVHBmXgR1QV8--GY_TevjQ-k9Fln7--8b72vi_0Vxj9le4Sm3EVeD8i0vWjHFNhLDXCtoYawfBS3EFeADCQ1kbTdsz2vlahS4hcoIvuQCeKBocun-dm9_OOGiZ6'},
      {'name': 'Cocktails', 'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuA0lNgc6X_Fh2WccRufqk0NqORZ88ejOCe7594ksrvl2prn443wfvLNvIlrLiMZQ2lr57qWIF-wyV4h7FrSdloPOkiID4Z5K9VqYmYt8jm-VbGinPbPAdDy82yn_cOCbGVu03GE0GMQmiIsXoo70YfsLyCSYsxR9PiR4Pr86b87K6iaih83_w-JTbZGnABgF9uj6Ehgy671Pemt7KqKQBXHb-VdqkxufAVB_Nt3Im7B2c_zzhMz79pwOgaVoZUZSB-OcG8ZUWT91c7J'},
      {'name': 'Desserts', 'img': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAab3imRFVceUVcPhute2Cx5xDHd5eqg7Y35w5eXSFtNtWN-duU4SmGRkfpL2IlmbN58BUxdyv-OK9yVWDq_MWjrRJn3N6dCe-0Tk8tZV49xCD9hhAMCzXBk6k0JYKoyNkYesnlh5wgDRi12HbrNmyn8pAHeqQq7-audfUS50P_lUAEiNWR3AnkotFI5gSGFTf_-_KI3di3FdvUw6uN5xrnQcoSaYV0SH0o0cJPpKIeK4qEoR646wUT8bVJ_v8lhP22spLs7PS_iYTg'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Categories', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text('View all', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.fuchsiaPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return BouncingTap(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailsScreen(categoryName: categories[index]['name']!),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(image: NetworkImage(categories[index]['img']!), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(categories[index]['name']!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveKitchens(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Live Kitchens Near You', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Consumer(
                  builder: (context, ref, child) {
                    final kitchensAsync = ref.watch(kitchenProvider);
                    final count = kitchensAsync.value?.where((k) => k.isOpen).length ?? 0;
                    return Text('$count Online', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.greenAccent));
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Map placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(-6.2088, 106.8456), // Jakarta coordinate
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c', 'd'],
                    ),
                    MarkerLayer(
                      markers: [
                        if (_currentLocation != null)
                          Marker(
                            point: _currentLocation!,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blueAccent.withValues(alpha: 0.2),
                                border: Border.all(color: Colors.blueAccent, width: 2),
                              ),
                              child: const Center(
                                child: Icon(Icons.circle, color: Colors.blueAccent, size: 16),
                              ),
                            ),
                          ),
                        Marker(
                          point: const LatLng(-6.2088, 106.8456),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: AppTheme.fuchsiaPrimary, size: 32),
                        ),
                        Marker(
                          point: const LatLng(-6.2188, 106.8556),
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.location_on, color: AppTheme.fuchsiaPrimary, size: 32),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 12, right: 12,
                  child: BouncingTap(
                    onTap: _getCurrentLocation,
                    child: GlassCard(
                      padding: const EdgeInsets.all(8),
                      child: _isGettingLocation
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppTheme.fuchsiaPrimary, strokeWidth: 2))
                        : const Icon(Icons.my_location, color: AppTheme.textPrimary, size: 20),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12, right: 12,
                  child: BouncingTap(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DealsMapScreen()),
                      );
                    },
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.fullscreen, size: 16, color: AppTheme.textPrimary),
                          const SizedBox(width: 4),
                          Text('Expand Map', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, child) {
            final kitchensAsync = ref.watch(kitchenProvider);
            return kitchensAsync.when(
              data: (kitchens) {
                if (kitchens.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text('No kitchens found.', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7))),
                    ),
                  );
                }
                return Column(
                  children: kitchens.map((kitchen) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => KitchenProfileScreen(kitchen: kitchen)));
                        },
                        child: _buildKitchenCard(
                          kitchen.name,
                          kitchen.address ?? 'Kitchen Location',
                          kitchen.rating.toString(),
                          '(0)',
                          kitchen.coverImageUrl ?? 'https://via.placeholder.com/150',
                          kitchen.isOpen,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.fuchsiaPrimary)),
              error: (e, st) => Center(child: Text('Error: $e')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildKitchenCard(String title, String subtitle, String rating, String reviews, String imgUrl, bool isOpen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
                ),
              ),
              if (isOpen)
                Positioned(
                  top: 4, left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.greenAccent, borderRadius: BorderRadius.circular(4)),
                    child: Text('LIVE', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Colors.greenAccent, size: 14),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(rating, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(width: 4),
                    Text(reviews, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
