import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';
import 'review_cart_screen.dart';
import 'track_order_screen.dart';

class FoodieOrderHistoryScreen extends StatelessWidget {
  final bool showBackButton;
  const FoodieOrderHistoryScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildMonthDivider('This Month'),
              const SizedBox(height: 16),
              _buildOrderCard(
                context,
                'The Burger Alchemist',
                'Truffle Wagyu Burger x1',
                'Oct 24, 2023 • 7:15 PM',
                '\$28.50',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuB5n2paj7ZEEDT7PY-MYMEtNdQ-rydnM9G4p5jfYLyzJX8085_Q-PeMHDsoptDjs3qvsCGs6DXRjJsBXD3oImncdLqsB5K92l3-LoLiQOtutw0CSTjJ12y6HBy1etfViwivAIJf1jFnTAKj6vA4L_HTwSRz4KOzHBia16Fdo8BwXyDtIgRswUUzwsSIGmku0akaM0VJG2Ps1iBXQVHR99AoDFhmpfUvb3ECngy-VqnhmftwmaQlKSj0GcHFFCVOnhQYpUVytlxOrydo',
                'In Transit',
              ),
              const SizedBox(height: 16),
              _buildOrderCard(
                context,
                'Napoli Soul Kitchen',
                'Margherita Semplice x2',
                'Oct 18, 2023 • 8:40 PM',
                '\$42.20',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuC_l0jkXMn4bEjpzvD-F2jZT26zZ5YlDC3QwtIS7uB-zfaKifTIsm33a1o9SGDlo2HS8bcltteO2kPWEUrSVNssCacPro2xVd5qwCh9B7PQ6wIIfwVxXY8dAAiPOw4yH28KbdAakK6aC2np_WuA7MvlYf8i061AGmkeNm7K7LQuil2aiZND6UN17mLgIfCDfR0KxP3SQy65fgAVP4cSknptCvdyZLGPP-CRzpa9VIcKDMvvUUQMBq_Q1AKDR52gUDemY0x-9AWv3Vge',
                'Delivered',
              ),
              const SizedBox(height: 24),
              _buildMonthDivider('September'),
              const SizedBox(height: 16),
              _buildOrderCard(
                context,
                'Umi Umami Atelier',
                'Chef\'s Signature Omakase Box x1',
                'Sep 29, 2023 • 9:10 PM',
                '\$85.00',
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAc44ATXBeAX-8K8fABNua98GUY9xfGQRIVh9zzt6Y3C0uvKsitQXsMq6Dqif10tT3CBGTTxx7hJJSi72CHG7oes6PAur0aVhFWswShE2qGB1HW0047cFukoT5eAW9UJgpL5sw8gHEx4FfRkCURF-hPuYZ6sKg_j-gkA99QcqpUmbhC8MI6XkGsyBvtEQxepqrgNELL78EEBCxQpXKXXrrUYoW8gj_i5tVwtv4VjG5JrIKhSo2GPA8rsAxqt1hvu3S3omXdigrnNl2c',
                'Delivered',
              ),
              const SizedBox(height: 32),
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Text('Load older orders', style: TextStyle(color: AppTheme.textSecondary)),
                  label: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (showBackButton) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
            ],
            Text('Order History', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Relive your favorite culinary discoveries.', style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondary)),
        const SizedBox(height: 16),
        TextField(
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Find a dish or kitchen...',
            hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
            prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.surfaceLight.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.fuchsiaPrimary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthDivider(String month) {
    return Row(
      children: [
        Text(month.toUpperCase(), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1.5)),
        const SizedBox(width: 16),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
      ],
    );
  }

  Widget _buildOrderCard(BuildContext context, String kitchenName, String items, String date, String price, String imgUrl, String status) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
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
                        Expanded(child: Text(kitchenName, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(items, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.fuchsiaPrimary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(date, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(width: 16),
                        const Icon(Icons.payments, size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(price, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReviewCartScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.fuchsiaPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(status == 'Delivered' ? 'Reorder' : 'Track Order', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    if (status != 'Delivered') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TrackOrderScreen()),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(status == 'Delivered' ? 'Write Review' : 'Details', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(40, 40),
                  foregroundColor: AppTheme.textSecondary,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
