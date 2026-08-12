import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/order_model.dart';

class ChefOrdersScreen extends StatefulWidget {
  const ChefOrdersScreen({super.key});

  @override
  State<ChefOrdersScreen> createState() => _ChefOrdersScreenState();
}

class _ChefOrdersScreenState extends State<ChefOrdersScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Active', 'Preparing', 'Ready', 'Completed', 'Cancelled'];
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
                              orderId: order.id,
                              orderDate: order.date,
                              totalAmount: '\$${order.totalAmount.toStringAsFixed(2)}',
                              status: order.status,
                              items: order.items ?? [],
                              note: order.notes,
                              primaryActionText: nextStatus.isNotEmpty ? 'Mark $nextStatus' : '',
                              secondaryActionText: order.status == 'Active' ? 'Cancel' : null,
                              onPrimaryAction: nextStatus.isNotEmpty ? () => _updateOrderStatus(order.id, nextStatus) : null,
                              onSecondaryAction: order.status == 'Active' ? () => _updateOrderStatus(order.id, 'Cancelled') : null,
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
    required String orderId,
    required String orderDate,
    required String totalAmount,
    required String status,
    required List<OrderItemModel> items,
    String? note,
    required String primaryActionText,
    String? secondaryActionText,
    VoidCallback? onPrimaryAction,
    VoidCallback? onSecondaryAction,
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
                      Text('Order $orderId', style: AppTextStyles.headlineMd(color: Colors.white)),
                      Text(orderDate, style: AppTextStyles.labelMono(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
              Text(totalAmount, style: AppTextStyles.headlineMd(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) {
             final qty = item.quantity;
             final name = item.name;
             final price = item.price;
             return Padding(
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
                        child: Text('$qty', style: AppTextStyles.labelMono(color: AppColors.primary)),
                      ),
                      const SizedBox(width: 12),
                      Text(name, style: AppTextStyles.bodyMd(color: Colors.white)),
                    ],
                  ),
                  Text('\$${(double.parse(price.toString()) * qty).toStringAsFixed(2)}', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                ],
              ),
            );
          }),
          
          if (note != null && note.isNotEmpty) ...[
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
                    child: Text(note, style: AppTextStyles.labelSm(color: Colors.white)),
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
