import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../services/audio_service.dart';
import '../../models/order_model.dart';
import '../chat/chat_screen.dart';

class ChefOrdersScreen extends StatefulWidget {
  const ChefOrdersScreen({super.key});

  @override
  State<ChefOrdersScreen> createState() => _ChefOrdersScreenState();
}

class _ChefOrdersScreenState extends State<ChefOrdersScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Pending', 'Scheduled', 'Active', 'Preparing', 'Ready', 'Completed', 'Cancelled'];
  bool _isLoading = true;
  List<OrderModel> _orders = [];
  int _prevOrdersLength = -1;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    AudioService.unlock();
    _loadOrders();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _silentLoadOrders();
    });
  }

  Future<void> _silentLoadOrders() async {
    try {
      final orders = await ApiService.getOrders();
      _checkScheduledOrders(orders);
      if (mounted) {
        if (_prevOrdersLength >= 0 && orders.length > _prevOrdersLength) {
          AudioService.playOrder();
        }
        _prevOrdersLength = orders.length;
        setState(() {
          _orders = orders;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  void _checkScheduledOrders(List<OrderModel> orders) {
    final now = DateTime.now();
    for (var order in orders) {
      if (order.status == 'Scheduled' && (order.dineInDate?.isNotEmpty == true) && (order.dineInTime?.isNotEmpty == true)) {
        try {
          // Assuming format: yyyy-MM-dd and HH:mm
          // Adding :00 for seconds to make it ISO 8601 parsable
          final time = order.dineInTime!;
          final timeStr = time.length == 5 ? '$time:00' : time;
          final targetTime = DateTime.parse('${order.dineInDate} $timeStr');
          final diff = targetTime.difference(now).inMinutes;
          
          if (diff <= 30) {
            // Auto-activate the scheduled order
            ApiService.updateOrderStatus(order.id, 'Active');
            // Optimistically update local list so it moves instantly
            order.status = 'Active';
          }
        } catch (e) {
          debugPrint('Error parsing scheduled time: $e');
        }
      }
    }
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await ApiService.getOrders();
      _checkScheduledOrders(orders);
      if (mounted) {
        setState(() {
          _orders = orders;
        });
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    final success = await ApiService.updateOrderStatus(orderId, newStatus);
    if (success) {
      _loadOrders(); // Refresh the list
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update order status')),
        );
      }
    }
  }

  Future<void> _requestUberDelivery(String orderId) async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.requestUberDelivery(orderId);
      if (res != null && res['success'] == true) {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Uber Courier is on the way! 🚗'), backgroundColor: Colors.green),
           );
         }
         _loadOrders();
      } else {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(res?['error'] ?? 'Failed to call Uber'), backgroundColor: Colors.red),
           );
         }
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getNextStatus(OrderModel order) {
    if (order.status == 'Pending') {
      return (order.orderType == 'dine_in' || (order.dineInDate?.isNotEmpty == true)) ? 'Scheduled' : 'Active';
    }
    switch (order.status) {
      case 'Scheduled': return 'Active';
      case 'Active': return 'Preparing';
      case 'Preparing': return 'Ready';
      case 'Ready': return 'Completed';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter orders based on selected tab
    final selectedStatus = _tabs[_selectedTabIndex];
    final filteredOrders = _orders.where((o) => o.status == selectedStatus).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        title: const Text('Order Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            height: 50,
            color: AppColors.background.withValues(alpha: 0.95),
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
                      color: isSelected ? Colors.white : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? Colors.white : AppColors.outlineVariant.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Text(
                      _tabs[index],
                      style: AppTextStyles.labelMono(
                        color: isSelected ? Colors.black : Colors.white,
                      ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    color: Colors.white,
                    child: filteredOrders.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                              Center(
                                child: Text(
                                  'No $selectedStatus orders',
                                  style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredOrders.length,
                            itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final nextStatus = _getNextStatus(order);
                          
                          String primaryBtnText = '';
                          VoidCallback? onPrimaryActionCallback;
                          
                          if (nextStatus.isNotEmpty) {
                            if (order.status == 'Pending') {
                              primaryBtnText = (order.orderType == 'dine_in' || (order.dineInDate?.isNotEmpty == true)) ? 'Confirm Booking' : 'Accept Order';
                              onPrimaryActionCallback = () => _updateOrderStatus(order.id, nextStatus);
                            } else if (order.status == 'Scheduled') {
                              primaryBtnText = 'Start Cooking Now'; // Manual override
                              onPrimaryActionCallback = () => _updateOrderStatus(order.id, nextStatus);
                            } else if (order.status == 'Ready' && order.orderType != 'dine_in') {
                              primaryBtnText = 'Request Uber Delivery';
                              onPrimaryActionCallback = () => _requestUberDelivery(order.id);
                            } else {
                              primaryBtnText = 'Mark $nextStatus';
                              onPrimaryActionCallback = () => _updateOrderStatus(order.id, nextStatus);
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildOrderCard(
                              order: order,
                              primaryActionText: primaryBtnText,
                              secondaryActionText: (order.status == 'Active' || order.status == 'Pending' || order.status == 'Scheduled') ? (order.status == 'Pending' ? 'Reject' : 'Cancel') : null,
                              onPrimaryAction: onPrimaryActionCallback,
                              onSecondaryAction: (order.status == 'Active' || order.status == 'Scheduled') ? () => _updateOrderStatus(order.id, 'Cancelled') : null,
                              onContactCustomer: order.userId.isNotEmpty ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      otherParticipantId: order.userId,
                                      otherParticipantName: order.customerName.isNotEmpty ? order.customerName : 'Customer',
                                      otherParticipantAvatar: order.customerAvatar,
                                      orderId: order.id,
                                    ),
                                  ),
                                );
                              } : null,
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required OrderModel order,
    required String primaryActionText,
    String? secondaryActionText,
    VoidCallback? onPrimaryAction,
    VoidCallback? onSecondaryAction,
    VoidCallback? onContactCustomer,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
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
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    child: const Icon(Icons.receipt_long, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Order ${order.id}', style: AppTextStyles.headlineMd(color: Colors.white)),
                          if (order.orderType == 'dine_in') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(4)),
                              child: const Text('DINE-IN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      Text(order.date, style: AppTextStyles.labelMono(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  if (onContactCustomer != null)
                    GestureDetector(
                      onTap: onContactCustomer,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                      ),
                    ),
                  if (onContactCustomer != null) const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (order.orderType == 'dine_in' && order.dineInDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.withValues(alpha: 0.3))),
              child: Row(
                children: [
                  const Icon(Icons.table_restaurant, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text('Booking: ${order.dineInDate} at ${order.dineInTime ?? ""}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          ...order.items.map((item) {
             final qty = item.quantity;
             final name = item.name;
             final price = item.price;
             return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(top: 2),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text('$qty', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.bodyMd(color: Colors.white)),
                              if (item.options.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.options,
                                  style: AppTextStyles.labelSm(color: Colors.white60).copyWith(
                                    height: 1.3,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('\$${(double.parse(price.toString()) * qty).toStringAsFixed(2)}', style: AppTextStyles.labelSm(color: Colors.white70)),
                ],
              ),
            );
          }),
          
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(order.notes!, style: AppTextStyles.labelSm(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],

          // ─── Resi & Keterangan Pengantaran Card ───
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resi / Tracking Code & Order Method
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.qr_code_2, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Resi: GC-${order.id.padLeft(6, "0")}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        order.orderType == 'dine_in' ? 'Dine-In Booking' : 'ASAP Delivery',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(color: Colors.white12, height: 1),
                ),
                // Customer Name & Phone
                Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.white70, size: 15),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.customerName.isNotEmpty ? order.customerName : 'Customer',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    if (order.customerPhone.isNotEmpty) ...[
                      const Icon(Icons.phone_outlined, color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        order.customerPhone,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ],
                ),
                // Destination Address
                if (order.deliveryAddress.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.white70, size: 15),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.deliveryAddress,
                          style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                // Voucher / Promo Info
                if (order.promoCode != null && order.promoCode!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.loyalty, color: Colors.greenAccent, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Voucher: ${order.promoCode} (- \$${order.discountAmount.toStringAsFixed(2)})',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          Divider(color: Colors.white12),
          const SizedBox(height: 8),
          Row(
            children: [
              if (secondaryActionText != null && onSecondaryAction != null) ...[
                Expanded(
                  child: MaterialButton(
                    onPressed: onSecondaryAction,
                    color: AppColors.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.white24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(secondaryActionText, style: AppTextStyles.headlineMd(color: Colors.white70).copyWith(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (primaryActionText.isNotEmpty && onPrimaryAction != null)
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.magentaGloss,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: MaterialButton(
                      onPressed: onPrimaryAction,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(primaryActionText, style: AppTextStyles.headlineMd(color: AppColors.onPrimary).copyWith(fontSize: 14)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
