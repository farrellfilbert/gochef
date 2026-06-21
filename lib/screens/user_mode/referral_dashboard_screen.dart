import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';

class ReferralDashboardScreen extends StatelessWidget {
  const ReferralDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildHeroSection(),
              const SizedBox(height: 24),
              _buildReferralCodeCard(context),
              const SizedBox(height: 24),
              _buildTotalCreditsCard(),
              const SizedBox(height: 24),
              _buildProgressGrid(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
              const SizedBox(height: 100), // padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            Text('GoChef', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          ],
        ),
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCI-SDDeh_cHmgqbS6BEeGBwVp5kQgSgilMN5aK44eu0OkgVhriBEgwbcYsS2w50VFjJxxZ1ViXXH62JhpJAed5V21Z9Mb8b8s65xPcXL7f_5OhXYx1lT8vrNCSnYux4LiI7j-55n6G9nB5-4MOJLwF9CJec9qFTXoQq0bb2birddHi2spH4Vf4gEU9Uh0H7BH5MIsMXhJhA-D0cge65mbZZF0TpLQwyZEyq_RWEC8hdaey21kcwvbvxTSGaXpCIgVJeMg5sObmCKFT'),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuCx9y4pDrV4ILh6o0vtvk3f19Jys9HB8pxFlYCdfa74bJZ1KAuspxJwQqDofiR5-PkRx6p45O_WAtkF9T_2kf22BMqC9aznXEvZcYeaTN0FUeEpyn0xMeU4mQCuNGqvq7AAIAXlhJ73LBIULzbZYEKs_RXC_QiZIOZYNUllY4QDCgkbmMsacq4UCo5WcN8L_4f0tbB0EDUfNUVoMmj4X-Hk_mbfAvAo-cK038synbAqPRmrgEsluwK7n1bczjrKWFEDdPPyUbRVy-41'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
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
                color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.5)),
              ),
              child: Text('Referral Program', style: GoogleFonts.inter(color: AppTheme.fuchsiaPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 16),
            Text('Share the Love,\nEarn Free Meals', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
            const SizedBox(height: 8),
            Text('The best meals are better shared. Introduce your neighbors to GoChef and earn rewards for every discovery.', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('Give \$10', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                        Text('TO A FRIEND', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.2, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  Expanded(
                    child: Column(
                      children: [
                        Text('Get \$10', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                        Text('FOR YOURSELF', style: GoogleFonts.inter(fontSize: 10, letterSpacing: 1.2, color: AppTheme.textSecondary)),
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
            decoration: BoxDecoration(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.celebration, size: 32, color: AppTheme.fuchsiaPrimary),
          ),
          const SizedBox(height: 16),
          Text('Your Invite Code', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text('Share this code with neighbors to give them \$10 off their first order.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.fuchsiaPrimary.withValues(alpha: 0.3), style: BorderStyle.solid),
            ),
            alignment: Alignment.center,
            child: Text('GOCHEF-ALEX-24', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.fuchsiaPrimary)),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied!'), backgroundColor: Colors.green));
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.fuchsiaPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 24),
          Text('DIRECT SHARE', style: GoogleFonts.inter(fontSize: 12, letterSpacing: 1.2, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShareIcon(Icons.forum, 'WhatsApp', Colors.greenAccent),
              _buildShareIcon(Icons.sms, 'SMS', Colors.orange),
              _buildShareIcon(Icons.mail, 'Email', AppTheme.fuchsiaPrimary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.surfaceLight.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
      ],
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
              Text('Total Credits', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const Icon(Icons.account_balance_wallet, color: Colors.greenAccent, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Text('\$140.00', style: GoogleFonts.montserrat(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.greenAccent, size: 16),
              const SizedBox(width: 8),
              Text('+\$20 this week', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.fuchsiaPrimary, width: 2),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('View Wallet', style: TextStyle(color: AppTheme.fuchsiaPrimary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressGrid() {
    return Row(
      children: [
        Expanded(child: _buildProgressStat('Invites Sent', '24', Icons.person_add, AppTheme.fuchsiaPrimary)),
        const SizedBox(width: 12),
        Expanded(child: _buildProgressStat('Neighbors Joined', '18', Icons.handshake, Colors.greenAccent)),
        const SizedBox(width: 12),
        Expanded(child: _buildProgressStat('Success Rate', '4.8', Icons.star, Colors.orange)),
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
          Text(val, style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Activity', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text('View All', style: GoogleFonts.inter(color: AppTheme.fuchsiaPrimary)),
            ],
          ),
          const SizedBox(height: 24),
          _buildActivityRow(
            'Jordan Smith', 'Joined using your link • 2h ago',
            '+\$10 Pending', 'AWAITING ORDER',
            Colors.greenAccent,
            'https://lh3.googleusercontent.com/aida-public/AB6AXuB_YEZc5Pol67X6rwBvbYdvCYWRZRdgkhbywzmIZ1w4qcZjxgnlsfvvr3WOnKyQlDboGtc_7XSUcHHZRXIPftUKVZXYXqA71kh1EjTy2yHB6rOkLZ0SVIKuTM-mnlydU6Noz9vEVHu33sDbyY8at-O5F8wjV1bKAYDFXPfgCtEi0HTDUw9612YL17EOcwkZ5zoZsaX4ZFUhVHzbcAgG6en77Q-OoTcHnTmyLVD5mbIrmMbmMhEpQsfr5bxN7rfw03qYVDL85SIF4_mL'
          ),
          const Divider(color: Colors.white24, height: 32),
          _buildActivityRow(
            'Maria Garcia', 'Placed first order • 1d ago',
            '+\$10 Applied', null,
            Colors.greenAccent,
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBxgr_7cL3y7WZ9CkWngmvhNYmuPLux_RgMGlRXyqNU6n4__zFRZ4UaKki2Z9DfrHFIP76NSnSrBYYu2hWDxzQgdh0MwtoTVWbddu3bH4pSnZhWEbImn8uBCfTSFqzK60olE95gJEZi6mg6ewraexA4W0IpyTYYu9buirVCzybLTPouLStDLf3yQHf6cjbsZXX5OHB5TaFHYjo6rw85wEP9COCVvo5M1sq7qPy5YvjXcv1GPQMr6wqN2MlODR9xOy30-2E3mapFcyyE',
            true
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(String name, String desc, String amt, String? status, Color amtColor, String img, [bool completed = false]) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(img),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(amt, style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: amtColor)),
            if (status != null) Text(status, style: GoogleFonts.inter(fontSize: 8, letterSpacing: 1.2, color: AppTheme.textSecondary)),
            if (completed) const Icon(Icons.check_circle, size: 16, color: Colors.greenAccent),
          ],
        ),
      ],
    );
  }
}
