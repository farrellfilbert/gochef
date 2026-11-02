import 'package:flutter/material.dart';
import 'package:go_chef_app/theme/app_colors.dart';
import 'package:go_chef_app/theme/app_text_styles.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/api_service.dart';
import '../../models/order_model.dart';
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
    _ordersFuture = ApiService.getOrders(forChef: false);
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = ApiService.getOrders(forChef: false);
    });
    await _ordersFuture;
  }

  Future<void> _handleReorder(OrderModel order) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final kId = int.tryParse(order.kitchenId);
      final menuItems = await ApiService.getMenuItems(kitchenId: kId);
      int addedCount = 0;

      for (final orderItem in order.items) {
        final match = menuItems.where((m) => m.name.toLowerCase().trim() == orderItem.name.toLowerCase().trim()).toList();
        if (match.isNotEmpty) {
          final success = await ApiService.addToCart(match.first.id, quantity: orderItem.quantity);
          if (success) addedCount++;
        }
      }

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog

        if (addedCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Added $addedCount item(s) from ${order.kitchenName} to cart!'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'VIEW CART',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                },
              ),
            ),
          );
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('These items are currently out of stock or unavailable.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reorder: $e')),
        );
      }
    }
  }

  Future<void> _handleCancelOrder(OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Order?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to cancel Order #${order.id} from ${order.kitchenName}? Any charged amount will be refunded immediately.',
          style: const TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Order', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.updateOrderStatus(order.id, 'Cancelled');
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order #${order.id} has been cancelled.'), backgroundColor: Colors.redAccent),
          );
          _refreshOrders();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to cancel order. Please contact support.')),
          );
        }
      }
    }
  }

  void _showReceiptModal(BuildContext context, OrderModel order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16161D),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.receipt_long, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('GoChef Order Receipt', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('#${order.id}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.kitchenName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              order.status,
                              style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(order.date, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      if (order.deliveryAddress.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text('Deliver to: ${order.deliveryAddress}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                      const Divider(color: Colors.white12, height: 24),
                      const Text('ORDER ITEMS', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 8),
                      if (order.items.isNotEmpty)
                        ...order.items.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x ${item.name}',
                                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          );
                        })
                      else
                        Text('${order.itemsCount} item(s)', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const Divider(color: Colors.white12, height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Paid', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text('Paid with Card / Direct Checkout', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final receiptText = 'GoChef Order Receipt\n'
                              'Order ID: #${order.id}\n'
                              'Kitchen: ${order.kitchenName}\n'
                              'Date: ${order.date}\n'
                              'Total: \$${order.totalAmount.toStringAsFixed(2)}\n'
                              'Status: ${order.status}\n'
                              'thegrubnextdoor.com';
                          Share.share(receiptText);
                        },
                        icon: const Icon(Icons.share, color: Colors.white, size: 18),
                        label: const Text('Share Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Done', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Order History', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 2),
            Text('Keep track of your favorite meals', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ],
        ),
        actions: const [
          NotificationBell(),
          CartIconButton(),
          SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        color: Colors.white,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    final isSelected = _selectedFilter == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          _filters[index],
                          style: AppTextStyles.labelSm(
                            color: isSelected ? Colors.black : AppColors.onSurfaceVariant,
                          ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = index;
                            });
                          }
                        },
                        selectedColor: Colors.white,
                        backgroundColor: AppColors.surfaceContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.white : AppColors.outlineVariant.withValues(alpha: 0.2),
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              FutureBuilder<List<OrderModel>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Failed to load orders', style: AppTextStyles.headlineMd(color: Colors.white)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _refreshOrders,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final orders = snapshot.data ?? [];
                  final filterName = _filters[_selectedFilter];
                  final filteredOrders = orders.where((order) {
                    if (filterName == 'All') return true;
                    if (filterName == 'Active') {
                      return order.status == 'Pending' || order.status == 'Active' || order.status == 'Preparing' || order.status == 'Ready';
                    }
                    if (filterName == 'Scheduled') return order.status == 'Scheduled';
                    if (filterName == 'Completed') return order.status == 'Completed' || order.status == 'Delivered';
                    if (filterName == 'Cancelled') return order.status == 'Cancelled';
                    return true;
                  }).toList();

                  if (filteredOrders.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainer,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 16),
                            Text('No orders found', style: AppTextStyles.headlineMd(color: Colors.white)),
                            const SizedBox(height: 8),
                            Text('You haven\'t placed any orders matching this category yet.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: filteredOrders.map((order) {
                      final itemsSummary = order.items.isNotEmpty
                          ? order.items.map((i) => '${i.quantity}x ${i.name}').join(', ')
                          : '${order.itemsCount} item(s)';
                      final canCancel = (order.status == 'Pending' || order.status == 'Placed' || order.status == 'Active' || order.status == 'Scheduled');

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildOrderCard(
                          chefName: order.kitchenName,
                          dateStr: order.date,
                          orderId: '#${order.id}',
                          status: order.status,
                          avatar: order.avatar.isNotEmpty ? order.avatar : 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=500',
                          itemsStr: itemsSummary,
                          price: '\$${order.totalAmount.toStringAsFixed(2)}',
                          orderType: order.orderType,
                          dineInDate: order.dineInDate,
                          dineInTime: order.dineInTime,
                          canCancel: canCancel,
                          onCancel: canCancel ? () => _handleCancelOrder(order) : null,
                          onReceipt: () => _showReceiptModal(context, order),
                          onChat: order.kitchenUserId.isNotEmpty
                              ? () {
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
                                }
                              : null,
                          onRate: (order.status == 'Completed' || order.status == 'Delivered')
                              ? () {
                                  RateOrderDialog.show(
                                    context,
                                    orderId: order.id,
                                    kitchenId: int.tryParse(order.kitchenId),
                                    kitchenName: order.kitchenName,
                                    kitchenAvatar: order.avatar,
                                    onSubmitted: () => _refreshOrders(),
                                  );
                                }
                              : null,
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
                          onReorder: () => _handleReorder(order),
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
    bool canCancel = false,
    VoidCallback? onCancel,
    required VoidCallback onReceipt,
    VoidCallback? onRate,
    required VoidCallback onDetails,
    required VoidCallback onReorder,
    VoidCallback? onChat,
  }) {
    bool isDelivered = status == 'Completed' || status == 'Delivered';
    bool isCancelled = status == 'Cancelled';

    Color statusColor = Colors.orange;
    if (isDelivered) statusColor = Colors.greenAccent;
    if (isCancelled) statusColor = Colors.redAccent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$dateStr • $orderId',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
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

          const SizedBox(height: 14),
          Text(itemsStr, style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(price, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (onChat != null)
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        color: Colors.white70,
                        onPressed: onChat,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        padding: EdgeInsets.zero,
                      ),
                    // Receipt button
                    OutlinedButton(
                      onPressed: onReceipt,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text('Receipt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    if (canCancel && onCancel != null)
                      OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.4)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('Cancel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    if (onRate != null)
                      TextButton.icon(
                        onPressed: onRate,
                        icon: const Icon(Icons.star, color: Colors.amber, size: 14),
                        label: const Text('Rate', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ElevatedButton(
                      onPressed: onDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(isDelivered ? 'Details' : 'Track', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    if (!isCancelled)
                      ElevatedButton(
                        onPressed: onReorder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(isDelivered ? 'Reorder' : 'Order Again', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
