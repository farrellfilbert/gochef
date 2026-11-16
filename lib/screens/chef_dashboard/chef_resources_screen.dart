import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class FoodFlipItem {
  final int id;
  final String title;
  final String headline;
  final String tagline;
  final String budget;
  final int servings;
  final String price;
  final String grossSales;
  final String qualification;
  final IconData icon;

  const FoodFlipItem({
    required this.id,
    required this.title,
    required this.headline,
    required this.tagline,
    required this.budget,
    required this.servings,
    required this.price,
    required this.grossSales,
    required this.qualification,
    required this.icon,
  });
}

class ChefResourcesScreen extends StatefulWidget {
  const ChefResourcesScreen({super.key});

  @override
  State<ChefResourcesScreen> createState() => _ChefResourcesScreenState();
}

class _ChefResourcesScreenState extends State<ChefResourcesScreen> {
  final List<FoodFlipItem> _flips = const [
    FoodFlipItem(
      id: 1,
      title: "Quesadilla Payday",
      headline: "A tortilla is the beginning",
      tagline: "Your filling, crisp, and salsa make it yours.",
      budget: "\$18",
      servings: 10,
      price: "\$8",
      grossSales: "\$80",
      qualification: "Trial idea: 10 orders at \$8 = \$80 sales against an \$18 ingredient budget, before other costs. Open My Kitchen.",
      icon: Icons.local_pizza_outlined,
    ),
    FoodFlipItem(
      id: 2,
      title: "Breakfast Burrito Business",
      headline: "Your morning routine",
      tagline: "Could be somebody else’s breakfast plan.",
      budget: "\$22",
      servings: 10,
      price: "\$9",
      grossSales: "\$90",
      qualification: "Trial idea: 10 at \$9 = \$90 sales; \$22 ingredient budget. Count every cost before you flip.",
      icon: Icons.breakfast_dining,
    ),
    FoodFlipItem(
      id: 3,
      title: "Loaded Potato Love",
      headline: "Humble potato",
      tagline: "Main-character treatment.",
      budget: "\$18",
      servings: 10,
      price: "\$8",
      grossSales: "\$80",
      qualification: "Trial idea: 10 at \$8 = \$80 sales; \$18 ingredient budget. Give the neighborhood a reason to order yours.",
      icon: Icons.dinner_dining,
    ),
    FoodFlipItem(
      id: 4,
      title: "Garlic Noodles, Big Energy",
      headline: "Simple ingredients",
      tagline: "A sauce worth coming back for.",
      budget: "\$16",
      servings: 8,
      price: "\$9",
      grossSales: "\$72",
      qualification: "Trial idea: 8 at \$9 = \$72 sales; \$16 ingredient budget. Start with one dish you do well.",
      icon: Icons.ramen_dining,
    ),
    FoodFlipItem(
      id: 5,
      title: "Fried Rice, Fresh Opportunity",
      headline: "Make the rice the reason",
      tagline: "Consistency is part of the recipe.",
      budget: "\$16",
      servings: 8,
      price: "\$9",
      grossSales: "\$72",
      qualification: "Trial idea: 8 at \$9 = \$72 sales; \$16 ingredient budget. Consistency is part of the recipe.",
      icon: Icons.rice_bowl,
    ),
    FoodFlipItem(
      id: 6,
      title: "French Toast That Flips",
      headline: "Breakfast deserves drama",
      tagline: "Plate it beautifully, price it honestly.",
      budget: "\$17",
      servings: 10,
      price: "\$8",
      grossSales: "\$80",
      qualification: "Trial idea: 10 at \$8 = \$80 sales; \$17 ingredient budget. Plate it beautifully, price it honestly.",
      icon: Icons.bakery_dining,
    ),
    FoodFlipItem(
      id: 7,
      title: "Stack Your Pancakes",
      headline: "Start with a stack",
      tagline: "Build with repeat customers.",
      budget: "\$15",
      servings: 10,
      price: "\$7",
      grossSales: "\$70",
      qualification: "Trial idea: 10 at \$7 = \$70 sales; \$15 ingredient budget. Know your cost per plate.",
      icon: Icons.cake,
    ),
    FoodFlipItem(
      id: 8,
      title: "Baked Ziti, Built to Share",
      headline: "One tray",
      tagline: "Ten reasons to come back.",
      budget: "\$25",
      servings: 10,
      price: "\$10",
      grossSales: "\$100",
      qualification: "Trial idea: 10 at \$10 = \$100 sales; \$25 ingredient budget. Batch smart.",
      icon: Icons.restaurant,
    ),
    FoodFlipItem(
      id: 9,
      title: "Chickpea Curry Come-Up",
      headline: "Let the spice do the talking",
      tagline: "Big flavor starts with care.",
      budget: "\$24",
      servings: 8,
      price: "\$11",
      grossSales: "\$88",
      qualification: "Trial idea: 8 at \$11 = \$88 sales; \$24 ingredient budget. Big flavor starts with care.",
      icon: Icons.soup_kitchen,
    ),
    FoodFlipItem(
      id: 10,
      title: "Chili With a Plan",
      headline: "Comfort food signature",
      tagline: "Build a bowl people remember.",
      budget: "\$18",
      servings: 8,
      price: "\$9",
      grossSales: "\$72",
      qualification: "Trial idea: 8 at \$9 = \$72 sales; \$18 ingredient budget. Build a bowl people remember.",
      icon: Icons.outdoor_grill,
    ),
    FoodFlipItem(
      id: 11,
      title: "Lentil Love Bowls",
      headline: "Everyday ingredients",
      tagline: "Deserve extraordinary seasoning.",
      budget: "\$16",
      servings: 8,
      price: "\$9",
      grossSales: "\$72",
      qualification: "Trial idea: 8 at \$9 = \$72 sales; \$16 ingredient budget. Warm the neighborhood.",
      icon: Icons.spa,
    ),
    FoodFlipItem(
      id: 12,
      title: "Baked Mac, Main Character",
      headline: "If they ask you to bring the mac",
      tagline: "Take the hint. Put your signature on the menu.",
      budget: "\$22",
      servings: 8,
      price: "\$10",
      grossSales: "\$80",
      qualification: "Trial idea: 8 at \$10 = \$80 sales; \$22 ingredient budget. Put your signature on the menu.",
      icon: Icons.lunch_dining,
    ),
    FoodFlipItem(
      id: 13,
      title: "Personal Pizza Potential",
      headline: "Small pizza",
      tagline: "Serious personality. Give yours a signature finish.",
      budget: "\$20",
      servings: 10,
      price: "\$8",
      grossSales: "\$80",
      qualification: "Trial idea: 10 at \$8 = \$80 sales; \$20 ingredient budget. Give yours a signature finish.",
      icon: Icons.local_pizza,
    ),
    FoodFlipItem(
      id: 14,
      title: "Egg Salad, Elevated",
      headline: "The sandwich is simple",
      tagline: "Your touch is the difference.",
      budget: "\$17",
      servings: 10,
      price: "\$8",
      grossSales: "\$80",
      qualification: "Trial idea: 10 at \$8 = \$80 sales; \$17 ingredient budget.",
      icon: Icons.egg_alt,
    ),
    FoodFlipItem(
      id: 15,
      title: "Tuna Melt Momentum",
      headline: "Golden bread. Melty cheese.",
      tagline: "A reason to order again.",
      budget: "\$24",
      servings: 8,
      price: "\$10",
      grossSales: "\$80",
      qualification: "Trial idea: 8 at \$10 = \$80 sales; \$24 ingredient budget.",
      icon: Icons.set_meal,
    ),
    FoodFlipItem(
      id: 16,
      title: "BBQ Chickpea Sliders",
      headline: "Two little sliders",
      tagline: "A whole lot of flavor.",
      budget: "\$22",
      servings: 10,
      price: "\$9",
      grossSales: "\$90",
      qualification: "Trial idea: 10 plates at \$9 = \$90 sales; \$22 ingredient budget.",
      icon: Icons.fastfood,
    ),
    FoodFlipItem(
      id: 17,
      title: "Overnight Oats, Next Move",
      headline: "Give somebody’s busy morning",
      tagline: "A better beginning.",
      budget: "\$16",
      servings: 8,
      price: "\$6",
      grossSales: "\$48",
      qualification: "Trial idea: 8 at \$6 = \$48 sales; \$16 ingredient budget.",
      icon: Icons.eco,
    ),
    FoodFlipItem(
      id: 18,
      title: "Banana Pudding Payoff",
      headline: "The group chat knows",
      tagline: "Who makes the pudding. Let the neighborhood meet you.",
      budget: "\$18",
      servings: 10,
      price: "\$6",
      grossSales: "\$60",
      qualification: "Trial idea: 10 cups at \$6 = \$60 sales; \$18 ingredient budget. Let the neighborhood meet you.",
      icon: Icons.icecream,
    ),
    FoodFlipItem(
      id: 19,
      title: "Brownie Box Business",
      headline: "Two brownies",
      tagline: "One very good decision.",
      budget: "\$14",
      servings: 12,
      price: "\$6",
      grossSales: "\$72",
      qualification: "Trial idea: 12 boxes at \$6 = \$72 sales; \$14 ingredient budget.",
      icon: Icons.cookie,
    ),
    FoodFlipItem(
      id: 20,
      title: "Elote Cup Comeback",
      headline: "Sweet corn. Tangy lime.",
      tagline: "Your own finishing touch.",
      budget: "\$16",
      servings: 8,
      price: "\$6",
      grossSales: "\$48",
      qualification: "Trial idea: 8 at \$6 = \$48 sales; \$16 ingredient budget.",
      icon: Icons.grass,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12141C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Chef Resources x Food Flips',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF161A24), Color(0xFF090A0F)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'FOOD FLIP / HOW TO EARN',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.auto_graph, color: AppColors.primary, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${_flips.length} Blueprints',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Turn High-Margin Dishes Into Real Neighborhood Revenue',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.25),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore proven dish blueprints with target ingredient budgets, selling prices, and projected gross earnings. Perfect for launching your weekly trial specials.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _flips[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _buildFoodFlipCard(item),
                  );
                },
                childCount: _flips.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodFlipCard(FoodFlipItem item) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.45), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Subtle background glow
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP: FOOD FLIP / HOW TO EARN
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.bolt, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'FOOD FLIP / HOW TO EARN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${item.id.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // MIDDLE: Hero plate & headlines
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E212B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Icon(item.icon, color: AppColors.primary, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.headline,
                                style: TextStyle(
                                  color: AppColors.primary.withValues(alpha: 0.95),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.tagline,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13.5,
                        height: 1.35,
                      ),
                    ),
                    const Spacer(),

                    // BOTTOM: Red reverse-arrow card motif
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.95),
                            const Color(0xFFB91C1C),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.reply_all_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'ECONOMICS BREAKDOWN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMetricCol('BUDGET', item.budget),
                              const Icon(Icons.arrow_forward, color: Colors.white70, size: 16),
                              _buildMetricCol('PRICING', '${item.servings} × ${item.price}'),
                              const Icon(Icons.arrow_forward, color: Colors.white70, size: 16),
                              _buildMetricCol('GROSS SALES', item.grossSales, isHighlight: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Visible qualification & action
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF151822),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.qualification,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? const Color(0xFFFACC15) : Colors.white,
            fontSize: isHighlight ? 15 : 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

