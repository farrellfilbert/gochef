import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/order_model.dart';
import '../../utils/web_js.dart';
import '../../widgets/notification_bell.dart';

class ChefAnalyticsScreen extends StatefulWidget {
  const ChefAnalyticsScreen({super.key});

  @override
  State<ChefAnalyticsScreen> createState() => _ChefAnalyticsScreenState();
}

class _ChefAnalyticsScreenState extends State<ChefAnalyticsScreen> {
  late Future<Map<String, dynamic>?> _analyticsFuture;
  String _kitchenName = 'your kitchen';
  int? _kitchenId;
  bool _isGeneratingReport = false;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _loadData();
  }

  Future<Map<String, dynamic>?> _loadData() async {
    final user = await ApiService.getProfile();
    if (user.kitchenId != null) {
      final parsedId = int.tryParse(user.kitchenId!) ?? 0;
      if (parsedId > 0) {
        _kitchenId = parsedId;
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

  Future<void> _downloadChefReport() async {
    if (_isGeneratingReport) return;
    setState(() => _isGeneratingReport = true);

    try {
      List<OrderModel> orders = [];
      if (_kitchenId != null && _kitchenId! > 0) {
        orders = await ApiService.getKitchenOrders(_kitchenId!);
      } else {
        orders = await ApiService.getOrders(forChef: true);
      }

      // Generate CSV Content
      final StringBuffer csv = StringBuffer();
      csv.writeln('GoChef - Official Chef Earnings & Sales Report');
      csv.writeln('Kitchen: "$_kitchenName"');
      csv.writeln('Generated: "${DateTime.now().toIso8601String()}"');
      csv.writeln('Total Orders: ${orders.length}');
      csv.writeln('');
      csv.writeln('Date,Time,Order ID,Customer,Meal Items,Total Portions,Sales Amount (\$),Status');

      double totalSales = 0.0;
      int totalMeals = 0;

      for (var o in orders) {
        totalSales += o.totalAmount;
        
        // Parse date and time
        String dateStr = '';
        String timeStr = '';
        if (o.createdAt.isNotEmpty) {
          final parts = o.createdAt.split('•');
          if (parts.length >= 2) {
            dateStr = parts[0].trim();
            timeStr = parts[1].trim();
          } else {
            dateStr = o.createdAt;
          }
        }

        // Format items
        final itemsStr = o.items.map((it) => '${it.name} (x${it.quantity})').join('; ');
        final int orderPortions = o.items.fold(0, (sum, it) => sum + it.quantity);
        totalMeals += orderPortions > 0 ? orderPortions : 1;

        csv.writeln(
          '"$dateStr","$timeStr","${o.orderNumber}","${o.customerName}","${itemsStr.replaceAll('"', '""')}","${orderPortions > 0 ? orderPortions : 1}","${o.totalAmount.toStringAsFixed(2)}","${o.status}"',
        );
      }

      csv.writeln('');
      csv.writeln(',,,,TOTAL MEALS SOLD:,$totalMeals,GROSS SALES:,\$${totalSales.toStringAsFixed(2)}');

      final csvContent = csv.toString();
      final filename = 'Chef_Report_${_kitchenName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.csv';

      // 1. Download on Web via WebJs
      WebJs.downloadFile(filename, csvContent, mimeType: 'text/csv');

      // 2. Share sheet on mobile / dialog preview
      if (mounted) {
        _showReportSuccessSheet(orders.length, totalSales, totalMeals, csvContent, filename);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingReport = false);
    }
  }

  void _showReportSuccessSheet(int orderCount, double totalSales, int totalMeals, String csvContent, String filename) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chef Report Ready',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        filename,
                        style: const TextStyle(color: Colors.white60, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Total Sales', '\$${totalSales.toStringAsFixed(2)}', Colors.greenAccent),
                  Container(width: 1, height: 36, color: Colors.white12),
                  _buildSummaryItem('Meals Sold', totalMeals.toString(), AppColors.primary),
                  Container(width: 1, height: 36, color: Colors.white12),
                  _buildSummaryItem('Orders', orderCount.toString(), Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Share.share(csvContent, subject: 'Chef Earnings & Sales Report - $_kitchenName');
                    },
                    icon: const Icon(Icons.share, color: Colors.white, size: 18),
                    label: const Text('Share / Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.done, color: Colors.white, size: 18),
                    label: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kitchen Overview',
                        style: AppTextStyles.headlineLgMobile(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Here\'s how $_kitchenName is performing today.',
                        style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingReport ? null : _downloadChefReport,
                icon: _isGeneratingReport
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.file_download_outlined, color: Colors.white, size: 20),
                label: Text(
                  _isGeneratingReport ? 'Generating Report...' : 'Download Chef Report',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
              ),
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
                final revVal = double.tryParse(data?['revenue']?.toString() ?? '');
                final revenue = revVal != null ? '\$${revVal.toStringAsFixed(2)}' : '\$0.00';
                final monthlyVal = double.tryParse(data?['monthly']?.toString() ?? '');
                final monthly = monthlyVal != null ? '\$${monthlyVal.toStringAsFixed(2)}' : '\$0.00';
                final totalOrders = data?['total_orders']?.toString() ?? '0';

                final sevenDayVal = double.tryParse(data?['seven_day_sales']?.toString() ?? '');
                final sevenDaySales = sevenDayVal != null ? '\$${sevenDayVal.toStringAsFixed(2)}' : '\$0.00';
                final sevenDayOrders = data?['seven_day_orders']?.toString() ?? '0';

                final List rawDaily = data?['daily_performance'] as List? ?? [];
                final List<Map<String, dynamic>> dailyList = rawDaily.map((e) => Map<String, dynamic>.from(e)).toList();

                double maxSale = 1.0;
                for (var d in dailyList) {
                  final sale = double.tryParse(d['sales']?.toString() ?? '') ?? 0.0;
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
                                final sales = double.tryParse(dayData['sales']?.toString() ?? '') ?? 0.0;
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
