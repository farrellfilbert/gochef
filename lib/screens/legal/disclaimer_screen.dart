import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Disclaimer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Badge Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                        ),
                        child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GOCHEF MARKETPLACE',
                              style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Food Safety, Operations & Legal Disclaimer',
                              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: October 2026 • Effective for all Chefs & Customers',
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              number: '1',
              title: 'Independent Home Kitchens & MEHKO Operations',
              content:
                  'GoChef is a technology platform connecting independent culinary artisans and local chefs with food lovers. Meals offered on the GoChef platform are prepared in independent private home kitchens permitted under Microenterprise Home Kitchen Operation (MEHKO), Cottage Food Operation (CFO), or applicable commercial and local health ordinances.\n\nGoChef does not own, direct, employ, or operate any independent kitchen. Each chef acts as an independent contractor solely responsible for kitchen hygiene, safe food preparation, ingredient sourcing, sanitation, and adherence to county health department standards.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              number: '2',
              title: 'Food Allergy & Dietary Notice',
              content:
                  'Home kitchens may store and prepare items containing major food allergens including milk, eggs, peanuts, tree nuts, fish, shellfish, wheat, soybeans, and sesame.\n\nWhile chefs take great care, GoChef cannot guarantee that any food item is 100% free of allergen cross-contact. If you have severe or life-threatening food allergies, you must inform the chef directly in the order notes and exercise your own discretion before consuming.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              number: '3',
              title: 'Permits, Licenses & Verification',
              content:
                  'GoChef facilitates the display of chef-provided credentials, such as MEHKO permits, ServSafe certifications, food handler cards, and business licenses indicated by green verification badges.\n\nWhile GoChef conducts preliminary onboarding checks, the ultimate responsibility for maintaining valid, active municipal, county, and state permits rests solely with the independent culinary provider.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              number: '4',
              title: 'Handling, Storage & Consumption',
              content:
                  'All meals should be consumed immediately upon delivery or pickup. Any leftover perishable food must be refrigerated at or below 40°F (4°C) within two hours of preparation and reheated to an internal temperature of at least 165°F (74°C) prior to consumption.',
            ),
            const SizedBox(height: 20),

            _buildSection(
              number: '5',
              title: 'Platform Role & Limitation of Liability',
              content:
                  'GoChef Technologies Inc. provides order coordination, communication, and marketplace settlement services. To the fullest extent permitted by law, GoChef disclaims liability for any foodborne illness, adverse allergic reactions, inaccurate chef descriptions, or handling disputes between customers and independent chefs. In the event of a dispute or quality concern, GoChef Support is available 24/7 to facilitate fair mediation and refunds where appropriate.',
            ),
            const SizedBox(height: 36),

            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('I Understand & Acknowledge', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String number, required String title, required String content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(height: 1.55, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

