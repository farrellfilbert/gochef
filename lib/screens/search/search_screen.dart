import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            Navigator.maybePop(context);
                          },
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Search',
                          style: AppTextStyles.headlineLgMobile(color: AppColors.primary)
                              .copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: AppColors.primary),
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
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(Icons.search, color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
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
                                  hintText: 'Search for chefs, meals, or cuisines',
                                  hintStyle: AppTextStyles.bodyMd(
                                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.4)),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.tune, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Filter Chips ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      _buildFilterChip(context, 'Nearby', isSelected: true),
                      const SizedBox(width: 12),
                      _buildFilterChip(context, 'Top Rated'),
                      const SizedBox(width: 12),
                      _buildFilterChip(context, 'Under \$15'),
                      const SizedBox(width: 12),
                      _buildFilterChip(context, 'Vegan'),
                      const SizedBox(width: 12),
                      _buildFilterChip(context, 'Gluten-Free'),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Recent Searches ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Searches',
                            style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                        Text('Clear All', style: AppTextStyles.labelSm(color: AppColors.primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildRecentSearch(context, 'Authentic Ramen'),
                        _buildRecentSearch(context, 'Vegan Sushi'),
                        _buildRecentSearch(context, 'Chef Marco'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ─── Trending Near You ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trending Near You', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    const SizedBox(height: 16),
                    _buildTrendingCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {bool isSelected = false}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchResultsScreen()),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
      ),
    );
  }

  Widget _buildRecentSearch(BuildContext context, String label) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchResultsScreen()),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 14, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
        ],
      ),
      ),
    );
  }

  Widget _buildTrendingCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchResultsScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
      height: 256,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
        image: const DecorationImage(
          image: NetworkImage(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCzP1Heyd8Kl8rTcn43JqYJ4kEuySscn7kPLPO7q2-qmeDw3ha0BR2eXOY4tY1o3RUIj4SDUUSyTWrTAitGmQXIQBym6w1h0ciWwVsCBafKQWXC7IlyaXfzZquNbhc9jxiiqJ_AGshdhlvai2lIhIzQm7bEZsOPh9Yj9avrJRfg95xmYiJ_nwHzHQ2wLTzpl0AwYzNm2kkfZ987jVzoDXM_qTsr-mocRS-OLx6QShXFp7u4WXYaZ7Lftw'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.midnight.withValues(alpha: 0.9),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('BESTSELLER',
                      style: AppTextStyles.labelSm(color: AppColors.primary)
                          .copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Text('Rainbow Poke Symphony',
                    style: AppTextStyles.headlineMd(color: Colors.white)),
                const SizedBox(height: 4),
                Text('\$18.50 • Fresh Kitchen',
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
              ],
            ),
          )
        ],
      ),
      ),
    );
  }
}
