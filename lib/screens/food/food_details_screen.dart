import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class FoodDetailsScreen extends StatefulWidget {
  const FoodDetailsScreen({super.key});

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  int _quantity = 1;
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
            padding: const EdgeInsets.only(bottom: 120), // For bottom action bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAY9drekVqItHkRSizimEMTTdsK4ve3MIu0mcLrXEoOQ06dnP-VRjuHDjnzxsdB2JoGSkiAEiZ82J2TvgNCRD9ED3qXtBeixIGsLl9rsWW3NKZCFWRBsvGWWWMSwSz5ea6IJP5TEtPAAcoGXlWVW4G2IGomNd3MK9lWJa84HZFp4_Xvqse9fNQU_vC5flxpcTqYTH0LliHPuEsUMlYWt7z-7TmZVwYAtpChjB9Qj_V2k9BiDjiZ5-_0gA',
                        fit: BoxFit.cover,
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
                    ],
                  ),
                ),

                // Content Body (shifted up slightly to overlap gradient)
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title & Quick Stats
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Wild Mushroom Tagliatelle',
                                    style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface)
                                        .copyWith(height: 1.1),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$24.00',
                                    style: AppTextStyles.headlineMd(color: AppColors.primary)
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.glassBackground,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: AppColors.primary, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.9',
                                    style: AppTextStyles.labelMono(color: AppColors.onSurface),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Utility Bar
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.glassBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            children: [
                              _buildUtilityItem(Icons.schedule, '20-25 min'),
                              _buildVerticalDivider(),
                              _buildUtilityItem(Icons.local_fire_department, '640 kcal'),
                              _buildVerticalDivider(),
                              _buildUtilityItem(Icons.workspace_premium, 'Signature'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Description
                        Text('Description', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                        const SizedBox(height: 8),
                        Text(
                          'Indulge in our artisan-crafted tagliatelle, hand-cut daily and tossed with a rich medley of seasonal foraged wild mushrooms. Finished with a decadent drizzle of white truffle oil, fresh Italian parsley, and aged Grana Padano. A sophisticated urban take on a woodland classic.',
                          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 32),

                        // Ingredients
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Ingredients', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                            TextButton(
                              onPressed: () {},
                              child: Text('View All', style: AppTextStyles.labelSm(color: AppColors.primary)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildIngredient(Icons.grain, 'Pasta'),
                              _buildIngredient(Icons.forest, 'Mushroom'),
                              _buildIngredient(Icons.water_drop, 'Truffle'), // fallback for opacity icon
                              _buildIngredient(Icons.edit, 'Parmesan'),      // fallback for drive_file_rename
                              _buildIngredient(Icons.hd, 'Parsley'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Nutritional Value
                        Text('Nutritional Value', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildNutritionBox('Protein', '18g', AppColors.tertiary)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildNutritionBox('Fat', '22g', AppColors.primary)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildNutritionBox('Carbs', '74g', AppColors.onSurfaceVariant)),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Personalize
                        Text('Personalize Your Dish', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                        const SizedBox(height: 12),
                        _buildPersonalizeOption('Extra Aged Parmesan', '+\$2.50'),
                        _buildPersonalizeOption('Fresh Black Truffle Shavings', '+\$8.00'),
                        _buildPersonalizeOption('Gluten-Free Pasta Option', '+\$3.00'),
                        const SizedBox(height: 32),

                        // Reviews
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('What Others are Saying', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                            Text(
                              '1.2k Reviews',
                              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)
                                  .copyWith(decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildReview('Marco R.', '"The truffle aroma hits you the moment it arrives. Simply divine texture on the pasta."', true),
                        _buildReview('Elena S.', '"Best vegetarian pasta in the city. The mushrooms are so meaty and flavorful."', false),
                      ],
                    ),
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
                      _buildNavIconButton(Icons.share, () {}),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Bottom Action Bar ───
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 24,
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(context).padding.bottom == 0 ? 24 : MediaQuery.of(context).padding.bottom,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glassBackground,
                    border: Border(
                      top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Quantity Selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 20),
                              onPressed: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                              color: AppColors.onSurface,
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                            SizedBox(
                              width: 32,
                              child: Text(
                                '$_quantity',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 20),
                              onPressed: () => setState(() => _quantity++),
                              color: AppColors.onSurface,
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Add to Cart Button
                      Expanded(
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF4A90), Color(0xFFBA005E)],
                            ),
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(26),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.shopping_basket, color: Colors.white, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add to Cart',
                                    style: AppTextStyles.headlineMd(color: Colors.white)
                                        .copyWith(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
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
        color: AppColors.glassBackground,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.onSurface),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildUtilityItem(IconData icon, String text) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(height: 4),
          Text(
            text,
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.outlineVariant.withValues(alpha: 0.2),
    );
  }

  Widget _buildIngredient(IconData icon, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.glassBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSm(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineMd(color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizeOption(String title, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: false, // UI only
                  onChanged: (val) {},
                  fillColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppColors.primary;
                    }
                    return Colors.transparent;
                  }),
                  side: BorderSide(color: AppColors.outline, width: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.bodyMd(color: AppColors.onSurface),
              ),
            ],
          ),
          Text(
            price,
            style: AppTextStyles.labelMono(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildReview(String name, String review, bool isPrimary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isPrimary
                          ? AppColors.primaryContainer.withValues(alpha: 0.2)
                          : AppColors.tertiaryContainer.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      size: 16,
                      color: isPrimary ? AppColors.primary : AppColors.tertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: AppTextStyles.labelSm(color: AppColors.onSurface)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => const Icon(Icons.star, color: AppColors.primary, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review,
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                .copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
