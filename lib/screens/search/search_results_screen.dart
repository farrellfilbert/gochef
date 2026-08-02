import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../home/home_screen.dart'; // To reuse some navigation or mock data if needed

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Stack(
        children: [
          // ─── Main Content ───
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: 130, // Space for fixed header & filters
                bottom: 100, // Space for bottom nav (if we show it)
                left: 20,
                right: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results Summary
                  Text(
                    '24 KITCHENS & DISHES FOUND',
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)
                        .copyWith(letterSpacing: 2),
                  ),
                  const SizedBox(height: 24),

                  // Featured Kitchens
                  Text(
                    'Featured Kitchens',
                    style: AppTextStyles.headlineMd(color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  _buildKitchenCard(
                    title: "Yosuke's Ramen Den",
                    rating: '4.9',
                    subtitle: 'Specializing in 18-hour Tonkotsu broth',
                    distance: '0.8 mi',
                    time: '25-35 min',
                    tag: 'Bestseller',
                    tagColor: AppColors.primary,
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCOHq4p96XG_LWwhtNe8SdH_J1upongdAIAC27nZqZOnFROiKiaQveCa1vvO58XRroyJckTQXPeU0Au3L4O8DsRcLf2YUbGjMEjg_U3xF-8DYc1yHbkGCRlMq6ssc6Z8xdplq6n38sSTEgU3MJaGXE-XHCUlNYqPL-SsP3sGyNxOvF2S_jYaMLE0zXmqSBswOBs6qAJ1KQgvzdrkZnJ1E8ywpvU6Dwvtkx41xfqVSyRs8kGjrgJOMMixg',
                  ),
                  const SizedBox(height: 16),
                  _buildKitchenCard(
                    title: 'Green Lotus Umami',
                    rating: '4.7',
                    subtitle: 'Elevated vegan & gluten-free ramen',
                    distance: '1.4 mi',
                    tag: 'Vegan',
                    tagColor: AppColors.tertiary,
                    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAXK4edMmEzXw2x_pmuvvWB9k4sDZBiomusvhxjVo4AlfBkdOqCbQ8_xaUT90ad5vCHULQ_ziDMUsGRe-8Nx7zMznm_w2qiMt_9EFUqD8jsbKoynDkYh6LCxfhknxCmt4nxE7IH1yQby2U7m6HaAkmlgwbo2YFDhoF-UmlAYS5eBhKAR6UTzjDFmGmFiZZ5EIjDqWEkJlZ_UhN1ZmzTIIAgX5yJUwENp_PrWGNY5LLH-r4voWJ1mppIDQ',
                  ),
                  const SizedBox(height: 32),

                  // Matching Dishes
                  Text(
                    'Matching Dishes',
                    style: AppTextStyles.headlineMd(color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75, // Adjust for image + text
                    children: [
                      _buildDishCard(
                        title: 'Spicy Miso Ramen',
                        kitchen: "By Yosuke's Ramen Den",
                        price: '\$18.50',
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuChoW2fsu6vnq8tJNACYGqSsbVsVKL2YBgQbgBHV9z7ouQC_47Q68zWWuLCVlXm73malDMJbuKHyyS9y6w1tGNc8SLaOpEsaFX3TENOEZeyJTvfP6RQxXrHasiUOLDVmuT_hihtfwFUSIoG9uIMjLApfrqDf-WRHJUmLu_6h3CXOu-evRWv7rHo5Fbe_ThjvoN5OtPcPsBCCWwPZubzysSwy4pu6tm7gtuOx-nDRG1pBg2B5QVdBgQrlg',
                      ),
                      _buildDishCard(
                        title: 'Black Garlic Shoyu',
                        kitchen: 'By Midnight Umami',
                        price: '\$19.00',
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBVKXYkqOxLxoUX7suR3F4lyzH1qPm5ij2BYzyTCtML0YSAWavxbSMHaVScTSvn1qM8S87uZkaOCYtKwQczuePmV3w_MCZIZQOm_JDNbz14zeZG7SEpiB7UWsyP3-X7iyEGBFrWaTsB-uz0d3T2wYwkqgshLrH5z_9v3sbxcND2odmxQbExce8lZq9S1DLTFTnfOf2OSAu4k9qgIq1wVPq4SfclYPh0rC0M9SVtvrK1i9zq7ng01-Lkag',
                      ),
                      _buildDishCard(
                        title: 'Truffle Shio Ramen',
                        kitchen: 'By Luxe Kitchen',
                        price: '\$24.00',
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAmqD7bsCvr098T5AgGNZpEHap_tpwfktFfmDCV2dC288WNdR-goSl2MuKu9wGIMzpjpB8mP95qDVRwCWqVLHg93UhrInWjI_YSbHAvjAcgr-JRsdUSI7FgwCB_GC0r6oPSncJPZXsJWLpzGk8uKBimDeOlFyyjp-hSEQXffR4qQVRvn-Q8hcgw5cD8pGiQjgdmyKECk0MO305WfiNiqJ9w2jHtNc-ldgjO8Ix6AHGqcNZ7xs8kwEWXig',
                      ),
                      _buildDishCard(
                        title: 'Vegan TanTanmen',
                        kitchen: 'By Green Lotus Umami',
                        price: '\$17.50',
                        imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBtRIUCE8s2ppXGJHHjfu2ksfKco5VQOQ9aP49yH2KcvHDtSPy_VeO3v1_hVw9fsPiOIGVovoaoh0aaM_WTRO_CtONa04YkrRWdnaAPjA44_FCyDfr_MET1JiDTBXNhCrPjzyofHmPg_YeoWsKkrd1OmAYvh2rigveBQzIZg_U_KNLoCX1qbLGebz62lanllblzJk0aq7WohAsyierWzqwkByLVM51dT_NOAgglbh36V9J4KotmJBYfBA',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Top AppBar (Sticky Search Header) ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: AppColors.surface.withValues(alpha: 0.8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search Bar Row
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 16,
                          left: 20,
                          right: 20,
                          bottom: 16,
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                              onPressed: () {
                                if (Navigator.canPop(context)) Navigator.pop(context);
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 16),
                                    const Icon(Icons.search, color: AppColors.onSurfaceVariant, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: TextEditingController(text: 'Authentic Ramen'),
                                        style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.tune, color: AppColors.primary, size: 20),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                        child: Row(
                          children: [
                            _buildFilterChip('Sort by: Relevance', true, hasDropdown: true),
                            _buildFilterChip('Price: \$\$', false),
                            _buildFilterChip('Rating: 4.5+', false),
                            _buildFilterChip('Distance: < 2mi', false),
                            _buildFilterChip('Dietary', false, hasAdd: true),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.ghostBorder),
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

  Widget _buildFilterChip(String label, bool isSelected, {bool hasDropdown = false, bool hasAdd = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryContainer : AppColors.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm(
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            ),
          ),
          if (hasDropdown) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            ),
          ],
          if (hasAdd) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.add,
              size: 16,
              color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKitchenCard({
    required String title,
    required String rating,
    required String subtitle,
    required String distance,
    String? time,
    required String tag,
    required Color tagColor,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              width: 96,
              height: 96,
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
                            .copyWith(fontSize: 16, height: 1.2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: AppColors.primary, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: AppTextStyles.labelSm(color: AppColors.onSurface)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(distance, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                        if (time != null) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.schedule, size: 14, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(time, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: tagColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        tag,
                        style: AppTextStyles.labelSm(color: tagColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard({
    required String title,
    required String kitchen,
    required String price,
    required String imageUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Price Tag
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      price,
                      style: AppTextStyles.labelSm(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Add Button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4A90), Color(0xFFBA005E)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTextStyles.headlineMd(color: AppColors.onSurface)
              .copyWith(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          kitchen,
          style: AppTextStyles.labelMono(color: AppColors.onSurfaceVariant)
              .copyWith(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
