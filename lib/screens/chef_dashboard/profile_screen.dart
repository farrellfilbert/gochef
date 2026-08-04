import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'earnings_screen.dart';

class ChefProfileScreen extends StatelessWidget {
  const ChefProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.surface.withOpacity(0.9),
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1556155092-490a1ba16284?q=80&w=2000&auto=format&fit=crop',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.background],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5), width: 2),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1574966739987-65e38f424418?q=80&w=200&auto=format&fit=crop'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Urban Gourmet Kitchen', style: AppTextStyles.headlineLgMobile(color: Colors.white)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: AppColors.onSurfaceVariant, size: 14),
                                  const SizedBox(width: 4),
                                  Text('Manhattan, NYC', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Row
                Row(
                  children: [
                    Expanded(child: _buildStatItem('2.4k', 'Total Orders')),
                    Container(width: 1, height: 40, color: AppColors.outlineVariant.withOpacity(0.2)),
                    Expanded(child: _buildStatItem('4.9', 'Avg Rating', highlight: true)),
                    Container(width: 1, height: 40, color: AppColors.outlineVariant.withOpacity(0.2)),
                    Expanded(child: _buildStatItem('3.5', 'Years Active')),
                  ],
                ),
                const SizedBox(height: 24),

                // About Section
                Row(
                  children: [
                    Icon(Icons.info, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text('About the Kitchen', style: AppTextStyles.headlineMd(color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border(left: BorderSide(color: AppColors.primary, width: 4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"Our culinary philosophy is rooted in the intersection of urban sophistication and traditional gourmet comfort. We bring the private chef\'s table experience directly to your home."',
                        style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildTag('Organic'),
                          const SizedBox(width: 8),
                          _buildTag('Farm-to-Table'),
                          const SizedBox(width: 8),
                          _buildTag('Artisanal'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Operational Settings
                Text('Operational Settings', style: AppTextStyles.headlineMd(color: Colors.white)),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(context, Icons.schedule, 'Business Hours', 'Manage your operating times'),
                      Divider(color: AppColors.outlineVariant.withOpacity(0.1), height: 1),
                      _buildSettingsTile(context, Icons.payments, 'Payout Methods', 'Manage your earnings & bank info', destination: const ChefEarningsScreen()),
                      Divider(color: AppColors.outlineVariant.withOpacity(0.1), height: 1),
                      _buildSettingsTile(context, Icons.local_shipping, 'Delivery Radius', 'Set your service area (currently 5mi)'),
                      Divider(color: AppColors.outlineVariant.withOpacity(0.1), height: 1),
                      _buildSettingsTile(context, Icons.shield, 'Kitchen Inspection', 'Renew your safety certifications'),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {bool highlight = false}) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.displayLgMobile(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.bold, fontSize: 10)),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Text(text, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
    );
  }

  Widget _buildSettingsTile(BuildContext context, IconData icon, String title, String subtitle, {Widget? destination}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
      trailing: Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}
