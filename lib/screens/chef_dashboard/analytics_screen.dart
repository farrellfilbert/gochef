import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ChefAnalyticsScreen extends StatefulWidget {
  const ChefAnalyticsScreen({super.key});

  @override
  State<ChefAnalyticsScreen> createState() => _ChefAnalyticsScreenState();
}

class _ChefAnalyticsScreenState extends State<ChefAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        title: const Text('Kitchen Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kitchen Overview',
              style: AppTextStyles.headlineLgMobile(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s how Urban Gourmet Kitchen is performing today.',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            
            // Stats Grid
            Row(
              children: [
                Expanded(child: _buildStatCard('Today\'s Orders', '32', '+12%', Icons.shopping_bag)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Revenue', '\$420.50', '+8%', Icons.payments)),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatCard('Monthly Earnings', '\$5.2k', 'Top 5% Chef Rating', Icons.account_balance_wallet, isWide: true),
            
            const SizedBox(height: 32),
            Text(
              '7-Day Performance',
              style: AppTextStyles.headlineMd(color: Colors.white),
            ),
            const SizedBox(height: 16),
            
            // Placeholder for Chart
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sales', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('248', style: AppTextStyles.displayLgMobile(color: Colors.white)),
                      const SizedBox(width: 8),
                      Text('+18.4%', style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  // Fake chart bars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildChartBar(40, 'MON'),
                      _buildChartBar(60, 'TUE'),
                      _buildChartBar(55, 'WED'),
                      _buildChartBar(85, 'THU'),
                      _buildChartBar(75, 'FRI'),
                      _buildChartBar(100, 'SAT', isHighlight: true),
                      _buildChartBar(40, 'SUN'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 80), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, IconData icon, {bool isWide = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.displayLgMobile(color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primary, size: 16),
              const SizedBox(width: 4),
              Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double heightPercentage, String label, {bool isHighlight = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: heightPercentage,
          decoration: BoxDecoration(
            color: isHighlight ? AppColors.primary : AppColors.primary.withOpacity(0.4),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, color: isHighlight ? AppColors.primary : AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
