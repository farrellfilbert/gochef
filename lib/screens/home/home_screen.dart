import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../kitchen/kitchen_profile_screen.dart';
import '../food/food_details_screen.dart';
import '../search/search_results_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                            image: const DecorationImage(
                              image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCXRdPe5_MByp2tNUrIy7UsKh6b6qoLfFFfx4_VyYcOly1XAyrMfXK9FA3XGzRXOz57m6SCZVfc2Ndc6AgT6Uxw98-ucCdYyfx_l9gNdz5WtkdEGHR-z2iOQcd0RRYlTDlBQRjGd_YTaV1533HDcAV__XS2fj5896BuDL4zShrJYRxwBz74YVTmA0da0WIm-yu0P4lSn6zotP6M2DeLcMJm9ljXy5MUH7FI0mIG1AHYOYBchylw4JJ4xA'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GoChef',
                              style: AppTextStyles.headlineLgMobile(color: AppColors.primary)
                                  .copyWith(fontSize: 20),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  'University District',
                                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: AppColors.onSurfaceVariant),
                      onPressed: () {},
                    )
                  ],
                ),
              ),
            ),

            // ─── Search Bar ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SearchResultsScreen()),
                              );
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Search student chefs or meals...',
                            hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Categories ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      _buildCategoryChip('All', isSelected: true),
                      const SizedBox(width: 12),
                      _buildCategoryChip('Breakfast'),
                      const SizedBox(width: 12),
                      _buildCategoryChip('Lunch'),
                      const SizedBox(width: 12),
                      _buildCategoryChip('University Special'),
                      const SizedBox(width: 12),
                      _buildCategoryChip('Late Night'),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Promotions Carousel ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Container(
                  height: 192,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDJlpMgVZQB61othkAAirwTy8w2Q7ANbkgihdRrX-YG0Ad2t5TQatD-1gMbNYnv9wvNL1X-reQ3oZPKpaspia8k8WAu4YAeoSCG_qYS90qHBACbRbV_XPv8mBAIUu3cgJ0ho9KpI60iHh_KVu8wlWrWNmnfF8LZMc4LWwiLGBSI60EerPg0w2DPz7u_4ZTnzORjaRh0ZnCJBmUGLr9gXKtdR8FEFmva8M4pARMKVF_0Rkfy8n4YW59ooQ'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.surface,
                          AppColors.surface.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'LIMITED OFFER',
                            style: AppTextStyles.labelSm(color: AppColors.onPrimaryContainer)
                                .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '50% Off Your First Order',
                          style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)
                              .copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Exclusive to University District students',
                          style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Featured Kitchens ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Featured Kitchens', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                        Text('View All', style: AppTextStyles.labelSm(color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFeaturedKitchen(
                            context: context,
                            title: "Yosuke's Ramen Den",
                            rating: '4.9',
                            desc: 'Authentic 18-hour Tonkotsu broth',
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCOHq4p96XG_LWwhtNe8SdH_J1upongdAIAC27nZqZOnFROiKiaQveCa1vvO58XRroyJckTQXPeU0Au3L4O8DsRcLf2YUbGjMEjg_U3xF-8DYc1yHbkGCRlMq6ssc6Z8xdplq6n38sSTEgU3MJaGXE-XHCUlNYqPL-SsP3sGyNxOvF2S_jYaMLE0zXmqSBswOBs6qAJ1KQgvzdrkZnJ1E8ywpvU6Dwvtkx41xfqVSyRs8kGjrgJOMMixg',
                          ),
                          _buildFeaturedKitchen(
                            context: context,
                            title: 'Global Flavors',
                            rating: '4.8',
                            desc: 'Fusion dishes by Chef Elena Rossi',
                            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAfF1lflw4R1iVUwl7mM42yMijAXNVFnMeJ_1oxsxekf5vzK1PO3XqHliVJ-6LOuiZsIyIpo_u1kpEw1DNuoXzXzSWzkSwBiMByZA9n3Ksof_trWvQj6ZR1TcIWeCZBV5rqK5ALRzPSflnMsZe8Vv0aqj5os_2AdZ-RXtyyryNdtWrjD_q_gnOBCSCOStNR3neVk83xtIgbu0Wky3r_aUivUz5QlI8w7kwR2FKscUrA2rT4M1lyMdfwUA',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Popular Meals ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0, left: 20.0, right: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Popular Meals', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    const SizedBox(height: 16),
                    _buildPopularMeal(
                      context: context,
                      title: 'Spicy Miso Ramen',
                      chef: "Yosuke's Ramen Den",
                      price: '\$18.50',
                      time: '25-35 min',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuChoW2fsu6vnq8tJNACYGqSsbVsVKL2YBgQbgBHV9z7ouQC_47Q68zWWuLCVlXm73malDMJbuKHyyS9y6w1tGNc8SLaOpEsaFX3TENOEZeyJTvfP6RQxXrHasiUOLDVmuT_hihtfwFUSIoG9uIMjLApfrqDf-WRHJUmLu_6h3CXOu-evRWv7rHo5Fbe_ThjvoN5OtPcPsBCCWwPZubzysSwy4pu6tm7gtuOx-nDRG1pBg2B5QVdBgQrlg',
                    ),
                    const SizedBox(height: 16),
                    _buildPopularMeal(
                      context: context,
                      title: 'Wild Mushroom Tagliatelle',
                      chef: 'Global Flavors',
                      price: '\$24.00',
                      time: '20-25 min',
                      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAY9drekVqItHkRSizimEMTTdsK4ve3MIu0mcLrXEoOQ06dnP-VRjuHDjnzxsdB2JoGSkiAEiZ82J2TvgNCRD9ED3qXtBeixIGsLl9rsWW3NKZCFWRBsvGWWWMSwSz5ea6IJP5TEtPAAcoGXlWVW4G2IGomNd3MK9lWJa84HZFp4_Xvqse9fNQU_vC5flxpcTqYTH0LliHPuEsUMlYWt7z-7TmZVwYAtpChjB9Qj_V2k9BiDjiZ5-_0gA',
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

  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? Colors.transparent : AppColors.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMono(
            color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildFeaturedKitchen({
    required BuildContext context,
    required String title,
    required String rating,
    required String desc,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KitchenProfileScreen()),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.glassBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Column(
          children: [
            Container(
              height: 224,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.primary, size: 16),
                          const SizedBox(width: 4),
                          Text(rating, style: AppTextStyles.labelSm(color: AppColors.onSurface)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      const SizedBox(height: 4),
                      Text(desc, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text('VEGAN',
                        style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontSize: 10)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChefCard(String name, String desc, String badge, String imgUrl) {
    return Container(
      width: 256,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 192,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imgUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(badge,
                        style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontSize: 10)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(name, style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text(desc, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('+12 joined', style: AppTextStyles.labelSm(color: AppColors.primaryFixedDim).copyWith(fontSize: 10)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text('Order Now',
                    style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontSize: 10)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPopularMeal({
    required BuildContext context,
    required String title,
    required String chef,
    required String price,
    required String time,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FoodDetailsScreen()),
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
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
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
                      Text(title, style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontSize: 16)),
                      Text(price,
                          style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(chef, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(time, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('Add to Cart',
                            style: AppTextStyles.labelSm(color: AppColors.onPrimaryContainer)
                                .copyWith(fontWeight: FontWeight.bold)),
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
