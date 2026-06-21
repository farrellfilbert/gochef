import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String dishName;
  final String heroImage;
  final String chefName;

  const RecipeDetailsScreen({
    super.key,
    this.dishName = 'Truffle Butter Gnocchi',
    this.heroImage = 'https://lh3.googleusercontent.com/aida-public/AB6AXuBc9gLMczedlElKDOtOAUdKRimrvmRWcN1t7IMbSzZDVduH8RojTZWmpbZAwo_FnM3ri4GJb2Cljb5yQy2JqLo9RsBhQEjBX5MxaEbeGvSVEwxoNYYelgiuntqKdhRjSPx83zPnr1emNh4ukHeZ8kB3AG3-nmm8p5jzz67cZ_ZgmbpCmP4xIpVZOp156N6n56qC8HNYGO9W2REncLxouJEckM-Oe9JIEj53CYapSHETlPjWzXOT_jpPWNulMJZBq7hIi7LUlhU2Qz1c',
    this.chefName = 'Chef Marco Rossi',
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  int _selectedTab = 0; // 0 for Ingredients, 1 for Preparation Steps

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAiRuCn4HRdlkrlRJz6Lv9oX9qR9GaDZZS_F7MYwXhPWcCd2JUg2j2ow01IkYrq7eoCdM16NjuzGO4tOnRcEpthtsYfpwxGsao1BzgGYk5hayekJCvZ2z0SFtVQV7pnA7clor_wb6kjZ1BR80PNNmEJWwiJBMj1spSj7k6Ovu_Au2aLTWrIUbMfxvS3mD15uRq6xk8POAOxhZ8eXK3_qEJ7ilZiCQalqc1V-6_Sg2Mz1uXr74TqwMawONNDWXrWoIMhssAqofURQfiM'),
            ),
            const SizedBox(width: 8),
            Text('THE GRUB', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.fuchsiaPrimary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_basket, color: AppTheme.fuchsiaPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(),
            const SizedBox(height: 24),
            _buildChefActionRow(),
            const SizedBox(height: 24),
            _buildStorySection(),
            const SizedBox(height: 24),
            _buildTabs(),
            const SizedBox(height: 16),
            _selectedTab == 0 ? _buildIngredientsList() : _buildStepsList(),
            const SizedBox(height: 32),
            _buildNutritionalInfo(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(widget.heroImage),
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.bottomLeft,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, AppTheme.backgroundDark.withValues(alpha: 0.9)],
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.withValues(alpha: 0.5))),
                  child: Text('CHEF FAVORITE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.5))),
                  child: Text('PREMIUM DISH', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.dishName, style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppTheme.fuchsiaPrimary),
                const SizedBox(width: 4),
                Text('45 MINS', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
                const SizedBox(width: 16),
                const Icon(Icons.leaderboard, size: 16, color: AppTheme.fuchsiaPrimary),
                const SizedBox(width: 4),
                Text('INTERMEDIATE', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChefActionRow() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAWe3JNREYf8B5RS6R2FL1LFUwl58hABv_f1NHnORTxQ2j25u8PRymp_VJqRC_MMKdkAn6tYDWu9Nxk_BFuPRCVojjAYfIxoNJmGyJ6cumD05b3v0SOD4Sn9LNiG1KHECbDfevHu-vMsFAuSyu2qEFwC-EB7diYQ58vo1aOA5bIusW0yQ30d3jk1yMGuQ6y9EfHgplVh_paiPBTSxzlFYj-HqHdHtY-EeKgeZkWXAOzDP--tqWO2EhAPSuvfHK-Nu0RN5ZK0GJ-Qz9j'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.chefName, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text('Handmade Pasta Specialist • 4.9 ★', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.shopping_cart, size: 18),
            label: const Text('Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.fuchsiaPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Story behind the dish', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
        const SizedBox(height: 8),
        Text(
          'This recipe was passed down through three generations of the Rossi family in Umbria. During the autumn truffle harvest, my grandmother would hand-roll each gnocchi before dawn. The secret isn\'t just in the truffles, but in the specific variety of potato and the "light touch" when kneading the dough to ensure every bite is like a cloud.',
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _selectedTab == 0 ? AppTheme.fuchsiaPrimary : Colors.transparent, width: 2))),
              alignment: Alignment.center,
              child: Text('INGREDIENTS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _selectedTab == 0 ? AppTheme.fuchsiaPrimary : AppTheme.textSecondary)),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = 1),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _selectedTab == 1 ? AppTheme.fuchsiaPrimary : Colors.transparent, width: 2))),
              alignment: Alignment.center,
              child: Text('STEPS', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _selectedTab == 1 ? AppTheme.fuchsiaPrimary : AppTheme.textSecondary)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsList() {
    final ingredients = [
      '500g Russet potatoes',
      '150g \'00\' flour',
      '1 Free-range egg yolk',
      '50g Unsalted butter',
      '10g Fresh black truffle',
      '30g Grana Padano',
      'Sea salt to taste',
    ];
    
    return Column(
      children: ingredients.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: GlassCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(item, style: GoogleFonts.inter(color: AppTheme.textPrimary))),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildStepsList() {
    final steps = [
      {'title': 'Prepare the Potatoes', 'desc': 'Boil whole potatoes in salted water until tender. Peel while hot and pass through a potato ricer onto a clean surface.'},
      {'title': 'Form the Dough', 'desc': 'Create a well in the potatoes, add flour and egg yolk. Gently fold together until a soft dough forms. Do not overwork.'},
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        int idx = entry.key;
        var step = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.2), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text('${idx + 1}', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(step['title']!, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    const SizedBox(height: 4),
                    Text(step['desc']!, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNutritionalInfo() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('NUTRITIONAL INFO', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildNutritionalRow('Calories', '420 kcal'),
          const Divider(color: Colors.white24, height: 24),
          _buildNutritionalRow('Protein', '12g'),
          const Divider(color: Colors.white24, height: 24),
          _buildNutritionalRow('Fat', '18g'),
        ],
      ),
    );
  }

  Widget _buildNutritionalRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
        Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }
}
