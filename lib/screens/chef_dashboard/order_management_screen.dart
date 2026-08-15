import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/order_model.dart';
import '../chat/chat_screen.dart';

class ChefOrdersScreen extends StatefulWidget {
  const ChefOrdersScreen({super.key});

  @override
  State<ChefOrdersScreen> createState() => _ChefOrdersScreenState();
}

class _ChefOrdersScreenState extends State<ChefOrdersScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Pending', 'Active', 'Preparing', 'Ready', 'Completed', 'Cancelled'];
  bool _isLoading = true;
  List<OrderModel> _orders = [];
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _silentLoadOrders();
    });
  }

  Future<void> _silentLoadOrders() async {
    try {
      final orders = await ApiService.getOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await ApiService.getOrders();
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

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Pending': return 'Active'; // For dine-in
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
            icon: const Icon(Icons.refresh, color: AppColors.primary),
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
                      color: isSelected ? AppColors.primaryContainer : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      border: isSelected ? Border.all(color: AppColors.primary.withValues(alpha: 0.2)) : null,
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    color: AppColors.primary,
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
                          final nextStatus = _getNextStatus(order.status);
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildOrderCard(
                              order: order,
                              primaryActionText: nextStatus.isNotEmpty ? (order.status == 'Pending' ? 'Confirm Booking' : 'Mark $nextStatus') : '',
                              secondaryActionText: (order.status == 'Active' || order.status == 'Pending') ? (order.status == 'Pending' ? 'Reject' : 'Cancel') : null,
                              onPrimaryAction: nextStatus.isNotEmpty ? () => _updateOrderStatus(order.id, nextStatus) : null,
                              onSecondaryAction: order.status == 'Active' ? () => _updateOrderStatus(order.id, 'Cancelled') : null,
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
          color: Colors.white.withValues(alpha: 0.05),
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
                    child: const Icon(Icons.receipt, color: AppColors.onSurfaceVariant),
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
                      Text(order.date, style: AppTextStyles.labelMono(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  if (onContactCustomer != null)
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                      onPressed: onContactCustomer,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onContactCustomer != null) const SizedBox(width: 8),
                  Text('\$${order.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.headlineMd(color: AppColors.primary)),
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
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('$qty', style: AppTextStyles.labelMono(color: AppColors.primary)),
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
                                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(
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
                  Text('\$${(double.parse(price.toString()) * qty).toStringAsFixed(2)}', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }),
          
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(order.notes!, style: AppTextStyles.labelSm(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
          Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
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
                      side: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(secondaryActionText, style: AppTextStyles.headlineMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 14)),
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
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 10,
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
