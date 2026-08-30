import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';

class ChefEarningsScreen extends StatefulWidget {
  const ChefEarningsScreen({super.key});

  @override
  State<ChefEarningsScreen> createState() => _ChefEarningsScreenState();
}

class _ChefEarningsScreenState extends State<ChefEarningsScreen> {
  late Future<Map<String, dynamic>?> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _loadData();
  }

  Future<Map<String, dynamic>?> _loadData() async {
    final user = await ApiService.getProfile();
    if (user != null && user.kitchenId != null) {
      return await ApiService.getKitchenAnalytics(int.parse(user.kitchenId!));
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
        title: const Text('Earnings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final data = snapshot.data;
          final revVal = double.tryParse(data?['revenue']?.toString() ?? '');
          final revenue = revVal != null ? '\$${revVal.toStringAsFixed(2)}' : '\$0.00';
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL BALANCE', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                          Icon(Icons.account_balance_wallet, color: AppColors.onSurfaceVariant.withOpacity(0.2), size: 48),
                        ],
                      ),
                      Text(revenue, style: AppTextStyles.displayLgMobile(color: Colors.white)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('💸 Payout request submitted to your linked bank account!'),
                                backgroundColor: AppColors.surface,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: const BorderSide(color: Colors.black, width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'Cash Out Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Recent Transactions', style: AppTextStyles.headlineMd(color: Colors.white)),
                const SizedBox(height: 16),
                _buildTransactionItem('Payout sent to Bank', 'Yesterday', '-\$420.50', false),
                _buildTransactionItem('Order #ORD-1029', 'Oct 20, 2:30 PM', '+\$15.50', true),
                _buildTransactionItem('Order #ORD-1028', 'Oct 20, 1:15 PM', '+\$32.00', true),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildTransactionItem(String title, String date, String amount, bool isPositive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLg(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(date, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: AppTextStyles.bodyLg(color: isPositive ? Colors.green : Colors.red).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
