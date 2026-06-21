import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme.dart';
import '../../widgets/premium/glass_card.dart';

class DealsMapScreen extends StatelessWidget {
  const DealsMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Stack(
        children: [
          // The Map
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(-6.2088, 106.8456),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              MarkerLayer(
                markers: [
                  _buildDealMarker(const LatLng(-6.2088, 106.8456), 'BOGO', AppTheme.fuchsiaPrimary),
                  _buildDealMarker(const LatLng(-6.2120, 106.8500), '\$5 OFF', AppTheme.fuchsiaPrimary),
                  _buildDealMarker(const LatLng(-6.2050, 106.8400), '15%', Colors.greenAccent),
                  _buildDealMarker(const LatLng(-6.2100, 106.8350), '25%', AppTheme.fuchsiaPrimary),
                ],
              ),
            ],
          ),
          
          // Back Button & Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppTheme.surfaceLight,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: TextField(
                          style: GoogleFonts.inter(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search neighborhood deals...',
                            hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                            icon: const Icon(Icons.search, color: AppTheme.textSecondary),
                            suffixIcon: const Icon(Icons.tune, color: AppTheme.fuchsiaPrimary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Flash Sales', isActive: true, icon: Icons.flash_on),
                      _buildFilterChip('Free Delivery'),
                      _buildFilterChip('Italian'),
                      _buildFilterChip('Vegan'),
                      _buildFilterChip('Halal'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Deal Card
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAQq4Me8DKyjXCmQ4NtQ6y-yRAR_WuoJ16CYDvOopT7lraKrdKMlKy0E2VUVDdtkjaA0xsgHEbgQ0HJPx1jrSiKeUQIgpWl91wz4BOoTlhGUK6npDKsHCKCSK1kcOlKKG6FWVTJ-3MjeNa8CtLVBTsJ7qyjbrqv2IS5AUXNrd5LUIzDzzIvjOttjONjRjZCF3GP9KlJetLZbQ1x24RMJj1_66EhNmfLaWc0WOYpSon_2_MLCd7ldZjjrY68nkDWuywvbEJ7QcHElV9p'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('Artisan Pepperoni Pie', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            Text('\$14.00', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.fuchsiaPrimary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Chef Maria • ', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                            const Icon(Icons.verified, color: Colors.greenAccent, size: 12),
                            Text(' Verified', style: GoogleFonts.inter(fontSize: 10, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.near_me, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text('0.8 miles', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                            const SizedBox(width: 12),
                            const Icon(Icons.star, size: 14, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text('4.9 (124)', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.fuchsiaPrimary,
                            minimumSize: const Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('View Deal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildDealMarker(LatLng point, String label, Color color) {
    return Marker(
      point: point,
      width: 80,
      height: 40,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color == Colors.greenAccent ? Colors.black : Colors.white,
              ),
            ),
          ),
          Icon(Icons.arrow_drop_down, color: color, size: 16),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false, IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: icon != null ? Icon(icon, size: 16, color: isActive ? Colors.white : AppTheme.textPrimary) : const SizedBox.shrink(),
        label: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppTheme.textPrimary,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppTheme.fuchsiaPrimary : AppTheme.surfaceLight.withValues(alpha: 0.8),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: icon != null ? 12 : 16, vertical: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: isActive ? Colors.transparent : Colors.white.withValues(alpha: 0.1)),
          ),
        ),
      ),
    );
  }
}
