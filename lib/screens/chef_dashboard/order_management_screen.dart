import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class ChefOrdersScreen extends StatefulWidget {
  const ChefOrdersScreen({super.key});

  @override
  State<ChefOrdersScreen> createState() => _ChefOrdersScreenState();
}

class _ChefOrdersScreenState extends State<ChefOrdersScreen> {
  int _selectedTabIndex = 1; // 1 = Preparing
  final List<String> _tabs = ['Pending', 'Preparing', 'Ready', 'Completed', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withOpacity(0.8),
        elevation: 0,
        title: const Text('Active Prep', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text('Avg. 18m', style: AppTextStyles.labelSm(color: AppColors.primary)),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            height: 50,
            color: AppColors.background.withOpacity(0.95),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedTabIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTabIndex = index),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.2)) : null,
                    ),
                    child: Text(
                      _tabs[index],
                      style: AppTextStyles.labelMono(
                        color: isSelected ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildOrderCard(
                  customerName: 'Julian Voss',
                  orderNumber: '#2412',
                  timeInfo: '12m elapsed',
                  timeIsUrgent: true,
                  subInfo: 'ASAP Delivery',
                  items: [
                    {'qty': 2, 'name': 'Black Truffle Risotto', 'price': '\$64.00'},
                    {'qty': 1, 'name': 'Braised Short Rib', 'price': '\$42.00'},
                  ],
                  note: 'Please ensure the risotto is extra creamy. No parsley garnish.',
                  primaryActionText: 'Finish',
                ),
                const SizedBox(height: 16),
                _buildOrderCard(
                  customerName: 'Elena Rossi',
                  orderNumber: '#2415',
                  timeInfo: '8m left',
                  timeIsUrgent: false,
                  subInfo: 'Pick-up @ 19:30',
                  items: [
                    {'qty': 1, 'name': 'Wagyu Beef Carpaccio', 'price': '\$38.00'},
                    {'qty': 1, 'name': 'Lobster Thermidor', 'price': '\$85.00'},
                  ],
                  primaryActionText: 'Finish',
                  hasOptions: true,
                ),
                const SizedBox(height: 16),
                _buildOrderCard(
                  customerName: 'Marcus Lee',
                  orderNumber: '#2419',
                  timeInfo: 'NEW',
                  timeIsUrgent: false,
                  subInfo: 'ASAP Delivery',
                  items: [
                    {'qty': 4, 'name': 'Pan-Seared Scallops', 'price': '\$112.00'},
                  ],
                  primaryActionText: 'Accept Order',
                  secondaryActionText: 'Decline',
                  isNew: true,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required String customerName,
    required String orderNumber,
    required String timeInfo,
    required bool timeIsUrgent,
    required String subInfo,
    required List<Map<String, dynamic>> items,
    String? note,
    required String primaryActionText,
    String? secondaryActionText,
    bool hasOptions = false,
    bool isNew = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isNew ? AppColors.primary.withOpacity(0.05) : AppColors.surfaceContainerHigh.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNew ? AppColors.primary.withOpacity(0.4) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerLow,
                    child: Icon(Icons.person, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(customerName, style: AppTextStyles.headlineMd(color: Colors.white)),
                      Text(orderNumber, style: AppTextStyles.labelMono(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: isNew ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4) : null,
                    decoration: isNew ? BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ) : null,
                    child: Text(
                      timeInfo,
                      style: AppTextStyles.labelMono(
                        color: isNew ? AppColors.onPrimary : (timeIsUrgent ? AppColors.error : AppColors.primary),
                      ).copyWith(fontWeight: timeIsUrgent ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                  if (!isNew)
                    Text(subInfo, style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withOpacity(0.6))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('${item['qty']}', style: AppTextStyles.labelMono(color: AppColors.primary)),
                    ),
                    const SizedBox(width: 12),
                    Text(item['name'], style: AppTextStyles.bodyMd(color: Colors.white)),
                  ],
                ),
                Text(item['price'], style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
              ],
            ),
          )),
          
          if (note != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(note, style: AppTextStyles.labelSm(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          Divider(color: AppColors.outlineVariant.withOpacity(0.1)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (secondaryActionText != null) ...[
                Expanded(
                  child: MaterialButton(
                    onPressed: () {},
                    color: AppColors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: AppColors.outlineVariant),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(secondaryActionText, style: AppTextStyles.headlineMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.magentaGloss,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: MaterialButton(
                    onPressed: () {},
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(primaryActionText, style: AppTextStyles.headlineMd(color: AppColors.onPrimary).copyWith(fontSize: 14)),
                  ),
                ),
              ),
              if (hasOptions || secondaryActionText == null) ...[
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: IconButton(
                    icon: Icon(hasOptions ? Icons.more_vert : Icons.print, color: Colors.white),
                    onPressed: () {},
                  ),
                )
              ]
            ],
          ),
        ],
      ),
    );
  }
}
