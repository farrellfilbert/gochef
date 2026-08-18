import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _allFaqs = [
    {
      'q': 'How do I track my live order?',
      'a': 'You can track your order in real-time from the "Tracking" bottom navigation menu or through your Order History. You\'ll see live progress: Scheduled, Preparing, Driver Pickup, and Out for Delivery with estimated time.',
    },
    {
      'q': 'How does Dine-In Booking work?',
      'a': 'When checking out, switch your order type to "Dine-In Booking". Select your preferred table reservation date and time slot. Enjoy the culinary experience directly at the chef\'s kitchen with zero delivery fee!',
    },
    {
      'q': 'Can I send photos to the chef in Live Chat?',
      'a': 'Yes! In the live chat screen with any kitchen, simply tap the camera icon next to the message input. You can attach photos of food preferences, dietary notes, or delivery landmark photos.',
    },
    {
      'q': 'Can I change my delivery address after ordering?',
      'a': 'If the order is still in "Pending" status, you can message the chef directly via Live Chat to adjust your delivery destination. You can also save multiple permanent addresses in your User Profile.',
    },
    {
      'q': 'What payment methods do you accept?',
      'a': 'We accept all major Credit and Debit Cards (Mastercard, Visa, American Express), Apple Pay, Google Pay, and Cash on Delivery.',
    },
    {
      'q': 'How do promo codes and discount vouchers work?',
      'a': 'Enter your valid promo code on the Checkout screen and tap "Apply". Your discount will be calculated automatically and deducted from your order subtotal before payment.',
    },
    {
      'q': 'How do I leave a review and rating for the chef?',
      'a': 'Once your order is marked "Completed", a ⭐ Rate Your Experience banner will appear on your tracking screen and Order History. Tap it to select 1-5 stars, choose quick feedback tags, and leave a review!',
    },
    {
      'q': 'How is the 5-mile kitchen radius calculated?',
      'a': 'Our Map Explorer automatically shows all verified private chefs and boutique kitchens located within a 5-mile radius from your location to ensure food arrives piping hot and fresh.',
    },
    {
      'q': 'What if I have severe food allergies or dietary preferences?',
      'a': 'Each dish displays detailed descriptions and allergy badges (Vegan, Halal, Gluten-Free, Nut-Free). You can also leave specific preparation notes during checkout or message the chef directly.',
    },
    {
      'q': 'How do I cancel or modify an order?',
      'a': 'Orders can be cancelled directly while still in "Pending" status. If preparation has begun, please contact the chef immediately via the in-app Live Chat or text our support line.',
    },
    {
      'q': 'What is the refund policy?',
      'a': 'If an order is cancelled or an item is unavailable, a full refund is automatically issued back to your original payment method within 1 to 3 business days.',
    },
    {
      'q': 'How can I become a Chef on GoChef x The GRUB Next Door?',
      'a': 'Go to your User Profile and tap "Become a Chef". Fill out your kitchen profile details, submit your food safety documentation, and our team will verify your kitchen within 24 hours!',
    },
    {
      'q': 'How do I contact customer support?',
      'a': 'You can reach us 24/7 through our AI Support Assistant on the Contact Support page, text us at +1 (555) 123-4567, or email support@thegrubnextdoor.com.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = _searchQuery.isEmpty
        ? _allFaqs
        : _allFaqs.where((faq) {
            return faq['q']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                faq['a']!.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
        title: const Text('Help Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // GoChef Logo Centered at Top of Page
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/GoCheflogo.png',
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(Icons.help_outline, size: 60, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'How can we help you?',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                const Text(
                  'GoChef x The GRUB Next Door Knowledge Base',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search FAQs, topics, delivery, dine-in...',
                hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white60, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
              ),
              style: const TextStyle(color: AppColors.onSurface),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Frequently Asked Questions (${filteredFaqs.length})',
            style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          if (filteredFaqs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const Icon(Icons.search_off, size: 48, color: Colors.white38),
                    const SizedBox(height: 8),
                    Text(
                      'No matching answers found for "$_searchQuery"',
                      style: const TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredFaqs.map((faq) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFaqItem(faq['q']!, faq['a']!),
                )),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(
          question,
          style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.onSurfaceVariant,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
