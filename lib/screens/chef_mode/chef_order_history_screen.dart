import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';

class ChefOrderHistoryScreen extends StatelessWidget {
  const ChefOrderHistoryScreen({super.key});

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
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFilterAndSearchBar(),
              const SizedBox(height: 24),
              _buildOrderList(),
              const SizedBox(height: 32),
              _buildPagination(),
              const SizedBox(height: 100), // padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ANALYTICS', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary, letterSpacing: 1.5)),
                Text('Order History', style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              ],
            ),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Lifetime Earnings', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                      Text('\$14,280.50', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orangeAccent)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.payments, color: Colors.orangeAccent, size: 28),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterAndSearchBar() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            style: GoogleFonts.inter(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search customer, order ID, or dish...',
              hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.chefSurfaceVariant.withValues(alpha: 0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.fuchsiaPrimary)),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterButton(Icons.filter_list, 'Filter'),
                const SizedBox(width: 8),
                _buildFilterButton(Icons.calendar_month, 'Date Range'),
                const SizedBox(width: 8),
                _buildPrimaryButton(Icons.download, 'Export CSV'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: AppTheme.textSecondary, size: 18),
      label: Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildPrimaryButton(IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.fuchsiaPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildOrderList() {
    return Column(
      children: [
        _buildOrderItem(
          '#ORD-8821', 'Delivered', Colors.greenAccent,
          'Margherita Pizza x 2', 'Customer: Julian Casablancas',
          'Oct 24, 2023', '07:45 PM', 'Payout', '+\$42.00',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA1wodKrPD3NR1ZkemQKCedksJWZyL6t9i5Tr84_qREtUbvOvNvDhDVjdOoAzv4jG7515KK-0r93gzVMirvN5Ae7J8xeE6goxqVqfgn-C_df0Iih9YrRQyKuRlcbA6rVQee44LmcYjOA4HFbUlLJrwotkVIyYW7aOIBcW4DQsmnV5wDzG5ddR0UxhKEuqWiIbQicUqZwvaOnWhoPD4rwcz5x6fefek5GD1Ac8Qg8A0Q5WBc9erIpUyd2oTSnEBAa597mOGwrBeSqZcT',
        ),
        const SizedBox(height: 16),
        _buildOrderItem(
          '#ORD-8819', 'Cancelled', Colors.redAccent,
          'Omakase Special', 'Customer: Sarah Jenkins',
          'Oct 23, 2023', '01:12 PM', 'Refunded', '\$0.00',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAbcqxUmvzX8CdWa3ICxhNbaOUuu50utfPVEhcUmD10jwQqFe2XaLNJzJbCivPJR7L85JKYSl11QNZyk_ClZXoDr5ccDdTCio1LGWuCyheDe5xKeBRV19pGXcfs8XSYUee8aI-Xf0z0ZLquEgDDxaWF3npdNT02bg-7lVyghMK0wDPyby8bAQ3vH3YYwpWhMiE7m-1zC5PNcsP0qosTmrkcK7pOAlR4NjmFCjLbIsvTW4lJADhTNtatOEho8h4tCuxRCVI5z-mZNV0s',
          isDimmed: true,
        ),
        const SizedBox(height: 16),
        _buildOrderItem(
          '#ORD-8815', 'Delivered', Colors.greenAccent,
          'Prime Ribeye Set', 'Customer: Michael Scott',
          'Oct 22, 2023', '09:05 PM', 'Payout', '+\$128.50',
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBEZj70C9wyXemhnmFK3y7VgjfICjK_ArnUkcCYAzCLpMCrDpbW_R05eJNps_MTXnw-MUyKsdMJdzbN9MD8jq1d0fAWhpUkroez2JFjE8VshVg60mQqYPZbu6gKtHuY0Fy_l5HVG8hISk_XvfRt_0ROzLo_Bc7jctY6KtBVJiBxj6RYbSIRt00jLh9ynnKAPX6U2ENaYMApW0S4qavmi_h2wPPVU1e7jDYUQ5ZMWmkAeIzafxvLs2ilXNHkVlOOhp8QUkwGhnIModpp',
        ),
      ],
    );
  }

  Widget _buildOrderItem(
    String id, String status, Color statusColor,
    String title, String subtitle,
    String date, String time, String amountLabel, String amount,
    String imgUrl, {bool isDimmed = false}
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(id, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(title, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(date, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                Text(time, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Text(amountLabel, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                Text(amount, style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: isDimmed ? AppTheme.textSecondary : AppTheme.fuchsiaPrimary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert, color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageNavButton(Icons.chevron_left),
        const SizedBox(width: 16),
        _buildPageNumber('1', isActive: true),
        const SizedBox(width: 8),
        _buildPageNumber('2'),
        const SizedBox(width: 8),
        _buildPageNumber('3'),
        const SizedBox(width: 16),
        _buildPageNavButton(Icons.chevron_right),
      ],
    );
  }

  Widget _buildPageNavButton(IconData icon) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Icon(icon, color: AppTheme.textSecondary),
    );
  }

  Widget _buildPageNumber(String number, {bool isActive = false}) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.fuchsiaPrimary : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: isActive ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      alignment: Alignment.center,
      child: Text(number, style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: isActive ? Colors.white : AppTheme.textSecondary)),
    );
  }
}
