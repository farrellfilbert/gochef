import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';

class ChefReferralScreen extends StatelessWidget {
  const ChefReferralScreen({super.key});

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
        title: Text('Chef Referral Program', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.textPrimary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 24),
            _buildReferralCodeCard(context),
            const SizedBox(height: 24),
            _buildTotalCreditsCard(),
            const SizedBox(height: 24),
            _buildProgressGrid(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBwPQxeugKtF2EICc1pANmi2PGbjCbM89HKBrTpmuYUk_vx8PTQwCExueaerILkjGWGydHY4i_XmSNXQ2TkUboFDdtU8rYLt5QsHAvICimgA29EwXkXzQzk-k-CjUJA6BHOz2Qim8P2S-bpIrNfcwQxVrdRRaESgWGGr9qDLAFgDk9zA_9cEf0fivLOPDyXT7qYNhdazYQtJQhPEEnV7TYbOiRKuygSLHLpOCNHKzWj_DI7K5iaCprtHrGaXRPHJN6-sH1D-4Rty7YI'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.black.withValues(alpha: 0.9), Colors.black.withValues(alpha: 0.3)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
              ),
              child: Text('Chef Alliance', style: GoogleFonts.inter(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            Text('Grow Your\nCulinary Empire', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
            const SizedBox(height: 8),
            Text('Invite talented chefs to join GoChef and earn \$50 commission when they complete their first 10 orders.', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('Give \$50', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                        Text('SIGNUP BONUS', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.2, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  Expanded(
                    child: Column(
                      children: [
                        Text('Get \$50', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                        Text('CASH REWARD', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.2, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCodeCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.group_add, size: 32, color: Colors.orange),
          ),
          const SizedBox(height: 16),
          Text('Your Invite Code', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Share this code with fellow chefs.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3), style: BorderStyle.solid),
            ),
            alignment: Alignment.center,
            child: Text('CHEF-MARCO-50', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.orange)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied!'), backgroundColor: Colors.green));
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCreditsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Earnings', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const Icon(Icons.payments, color: Colors.greenAccent, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Text('\$250.00', style: GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
              const SizedBox(width: 8),
              Text('+\$50 this month', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressGrid() {
    return Row(
      children: [
        Expanded(child: _buildProgressStat('Invites Sent', '12', Icons.send, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _buildProgressStat('Chefs Joined', '5', Icons.how_to_reg, Colors.greenAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildProgressStat('Conversion', '42%', Icons.analytics, AppTheme.fuchsiaPrimary)),
      ],
    );
  }

  Widget _buildProgressStat(String label, String val, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 16),
          Text(val, style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
