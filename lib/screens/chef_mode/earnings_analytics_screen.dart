import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui' as ui;
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';

class EarningsAnalyticsScreen extends StatelessWidget {
  const EarningsAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.chefBackground,
      body: Stack(
        children: [
          // Background Glow Effect
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.chefPrimaryContainer.withValues(alpha: 0.1),
              ),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildHeroCard(),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildSideStats(),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildPeakTimes(),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildTopDishes(),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildTransactionHistory(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      title: Row(
        children: [
          Text(
            'GoChef',
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.chefPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.chefTertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: AppTheme.chefTertiary, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Chef Mode',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.chefTertiary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppTheme.chefTextPrimary),
          onPressed: () {},
        ),
        Container(
          margin: const EdgeInsets.only(right: 24, left: 8),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.chefPrimaryContainer, width: 2),
            image: const DecorationImage(
              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB6up5mSyN_qf5i44WS4iSqaEEO-Cz4nVRWP-V0H6IETOuV3aKRnzJK-l5W8a1IdXFYnw8AiBRMAnPBcYx8l0so0rwwmdLH4ukqNNFvo14HM5nrOfkCyd-eGVev_IRVpKXfPm4vG4O_KTzvFXsfwvATS_28zEVjt8BWge9tG-PYz_XjR_uPtVtRy8De5LNnBYcdmngYhbxSQkXxyshHYkshN3rBWEK1flKhJgRJnW4X-z7iSO7a6j1fTH7zJUp4NpYvp3623zEkWozV'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL MONTHLY EARNINGS',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.chefTextSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '\$12,482.50',
                style: GoogleFonts.montserrat(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.chefTextPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.chefTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_upward, color: AppTheme.chefTertiary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '14.2%',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.chefTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Chart
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildChartBar(0.4, AppTheme.chefSurfaceVariant),
                const SizedBox(width: 8),
                _buildChartBar(0.55, AppTheme.chefSurfaceVariant),
                const SizedBox(width: 8),
                _buildChartBar(0.45, AppTheme.chefSurfaceVariant),
                const SizedBox(width: 8),
                _buildChartBar(0.7, AppTheme.chefSurfaceVariant),
                const SizedBox(width: 8),
                _buildChartBar(0.6, AppTheme.chefSurfaceVariant),
                const SizedBox(width: 8),
                _buildChartBar(0.95, AppTheme.chefPrimaryContainer, isCurrentWeek: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double heightFactor, Color color, {bool isCurrentWeek = false}) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          FractionallySizedBox(
            heightFactor: heightFactor,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                boxShadow: isCurrentWeek
                    ? [BoxShadow(color: AppTheme.chefPrimary.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)]
                    : null,
              ),
            ),
          ),
          if (isCurrentWeek)
            Positioned(
              top: -30,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.chefTextPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Current Week',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.chefBackground),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSideStats() {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payout Balance', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.chefTextSecondary)),
                const SizedBox(height: 8),
                Text('\$2,105.00', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w600, color: AppTheme.chefTextPrimary)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.chefPrimaryContainer,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Withdraw Now', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text('Next auto-payout: Aug 24', style: GoogleFonts.inter(fontSize: 10, color: AppTheme.chefTextSecondary)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Orders This Week', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.chefTextSecondary)),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.chefTertiary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.restaurant, color: AppTheme.chefTertiary, size: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('184', style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.chefTextPrimary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeakTimes() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Peak Service Times', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.chefTextPrimary)),
          const SizedBox(height: 24),
          _buildProgressRow('Lunch', 0.65, '65%'),
          const SizedBox(height: 16),
          _buildProgressRow('Happy Hr', 0.40, '40%'),
          const SizedBox(height: 16),
          _buildProgressRow('Dinner', 0.95, '95%', isHighlight: true),
          const SizedBox(height: 16),
          _buildProgressRow('Late Night', 0.25, '25%'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.chefSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb, color: AppTheme.chefPrimaryContainer, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Friday 7PM - 9PM is your most profitable window.',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.chefTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double fill, String percentage, {bool isHighlight = false}) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? AppTheme.chefTextPrimary : AppTheme.chefTextSecondary,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.chefSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fill,
              child: Container(
                decoration: BoxDecoration(
                  color: isHighlight ? AppTheme.chefPrimaryContainer : AppTheme.chefPrimaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isHighlight ? [BoxShadow(color: AppTheme.chefPrimaryContainer.withValues(alpha: 0.5), blurRadius: 8)] : null,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            percentage,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? AppTheme.chefTextPrimary : AppTheme.chefTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopDishes() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Performing Dishes', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.chefTextPrimary)),
              Text('View Full Menu', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.chefPrimaryContainer)),
            ],
          ),
          const SizedBox(height: 24),
          _buildDishItem(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAEoMt3VANKr9AsGvpj4WsJ4g97Z0HYkF6JAa3DrRKVYJIjnJlWBo6ELFy6J8J8zhrxE9sRCsKgQbN-O7j9ZzhaaU2L5zizR-q2tjI2rMOsTxcjOGdRWQXYjvTqZwT3Rq1m3z-0joL8yYaBesuxCHZT2LFMITtwHcTlucD71txV2j2WPocPv61K7EO-dWC91VPb9Cf9q5NMNfxTQUaxB3HaunsEY7IT3-p9gL3EK8ZRgbZQfR8d0Tw6CnFtpnxVANLTxJk1rloTIx78',
            'Truffle Tagliatelle',
            '84 orders · \$2,352 rev',
            '+12%',
            AppTheme.chefTertiary,
          ),
          const SizedBox(height: 16),
          _buildDishItem(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAlz7-PIrXHe7GWHCykt2hwUCQPHgl6VjeUUguw9sncoJiWS74-JSTSoheeKbM2eOtYBA98pdRNkDJadFPCJyqRHTwSDHj3_5dHFhwVVv9EEk9Ur3qg1k5TTzF5hgnUBvNBiZmlQtx8QfNpPolyULxSGmZTsew31f-jSXsv4YCkvhQ34tnaKSpIK1UBu-UefcUyblr0j6PwCwGhHolacS8izN8Yr_kDFQaSq4y-ARQL6n9bHxe1S0smFARfcg1U7BrMze9Grc22iE0U',
            'Midnight Scallops',
            '62 orders · \$1,860 rev',
            '+8%',
            AppTheme.chefTertiary,
          ),
          const SizedBox(height: 16),
          _buildDishItem(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuAi4FM5Ow-cYpM52ZzNN8oUKkkXImGhPnm-dMRmNbVQcKDVWceUG6Oi1l8nJHd9z7fVJZAcmgM8jkiY_QoCJtyJ5cDay2DbI94Kh5Ki880r_qyX3v5oBkH693UJE8TVSor3Gfwt3ln7yAV9a8doq_GDMaMYvR15MzQYHSQw3N9jMxlRDU6Lo4loG9oH5vnTsrbTArZFCc10Vq7QvN_SP54l13Z6l8JlcD2fkLHggcPzKX_FT8cngM_o2rMh_p52WHSYS2k2C7Y74rEl',
            'Magenta Velvet Cake',
            '45 orders · \$540 rev',
            '-2%',
            AppTheme.chefTextSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildDishItem(String imageUrl, String name, String stats, String growth, Color growthColor) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.chefTextPrimary)),
              Text(stats, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.chefTextSecondary)),
            ],
          ),
        ),
        Text(growth, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: growthColor)),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payout History', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.chefTextPrimary)),
                Row(
                  children: [
                    Icon(Icons.filter_list, color: AppTheme.chefTextSecondary, size: 20),
                    const SizedBox(width: 16),
                    Icon(Icons.download, color: AppTheme.chefTextSecondary, size: 20),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 1),
          _buildTransactionRow('Aug 17, 2023', '09:14 AM', 'PAY-9421-884', 'Completed', '\$3,420.50', AppTheme.chefTertiary),
          const Divider(color: Colors.white10, height: 1),
          _buildTransactionRow('Aug 10, 2023', '11:30 AM', 'PAY-8812-102', 'Completed', '\$2,980.00', AppTheme.chefTertiary),
          const Divider(color: Colors.white10, height: 1),
          _buildTransactionRow('Aug 03, 2023', '02:22 PM', 'PAY-7742-019', 'Processing', '\$3,105.00', AppTheme.chefTertiary),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: Text('Show more transactions', style: GoogleFonts.inter(color: AppTheme.chefPrimaryContainer)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(String date, String time, String ref, String status, String amount, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.chefTextPrimary)),
                Text(time, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.chefTextSecondary)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(ref, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.chefTextSecondary)),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: GoogleFonts.inter(fontSize: 10, color: statusColor)),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(amount, textAlign: TextAlign.right, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.chefTextPrimary)),
          ),
        ],
      ),
    );
  }
}
