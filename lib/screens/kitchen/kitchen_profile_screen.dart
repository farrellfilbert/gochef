import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'reviews_ratings_screen.dart';

class KitchenProfileScreen extends StatefulWidget {
  const KitchenProfileScreen({super.key});

  @override
  State<KitchenProfileScreen> createState() => _KitchenProfileScreenState();
}

class _KitchenProfileScreenState extends State<KitchenProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Stack(
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
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuAfF1lflw4R1iVUwl7mM42yMijAXNVFnMeJ_1oxsxekf5vzK1PO3XqHliVJ-6LOuiZsIyIpo_u1kpEw1DNuoXzXzSWzkSwBiMByZA9n3Ksof_trWvQj6ZR1TcIWeCZBV5rqK5ALRzPSflnMsZe8Vv0aqj5os_2AdZ-RXtyyryNdtWrjD_q_gnOBCSCOStNR3neVk83xtIgbu0Wky3r_aUivUz5QlI8w7kwR2FKscUrA2rT4M1lyMdfwUA',
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
                                      image: const DecorationImage(
                                        image: NetworkImage(
                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuBZt0ObO6z0v5-LjUuvVRMd81KNSVwCQxsL00OH_RFd8-7Gt227umclELZItuuNNo397io3aumUupK8uFc6hyGg_00VcVz90Dm1ScA-l7b4_7gwbSc54FqZitxlDtZGYt58bqSh8-eolZgVtrudfDD25-43hgIRu3_AfWKQlj5EMPl4G7FgRJz0ocH8Nua-Y1Sp-GYJqjB6bLjdN5JrFMVdRniAWoqiqFs2NMTBbrbDI-Tq371xgpH97g',
                                        ),
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
                                          'Global Flavors Collective',
                                          style: AppTextStyles.labelMono(color: AppColors.primary)
                                              .copyWith(letterSpacing: 1),
                                        ),
                                        Text(
                                          'Chef Elena Rossi',
                                          style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)
                                              .copyWith(height: 1.1),
                                        ),
                                        Text(
                                          'Executive Chef',
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
                                        MaterialPageRoute(builder: (context) => const ReviewsRatingsScreen()),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, color: AppColors.primary, size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          '4.9',
                                          style: AppTextStyles.bodyMd(color: AppColors.onSurface)
                                              .copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '200+ reviews',
                                          style: AppTextStyles.labelSm(color: AppColors.primary)
                                              .copyWith(decoration: TextDecoration.underline),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {},
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
                        'Chef Elena Rossi\'s culinary odyssey began in the sun-drenched hills of Tuscany, where she learned the alchemy of pasta-making from her nonna. After refining her craft in Michelin-starred kitchens across Europe, she moved to the heart of the city to launch the Global Flavors Collective. Elena\'s cooking is a love letter to her heritage, blending authentic family recipes with metropolitan sophistication.',
                        style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Kitchen Gallery
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kitchen Gallery', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      Row(
                        children: [
                          Text('View All', style: AppTextStyles.labelSm(color: AppColors.primary)),
                          const Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildGalleryImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBueb3j-wo1R2JSehOkgon8Lyw52zWb0WY6uXTUmxk5RTw8nCv8ppuMs8AR4HQ-0AloGJ6TK8kxr3G06MCpeEvuLaTyJSTfOOZWmROMzdG9LjyV1AH9HeJCtt7whS8FoJBTq_gBk-bNmv9qrbPXTsiIg-06RnTJscXekb_QmwAkjCEuLBtCupwO7VaG6YFdFhsFQz42UDOE0Iw0DOKA9jFkW1yVHc-j1PJgjGI1dQOsMA0KXXYlSLepxw'),
                      const SizedBox(width: 12),
                      _buildGalleryImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCtEDy8aN5-CvgRcCwzYr41ShXyxgtQYFNCet1fJ-mBveoBbtH9KQ3xyvi9rHHuspCAxmo8uEbi63nEFgELs8cHs5UzvNus-OCL3u9e63XIKKAeBOxYBc0nR8jfU1XI_gsUpNBc5hrbYMlQv8COp62WG2xO6Sf1SNPxa2KaSKiohrPGdYNM2_0pcW3lMcMYcuLVQfLNgzqWNIoDXjPVqbwhBY8gAhM0T3hEq0RhsN-itjn7ZweFSL5_Rw'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Today's Menu
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's Menu", style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        title: 'Wild Mushroom Tagliatelle',
                        price: '\$18.00',
                        desc: 'Fresh hand-cut pasta with foraged wild mushrooms, aged parmesan, and a drizzle of truffle essence.',
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBueb3j-wo1R2JSehOkgon8Lyw52zWb0WY6uXTUmxk5RTw8nCv8ppuMs8AR4HQ-0AloGJ6TK8kxr3G06MCpeEvuLaTyJSTfOOZWmROMzdG9LjyV1AH9HeJCtt7whS8FoJBTq_gBk-bNmv9qrbPXTsiIg-06RnTJscXekb_QmwAkjCEuLBtCupwO7VaG6YFdFhsFQz42UDOE0Iw0DOKA9jFkW1yVHc-j1PJgjGI1dQOsMA0KXXYlSLepxw',
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        title: 'Black Truffle Risotto',
                        price: '\$22.50',
                        desc: 'Creamy carnaroli rice slow-cooked with vegetable broth, finished with fresh black truffle shavings.',
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBxJkvDivB7bvgGVdLUZ0vtqrArhNou0EsparzfHWYSrq7MBKkW17W0hpzxrVysuxTefUiESwI_BTlVfVrP7ndBUBElkE8qLaQjdzd3aK7U5L3sWSznH1F2gJqzDviZjrhxk9zsOKYV0qUHDklB8LIR30GulhWLT8ZbDTO6xqx0Kha8dZo8ESVpzP1PTm8OhOMHb0RSD-CViGq7QQrJaGrQ9-x7UhB3umlOP5I0p1iNxK4MvbGGZB5pKA',
                      ),
                    ],
                  ),
                ),
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
                    color: _isScrolled ? AppColors.surface.withValues(alpha: 0.8) : Colors.transparent,
                    border: _isScrolled
                        ? Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1)))
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildNavIconButton(Icons.arrow_back, () {
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      }),
                      if (_isScrolled)
                        Text(
                          'Kitchen Profile',
                          style: AppTextStyles.headlineMd(color: AppColors.primary),
                        )
                      else
                        const SizedBox(),
                      _buildNavIconButton(Icons.share, () {}),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: _isScrolled ? Colors.transparent : AppColors.glassBackground,
        shape: BoxShape.circle,
        border: _isScrolled ? null : Border.all(color: AppColors.glassBorder),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildGalleryImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        url,
        width: 250,
        height: 140,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String price,
    required String desc,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
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
                      child: Text(
                        title,
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface)
                            .copyWith(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      price,
                      style: AppTextStyles.bodyMd(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: const Text('Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimaryContainer,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
