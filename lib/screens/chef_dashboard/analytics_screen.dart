import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../widgets/notification_bell.dart';

class ChefAnalyticsScreen extends StatefulWidget {
  const ChefAnalyticsScreen({super.key});

  @override
  State<ChefAnalyticsScreen> createState() => _ChefAnalyticsScreenState();
}

class _ChefAnalyticsScreenState extends State<ChefAnalyticsScreen> {
  late Future<Map<String, dynamic>?> _analyticsFuture;
  String _kitchenName = 'your kitchen';

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _loadData();
  }

  Future<Map<String, dynamic>?> _loadData() async {
    final user = await ApiService.getProfile();
    if (user != null && user.kitchenId != null) {
      final parsedId = int.tryParse(user.kitchenId!) ?? 0;
      if (parsedId > 0) {
        final kitchen = await ApiService.getKitchenDetail(parsedId);
        if (kitchen != null && mounted) {
          setState(() {
            _kitchenName = kitchen.name;
          });
        }
        return await ApiService.getKitchenAnalytics(parsedId);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        title: const Text('Kitchen Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: NotificationBell(iconColor: Colors.white),
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
              'Here\'s how $_kitchenName is performing today.',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            
            // Stats Grid & Real 7-Day Performance
            FutureBuilder<Map<String, dynamic>?>(
              future: _analyticsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                
                final data = snapshot.data;
                final todaysOrders = data?['todays_orders']?.toString() ?? '0';
                final revenue = data?['revenue'] != null ? '\$${(data!['revenue'] as num).toStringAsFixed(2)}' : '\$0.00';
                final monthly = data?['monthly'] != null ? '\$${(data!['monthly'] as num).toStringAsFixed(2)}' : '\$0.00';
                final totalOrders = data?['total_orders']?.toString() ?? '0';

                final sevenDaySales = data?['seven_day_sales'] != null ? '\$${(data!['seven_day_sales'] as num).toStringAsFixed(2)}' : '\$0.00';
                final sevenDayOrders = data?['seven_day_orders']?.toString() ?? '0';

                final List rawDaily = data?['daily_performance'] as List? ?? [];
                final List<Map<String, dynamic>> dailyList = rawDaily.map((e) => Map<String, dynamic>.from(e)).toList();

                double maxSale = 1.0;
                for (var d in dailyList) {
                  final sale = (d['sales'] as num?)?.toDouble() ?? 0.0;
                  if (sale > maxSale) maxSale = sale;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('Today\'s Orders', todaysOrders, 'Total orders today', Icons.shopping_bag)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard('Revenue', revenue, 'Total revenue', Icons.payments)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard('Monthly Earnings', monthly, 'Total $totalOrders orders lifetime', Icons.account_balance_wallet, isWide: true),
                    const SizedBox(height: 32),
                    Text(
                      '7-Day Performance',
                      style: AppTextStyles.headlineMd(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 220,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('7-Day Revenue', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                              Text('$sevenDayOrders orders past 7 days', style: AppTextStyles.labelSm(color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(sevenDaySales, style: AppTextStyles.displayLgMobile(color: Colors.white)),
                          const Spacer(),
                          if (dailyList.isEmpty)
                            Center(child: Text('No order data for past 7 days', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)))
                          else
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: dailyList.map((dayData) {
                                final label = dayData['day']?.toString() ?? '';
                                final sales = (dayData['sales'] as num?)?.toDouble() ?? 0.0;
                                final isToday = dayData['is_today'] == true;
                                final heightPct = (sales / maxSale) * 65.0 + 10.0;

                                return _buildChartBar(heightPct, label, isHighlight: isToday, salesAmount: sales);
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
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
                  color: AppColors.primary.withValues(alpha: 0.1),
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

  Widget _buildChartBar(double heightPercentage, String label, {bool isHighlight = false, double salesAmount = 0.0}) {
    return Tooltip(
      message: '$label: \$${salesAmount.toStringAsFixed(2)}',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (salesAmount > 0)
            Text(
              '\$${salesAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 9,
                color: isHighlight ? AppColors.primary : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 4),
          Container(
            width: 32,
            height: heightPercentage.clamp(10.0, 80.0),
            decoration: BoxDecoration(
              color: isHighlight ? AppColors.primary : AppColors.primary.withValues(alpha: salesAmount > 0 ? 0.6 : 0.25),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isHighlight ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
