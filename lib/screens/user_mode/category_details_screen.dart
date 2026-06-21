import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_container.dart';
import 'recipe_details_screen.dart';

class CategoryDetailsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    // Mock data for the category
    List<Map<String, String>> categoryItems = [];

    if (categoryName.toLowerCase() == 'lunch') {
      categoryItems = [
        {
          'dishName': 'Classic Beef Burger',
          'chefName': 'Chef Gordon',
          'expertise': 'Grill Master',
          'rating': '4.9',
          'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600',
        },
        {
          'dishName': 'Truffle Mushroom Pasta',
          'chefName': 'Chef Mario',
          'expertise': 'Italian Specialist',
          'rating': '4.8',
          'image': 'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=600',
        },
        {
          'dishName': 'Grilled Chicken & Veggies',
          'chefName': 'Chef Sarah',
          'expertise': 'Healthy Cuisine',
          'rating': '4.7',
          'image': 'https://images.unsplash.com/photo-1598514982205-f36b96d1e8d4?w=600',
        },
      ];
    } else if (categoryName.toLowerCase() == 'salads') {
      categoryItems = [
        {
          'dishName': 'Fresh Caesar Salad',
          'chefName': 'Chef Isabella',
          'expertise': 'Salad Artisan',
          'rating': '4.9',
          'image': 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?w=600',
        },
        {
          'dishName': 'Mediterranean Green Bowl',
          'chefName': 'Chef Nico',
          'expertise': 'Organic Specialist',
          'rating': '4.8',
          'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600',
        },
        {
          'dishName': 'Quinoa & Avocado Salad',
          'chefName': 'Chef Emily',
          'expertise': 'Vegan Master',
          'rating': '4.9',
          'image': 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=600',
        },
      ];
    } else if (categoryName.toLowerCase() == 'cocktails') {
      categoryItems = [
        {
          'dishName': 'Signature Margarita',
          'chefName': 'Mixologist James',
          'expertise': 'Classic Cocktails',
          'rating': '4.9',
          'image': 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=600',
        },
        {
          'dishName': 'Minty Mojito Splash',
          'chefName': 'Mixologist Clara',
          'expertise': 'Tropical Drinks',
          'rating': '4.8',
          'image': 'https://images.unsplash.com/photo-1551538827-9c037cb4f32a?w=600',
        },
        {
          'dishName': 'Smoked Old Fashioned',
          'chefName': 'Mixologist Arthur',
          'expertise': 'Whiskey Expert',
          'rating': '4.9',
          'image': 'https://images.unsplash.com/photo-1536935338773-84f509d31122?w=600',
        },
      ];
    } else if (categoryName.toLowerCase() == 'desserts') {
      categoryItems = [
        {
          'dishName': 'Decadent Chocolate Cake',
          'chefName': 'Chef Pierre',
          'expertise': 'Pastry Chef',
          'rating': '5.0',
          'image': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=600',
        },
        {
          'dishName': 'Fluffy Morning Pancakes',
          'chefName': 'Chef Anna',
          'expertise': 'Breakfast Sweets',
          'rating': '4.8',
          'image': 'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=600',
        },
        {
          'dishName': 'French Macaron Assortment',
          'chefName': 'Chef Marie',
          'expertise': 'French Patisserie',
          'rating': '4.9',
          'image': 'https://images.unsplash.com/photo-1569864358642-9d1684040f43?w=600',
        },
      ];
    } else {
      // Fallback
      categoryItems = [
        {
          'dishName': 'Signature $categoryName Special',
          'chefName': 'Chef Isabella Martinez',
          'expertise': 'Master of $categoryName',
          'rating': '4.9',
          'image': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
        },
        {
          'dishName': 'Classic $categoryName Delight',
          'chefName': 'Chef Marco Rossi',
          'expertise': '$categoryName Specialist',
          'rating': '4.8',
          'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=600&auto=format&fit=crop',
        },
      ];
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.backgroundDark.withValues(alpha: 0.9),
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              categoryName,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.fuchsiaPrimary.withValues(alpha: 0.2),
                      AppTheme.backgroundDark,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = categoryItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailsScreen(
                              dishName: item['dishName']!,
                              heroImage: item['image']!,
                              chefName: item['chefName']!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Section
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.network(
                                  item['image']!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Details Section
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['dishName']!,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceLight,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.star, color: Colors.orange, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              item['rating']!,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Divider(color: Colors.white.withValues(alpha: 0.1)),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppTheme.fuchsiaPrimary, width: 2),
                                          image: const DecorationImage(
                                            image: NetworkImage('https://images.unsplash.com/photo-1583394838336-acd977736f90?q=80&w=200&auto=format&fit=crop'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['chefName']!,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              item['expertise']!,
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: AppTheme.fuchsiaPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary, size: 16),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: categoryItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
