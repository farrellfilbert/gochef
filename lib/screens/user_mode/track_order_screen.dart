import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // Background Map (Placeholder)
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCdfHL4NRq3Qdm5QHgRRGtuOjs86h5VERFUWvo8Ywk6p0XoXuh5OyAGy_9MD5o2lOANKSvWqBgAFdmpX_1K5xODKNyVyo-Kq9T5kOm89yRXWJ_XzrM2qSsSdXsqMbBCEG9GNjaatbP76w3TXcig9ce9pEWd3PSbNkIE3OPLyeC88ZJ3Gglpzz2Rhg6Qa_p5O2Qj8A0KfTWPb349wQRg_GWvU8BCzSanqEKYd16p4hUBqemtJmlkh2qGJu70Fk4m3j1yDtzK-he9Cg5D',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.backgroundDark,
                  ],
                  stops: const [0.0, 0.9],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                const Spacer(),
                _buildTrackingOverlay(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.fuchsiaPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              Text(
                'Order #4292',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.fuchsiaPrimary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: AppTheme.fuchsiaPrimary),
                onPressed: () {},
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.fuchsiaPrimary, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDHhe7-k1_WZD7CvAcz0g7Sr8ZlENl1aORFDkisiAFrtmuSHf5VbFGf8zrcdAMmRjG0QbbXu-2SZq5nNaIc7s-rmO_YS0khTCZuLKWkHYAcqv99DAT_uq1mfjnmigo-sK4iR9VLfGt5jp-uvTBZAlAQZic4T2MHDLoPEW5VFb_sPOxaczN1tflqEvrpeqq7ixZVDCR66UHOVbHJN62V2ONe6QEyBTM6ckaKU-bfSyhjZk_FfeuBIdinRFgURkRNTMxaW5HkTJV9CKJs'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingOverlay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildOrderSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ESTIMATED ARRIVAL', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  Text('12:45 PM', style: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.w700, color: AppTheme.fuchsiaPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('Out for Delivery', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.greenAccent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildStepper(),
          const SizedBox(height: 32),
          _buildChefContactCard(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 16, right: 16, top: 12,
          child: Row(
            children: [
              Expanded(child: Container(height: 4, color: AppTheme.fuchsiaPrimary)),
              Expanded(child: Container(height: 4, color: AppTheme.fuchsiaPrimary)),
              Expanded(child: Container(height: 4, color: Colors.white.withValues(alpha: 0.2))),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStepIcon(Icons.check, 'Received', isActive: true),
            _buildStepIcon(Icons.soup_kitchen, 'Preparing', isActive: true),
            _buildStepIcon(Icons.pedal_bike, 'In Transit', isActive: true, isCurrent: true),
            _buildStepIcon(Icons.home, 'Arrived', isActive: false),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIcon(IconData icon, String label, {bool isActive = false, bool isCurrent = false}) {
    return Column(
      children: [
        Container(
          width: isCurrent ? 36 : 28,
          height: isCurrent ? 36 : 28,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.fuchsiaPrimary : AppTheme.surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.backgroundDark, width: 4),
          ),
          child: Icon(icon, color: isActive ? Colors.white : Colors.transparent, size: isCurrent ? 18 : 14),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal, color: isCurrent ? AppTheme.fuchsiaPrimary : AppTheme.textSecondary)),
      ],
    );
  }

  Widget _buildChefContactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAaIuJi-aoxED7dNLb-LPhi92ba9eUQh6suhflf66Pr6Xf22NVQaD1td7lFqTJZT_Q6WF-FgkgFsko5NLqEUqPouJkP-pQ3TsKkaZK4SfwFXDwCmC-cTP4_0HJQ1xNsdVI9XzGWcIYp0IFFtYedVgqEGFl6RIZ6CpLeuEpSVSrfKz1ENON5XtRJ57BmbsTS_3ELDICiCcIuBMoyAxmie6byRFQY23XeA1fTWx6wylr_-ZsSWCu8IKDeUNKJqrEgKj3sQ5LkVT3ZM4yw'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -2, right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: AppTheme.surfaceColor, shape: BoxShape.circle),
                  child: const Icon(Icons.verified, color: Colors.greenAccent, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chef Elena Rossi', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text('4.9 (2.4k reviews)', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.chat, color: AppTheme.fuchsiaPrimary), style: IconButton.styleFrom(backgroundColor: AppTheme.fuchsiaPrimary.withValues(alpha: 0.1)), onPressed: () {}),
              const SizedBox(width: 8),
              IconButton(icon: const Icon(Icons.call, color: AppTheme.fuchsiaPrimary), style: IconButton.styleFrom(backgroundColor: AppTheme.fuchsiaPrimary.withValues(alpha: 0.1)), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Order Summary', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              Text('3 items', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.fuchsiaPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          _buildCompactCartItem('Slow-Cooker Tortilla Soup', '\$18.50', 'Spice level: Medium • No Cilantro', 'https://lh3.googleusercontent.com/aida-public/AB6AXuA6rKG8ao3l1QJlbsSf0z2zXVImqyC0glwG2kdlxjCxMoD2MuCEMNFE3pLG9FS79wQKQOtZn4sfhWVL8MHPilH5wbIM2Mz458r0pE18vbUz9dncWQYOLkpF6p6jwuEEI2wboXogzSyTyeds0RyTkuwl56pjBPsk4HsLp1ZkXdFoTeZAqs3cq-DaqAn6iWj5jXCuzd03ZQSAgwqi_YeO-44bEaI8XgCeb52pjqFehLJ5M_H9IA6RPu2dhc3E7HL8p3Bn590kkaOKATp-'),
          const SizedBox(height: 16),
          _buildCompactCartItem('Pomegranate Kale Salad', '\$12.00', 'Extra roasted almonds', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDojkEn9wVd_Kz9Ha76zVR-Z6h0gki94GnjjMatpT5Ff1oAc2ECayClgFBDkgvSr4Ao1wvCXjRtvqvZGkfQNnlTuw7JDrAu3V2MLhJDHC3XrxCVMCSICYcQNGAa2UXlBbAX7XuB0L8mJoShmiXglgkUMTxU5xxbvyULJBNv3YGogehaIDih9KoocQUKv2aRvJ3ea6hv-_6z1V5oZONn5A6o_vZmUdmd_C8JhSDusJASif90bz5cojS1_-UkAaYCVXJPr9Ui6LU_Ia67'),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Paid', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
              Text('\$34.75', style: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCartItem(String name, String price, String desc, String imgUrl) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
                  Text(price, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                ],
              ),
              const SizedBox(height: 4),
              Text(desc, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}
