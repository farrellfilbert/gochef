import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import '../notifications/notifications_screen.dart';
import '../../services/api_service.dart';
import '../../models/order_model.dart';
import '../../widgets/custom_app_bar_title.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/cart_icon_button.dart';
import '../chat/chat_screen.dart';
import '../tracking/order_tracking_screen.dart';
import '../cart/cart_screen.dart';
import '../../widgets/rate_order_dialog.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Active', 'Scheduled', 'Completed', 'Cancelled'];
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = ApiService.getOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = ApiService.getOrders();
    });
    await _ordersFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        title: const CustomAppBarTitle(),
        actions: const [
          CartIconButton(iconColor: Colors.white),
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: NotificationBell(iconColor: Colors.white),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        color: AppColors.primary,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 120),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order History', style: AppTextStyles.headlineLgMobile(color: AppColors.onBackground)),
            const SizedBox(height: 16),
            
            // Search
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: TextField(
                style: AppTextStyles.bodyMd(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search past orders',
                  hintStyle: AppTextStyles.bodyMd(color: Colors.white.withValues(alpha: 0.7)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Filters
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  bool isSelected = _selectedFilter == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isSelected ? Colors.white : AppColors.outlineVariant.withValues(alpha: 0.15),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _filters[index],
                        style: AppTextStyles.labelSm(
                          color: isSelected ? Colors.black : Colors.white,
                        ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            
            // Order Cards
            FutureBuilder<List<OrderModel>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.primary)));
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No orders found.', style: TextStyle(color: Colors.white))));
                }
                
                final orders = snapshot.data!;
                List<OrderModel> filteredOrders = orders;
                if (_selectedFilter != 0) {
                  final filterMap = {1: 'Active', 2: 'Scheduled', 3: 'Completed', 4: 'Cancelled'};
                  filteredOrders = orders.where((o) => o.status == filterMap[_selectedFilter]).toList();
                }

                if (filteredOrders.isEmpty) {
                  return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No orders matching filter.', style: TextStyle(color: Colors.white))));
                }

                return Column(
                  children: filteredOrders.map((order) {
                    final itemsStr = order.items.isNotEmpty 
                        ? '${order.items[0].name} + ${order.itemsCount - 1 > 0 ? (order.itemsCount - 1).toString() + ' items' : ''}'
                        : '${order.itemsCount} items';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                          child: _buildOrderCard(
                              chefName: order.kitchenName,
                              dateStr: order.date.split(' • ')[0],
                              orderId: order.id,
                              status: (order.status == 'Active' && order.orderType != 'dine_in') ? 'Scheduled' : order.status,
                              avatar: order.avatar.isNotEmpty ? order.avatar : 'https://via.placeholder.com/150',
                              itemsStr: itemsStr,
                              price: '\$${order.totalAmount.toStringAsFixed(2)}',
                              orderType: order.orderType,
                              dineInDate: order.dineInDate,
                              dineInTime: order.dineInTime,
                              onChat: order.kitchenUserId.isNotEmpty ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  otherParticipantId: order.kitchenUserId,
                                  otherParticipantName: order.kitchenName,
                                  otherParticipantAvatar: order.avatar.isNotEmpty ? order.avatar : 'https://via.placeholder.com/150',
                                  orderId: order.id,
                                  kitchenId: order.kitchenId,
                                ),
                              ),
                            );
                          } : null,
                          onRate: (order.status == 'Completed' || order.status == 'Delivered') ? () {
                            RateOrderDialog.show(
                              context,
                              orderId: order.id,
                              kitchenId: int.tryParse(order.kitchenId),
                              kitchenName: order.kitchenName,
                              kitchenAvatar: order.avatar,
                              onSubmitted: () => _refreshOrders(),
                            );
                          } : null,
                          onDetails: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderTrackingScreen(
                                  orderId: order.id,
                                  kitchenId: order.kitchenId,
                                  kitchenName: order.kitchenName,
                                  totalAmount: order.totalAmount,
                                  itemsCount: order.itemsCount,
                                  kitchenAvatar: order.avatar.isNotEmpty ? order.avatar : 'https://via.placeholder.com/150',
                                  initialStatus: order.status,
                                ),
                              ),
                            );
                          },
                          onReorder: () async {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reordering...')));
                            try {
                              final menuItems = await ApiService.getMenuItems(kitchenId: int.tryParse(order.kitchenId));
                              bool addedAny = false;
                              for (final orderItem in order.items) {
                                final match = menuItems.where((m) => m.name == orderItem.name).toList();
                                if (match.isNotEmpty) {
                                  await ApiService.addToCart(match.first.id, quantity: orderItem.quantity);
                                  addedAny = true;
                                }
                              }
                              if (mounted) {
                                if (addedAny) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu items no longer available')));
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                              }
                            }
                          },
                        ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildOrderCard({
    required String chefName,
    required String dateStr,
    required String orderId,
    required String status,
    required String avatar,
    required String itemsStr,
    required String price,
    String? orderType,
    String? dineInDate,
    String? dineInTime,
    VoidCallback? onRate,
    required VoidCallback onDetails,
    required VoidCallback onReorder,
    VoidCallback? onChat,
  }) {
    bool isDelivered = status == 'Completed' || status == 'Delivered';
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF31353F).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA98890).withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                        image: DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chefName, 
                            style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$dateStr • $orderId', 
                            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDelivered ? Colors.green.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: isDelivered ? Colors.green.withValues(alpha: 0.2) : AppColors.error.withValues(alpha: 0.2)),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.labelSm(color: isDelivered ? Colors.greenAccent : AppColors.error).copyWith(fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          
          if (orderType == 'dine_in') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.table_restaurant, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text('Dine-In Booking: ${dineInDate ?? ""} ${dineInTime ?? ""}', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          Text(itemsStr, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(price, style: AppTextStyles.headlineMd(color: Colors.white)),
              Row(
                children: [
                  if (onChat != null)
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      color: AppColors.primary,
                      onPressed: onChat,
                    ),
                  if (onRate != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ElevatedButton(
                        onPressed: onRate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.withValues(alpha: 0.15),
                          foregroundColor: Colors.amber,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                            side: const BorderSide(color: Colors.amber, width: 1),
                          ),
                        ),
                        child: const Text('⭐ Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: onDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.onSurfaceVariant,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    ),
                    child: Text(isDelivered ? 'Details' : 'Support', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onReorder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDelivered ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                      foregroundColor: isDelivered ? Colors.white : AppColors.onSurface,
                      elevation: isDelivered ? 8 : 0,
                      shadowColor: isDelivered ? AppColors.primaryContainer.withValues(alpha: 0.5) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                        side: isDelivered ? BorderSide.none : BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: Text(isDelivered ? 'Reorder' : 'Try Again', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
