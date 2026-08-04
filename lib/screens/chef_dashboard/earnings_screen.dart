import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ChefEarningsScreen extends StatelessWidget {
  const ChefEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        title: const Text('Earnings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Total Balance Section
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
                  Text('\$1,240.50', style: AppTextStyles.displayLgMobile(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Scheduled for Oct 25', style: AppTextStyles.labelSm(color: AppColors.primary.withOpacity(0.8))),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.magentaGloss,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: MaterialButton(
                        onPressed: () {},
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        child: Text('Withdraw Funds', style: AppTextStyles.headlineMd(color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Revenue Trends
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Revenue Trends', style: AppTextStyles.headlineMd(color: Colors.white)),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      _buildTimeTab('Week', isSelected: true),
                      _buildTimeTab('Month'),
                      _buildTimeTab('Year'),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildTrendBar(40),
                        _buildTrendBar(60),
                        _buildTrendBar(55),
                        _buildTrendBar(85),
                        _buildTrendBar(70),
                        _buildTrendBar(50),
                        _buildTrendBar(95, opacity: 0.9),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Mon', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                      Text('Tue', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                      Text('Wed', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                      Text('Thu', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                      Text('Fri', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                      Text('Sat', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                      Text('Sun', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Earnings Breakdown
            Text('Earnings Breakdown', style: AppTextStyles.headlineMd(color: Colors.white)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  _buildBreakdownRow('Gross Revenue', '\$1,500.00', isPositive: true),
                  Divider(color: AppColors.outlineVariant.withOpacity(0.2), height: 1),
                  _buildBreakdownRow('Platform Commission (15%)', '-\$225.00', isNegative: true),
                  Divider(color: AppColors.outlineVariant.withOpacity(0.2), height: 1),
                  _buildBreakdownRow('Service Fees', '-\$34.50', isNegative: true),
                  Divider(color: AppColors.outlineVariant.withOpacity(0.2), height: 1),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Net Earnings', style: AppTextStyles.headlineMd(color: AppColors.primary)),
                        Text('\$1,240.50', style: AppTextStyles.displayLgMobile(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payout History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payout History', style: AppTextStyles.headlineMd(color: Colors.white)),
                Text('View All', style: AppTextStyles.labelSm(color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 16),
            _buildPayoutItem(
              amount: '\$420.50',
              status: 'Completed',
              statusColor: Colors.green,
              dateAndAccount: 'Oct 18, 2024 • Chase •••• 4242',
              icon: Icons.payments,
            ),
            const SizedBox(height: 12),
            _buildPayoutItem(
              amount: '\$820.00',
              status: 'Processing',
              statusColor: Colors.orange,
              dateAndAccount: 'Oct 22, 2024 • Chase •••• 4242',
              icon: Icons.sync,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTab(String text, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSm(color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildTrendBar(double heightPercentage, {double opacity = 0.4}) {
    return Container(
      width: 6,
      height: heightPercentage,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(opacity),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, {bool isPositive = false, bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
          Text(
            value,
            style: AppTextStyles.labelMono(
              color: isNegative ? AppColors.error : (isPositive ? Colors.white : AppColors.onSurfaceVariant),
            ).copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildPayoutItem({
    required String amount,
    required String status,
    required Color statusColor,
    required String dateAndAccount,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.surfaceContainerHighest,
            child: Icon(icon, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(amount, style: AppTextStyles.headlineMd(color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: AppTextStyles.labelSm(color: statusColor).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateAndAccount, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                    Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
