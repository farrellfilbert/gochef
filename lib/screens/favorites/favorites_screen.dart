import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import '../notifications/notifications_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryContainer, width: 2),
                image: const DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAU8mis0pP4cropYf_ewBNyFTgGq53qxntrTiyaVIf88KQ-osyDLkG4mckkT58h2jrGnKh06ZpQC473ANoxnVD5Zw39KV20LX9v46sSb3SSFJKZNNzVkxf5clSDYZYqHWqlCdnBflFDuoGDzjwlTZtq72B_lMiNQUi8Fq6FZXU2c17Nq9UK0t7tOO8OY03hINHRZbCxpqJ4bRcFYjdaOhFGtIMUjsm_Q0vpIQ-GTldl-OIIzcFxor18kQ'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
            icon: const Icon(Icons.notifications, color: AppColors.primary),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: TextField(
                style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Filter your favorites...',
                  hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
                  prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.secondary,
                labelStyle: AppTextStyles.headlineMd(color: AppColors.primary),
                tabs: const [
                  Tab(text: 'Meals'),
                  Tab(text: 'Kitchens'),
                ],
              ),
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMealsTab(),
                _buildKitchensTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 120),
      children: [
        _buildMealCard(
          title: 'Truffle Risotto',
          subtitle: 'Urban Gourmet Kitchen',
          price: '\$32.00',
          rating: '4.9',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBqCHamdmyHzWY44BD2HOJdBZKiRe0yGUhA0bw9NIDmOw-quVxvoE9NibZMRko85um3B3HddH_JtD8kH3XLibv8n-XPiN5V55ne4L4spXOsLznexFvnAIA_rN5Z5T_Sn3XEuQKpKgtikWZOc1Q00PcXk1H2DsIaZTmpvcffC3_Vt7QgdWWR5fq_SlvXz8jcjmCC6jsXNDJSSyvpcMeCWYRrgW-5n1senJTLdnD0V3WKexsGHt5X9u0dPA',
        ),
        const SizedBox(height: 24),
        _buildMealCard(
          title: 'Wild Mushroom Tagliatelle',
          subtitle: 'Chef Elena\'s Atelier',
          price: '\$28.50',
          rating: '4.8',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDP6G29Uk965cwwQ8OiS6HLbGNzT29gNEjRR97s9amn-YJdLzm-FtdOQso4TeJsmTd8enlfva0lZn_qxl_MtPx9_w8IvTRTWLxrFdOf6bf4_9MmFaSXh9RKF5b5t9MBwRNp51M6Az7sT3lfZX1OfZj6gi4-WxhKSO8fiyU_QqAyeYkXLQtDtDovAtQsA4-TIKk33qjDFbhg-hQCfTohXc05ue8nbJFDaeu41bByo3y0YdsbrpMUnD2WYw',
        ),
        const SizedBox(height: 24),
        _buildMealCard(
          title: 'Saffron Glazed Sea Bass',
          subtitle: 'Luxe Ocean Kitchen',
          price: '\$45.00',
          rating: '5.0',
          imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAF_TuEEoNWqJZqP1hnUQoRSSNl6QK6bLgLVUJOhjwmD_gVYRHNpxTQ51ZAfZoGk3xz3UiEPouK6VWw70icuOu0DUMrCrHWE5Kmw92nv9jeJ19oD1SR_MHVqSNQmo5Py55e0egEJGYNYKKWSYVCK1luLgfuMJc6H0REBPYLD9i-JCYJaV3c6cByV9y1n3ecZQ3xePFDShlMy3fpcdOQk9nGTzIK_Qwv1U1QbNpMZp1BvqiXgx0BNUqWIw',
        ),
      ],
    );
  }

  Widget _buildKitchensTab() {
    return ListView(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 120),
      children: [
        _buildKitchenCard(
          title: 'Urban Gourmet Kitchen',
          subtitle: 'Contemporary Fusion • 1.2 mi',
          rating: '4.9 (240+)',
          avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAfyJ0ofjcq8kSxWH35y8sDdaq-y-Q0bqU4ZoL4GuBMEaCchXl2dZkrUyYRrlRKYK--xVramO4GEWP8hbNNIA6s-LPdut57XLHc8r_Jej0GKraO8N_EIf3xg29zDDZG645tUnUX9XTA05Qfrk8B9_Uc3YsYmayhuhOulbh5ItKTcBPkY8vGcoePDajaF_Vg6NviGXfhseW0wPo4PWUtWpnT0WD4hbqqhj2k2MRRjELvKbyLwNPer4aiBA',
        ),
        const SizedBox(height: 16),
        _buildKitchenCard(
          title: 'Chef Elena\'s Atelier',
          subtitle: 'Artisanal Italian • 0.8 mi',
          rating: '4.8 (180+)',
          avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDOWZ9CphwpqABBphlDNO028ghueIMH1NoPIjseFQzFNqju-kI5px17pBS3WhIS-goUhxkpEBxGQSTNiZzH5Ih0mK94zt9_tHJklGfawuEnLS5gX2ROx2wOvgBhipSXQAgxD-H_I3R7LWfzvpfmdkzXmVvU6ucljjXJ1BbpQoWYobzgEMX0z-A-q15xoWH9zEB2t-bX8doZSYJJ1hnNFCEKD8CbOwJRjPrR-nrYVvzgObVKzk1AVIrpKw',
        ),
        const SizedBox(height: 16),
        _buildKitchenCard(
          title: 'Sakura Zenith',
          subtitle: 'Fine Dining Sushi • 2.5 mi',
          rating: '5.0 (95+)',
          avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAGA3gHDVYkV1na4L5RbvyQwvzWcKOIBhdD6UAo0w525e-UoLhAj8eKxbGGlNkf1WAm1O3SL3wY7C9rGLjvDUM172ixx5ye-2RjIaeFlE-qGa8bsUeBK6FRw174X3Bj01fQICnWQQbAL90c_wpPB6VkADnDGXMACFURWXieC9nM1s2fsU5EM_JFHJcJtFozOI3bWj5QSJsorODZ7QjvLvhQXjz1HUxuu_F4AZzkP3KMYIOB8vM2hxb4_w',
        ),
      ],
    );
  }

  Widget _buildMealCard({
    required String title,
    required String subtitle,
    required String price,
    required String rating,
    required String imageUrl,
  }) {
    return Container(
      height: 176,
      decoration: BoxDecoration(
        color: const Color(0xFF31353F).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA98890).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
              child: Image.network(imageUrl, fit: BoxFit.cover, height: double.infinity),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(height: 1.2)),
                            const SizedBox(height: 4),
                            Text(subtitle, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 14)),
                          ],
                        ),
                      ),
                      const Icon(Icons.favorite, color: AppColors.primaryContainer),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.primary, size: 16),
                          const SizedBox(width: 4),
                          Text(rating, style: AppTextStyles.labelSm(color: AppColors.onSurface)),
                        ],
                      ),
                      Text(price, style: AppTextStyles.headlineMd(color: AppColors.primary)),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildKitchenCard({
    required String title,
    required String subtitle,
    required String rating,
    required String avatar,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF31353F).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA98890).withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
              image: DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                Text(subtitle, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.primary, size: 12),
                    const SizedBox(width: 4),
                    Text(rating, style: AppTextStyles.labelSm(color: AppColors.onSurface)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.favorite, color: AppColors.primaryContainer),
        ],
      ),
    );
  }
}
