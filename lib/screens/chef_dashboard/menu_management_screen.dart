import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ChefMenuScreen extends StatefulWidget {
  const ChefMenuScreen({super.key});

  @override
  State<ChefMenuScreen> createState() => _ChefMenuScreenState();
}

class _ChefMenuScreenState extends State<ChefMenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        title: const Text('Menu Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search and Actions
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.bodyMd(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search your creations...',
                        hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant.withOpacity(0.5)),
                        prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.magentaGloss,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: MaterialButton(
                  onPressed: () {},
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('ADD NEW DISH', style: AppTextStyles.labelMono(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Menu Grid
            _buildDishCard(
              title: 'Black Truffle Risotto',
              description: 'Arborio rice infused with authentic Perigord black truffles and finished with 24-month aged Parmigiano.',
              price: '\$34.00',
              imagePath: 'https://images.unsplash.com/photo-1630409351241-1939611f7a07?q=80&w=600&auto=format&fit=crop',
              inventory: '12 in stock',
              isActive: true,
            ),
            const SizedBox(height: 16),
            _buildDishCard(
              title: 'Wild Mushroom Fettuccine',
              description: 'Hand-rolled pasta with a medley of forest-foraged mushrooms and a light garlic cream sauce.',
              price: '\$28.50',
              imagePath: 'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?q=80&w=600&auto=format&fit=crop',
              inventory: 'Out of stock',
              inventoryColor: AppColors.error,
              isActive: false,
            ),
            const SizedBox(height: 16),
            _buildDishCard(
              title: 'Diver Scallops',
              description: 'Pan-seared scallops with pea purée, crispy pancetta, and citrus-infused oil.',
              price: '\$42.00',
              imagePath: 'https://images.unsplash.com/photo-1626079979774-6f890cf25d2b?q=80&w=600&auto=format&fit=crop',
              inventory: '8 in stock',
              isActive: true,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDishCard({
    required String title,
    required String description,
    required String price,
    required String imagePath,
    required String inventory,
    Color? inventoryColor,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  imagePath,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.delete, size: 16, color: AppColors.error),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                    ),
                    child: Text(price, style: AppTextStyles.labelMono(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineMd(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant.withOpacity(0.8)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.outlineVariant.withOpacity(0.1)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('INVENTORY', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                          Text(inventory, style: AppTextStyles.bodyMd(color: inventoryColor ?? Colors.white)),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Active', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                          const SizedBox(width: 8),
                          Switch(
                            value: isActive,
                            onChanged: (bool value) {},
                            activeColor: AppColors.primary,
                            activeTrackColor: AppColors.primary.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
