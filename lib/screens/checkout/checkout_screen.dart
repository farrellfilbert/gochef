import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'order_complete_screen.dart';
import '../../services/api_service.dart';
import '../../models/address_model.dart';
import '../../models/cart_item_model.dart';
import '../profile/address_selection_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int kitchenId;
  const CheckoutScreen({super.key, required this.kitchenId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isAsap = true;
  String selectedPayment = 'mastercard'; // 'mastercard', 'apple', 'google'
  bool isOrdering = false;
  
  bool _isLoading = true;
  AddressModel? _primaryAddress;
  double _grandTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    setState(() => _isLoading = true);
    try {
      final allItems = await ApiService.getCart();
      final items = allItems.where((i) => i.kitchenId == widget.kitchenId).toList();
      final addresses = await ApiService.getAddresses();
      
      double subtotal = 0;
      for (var item in items) {
        subtotal += item.totalPrice;
      }
      double deliveryFee = items.isNotEmpty ? 4.00 : 0.00;
      double serviceFee = items.isNotEmpty ? 2.50 : 0.00;
      
      setState(() {
        _grandTotal = subtotal + deliveryFee + serviceFee;
        if (addresses.isNotEmpty) {
          _primaryAddress = addresses.firstWhere(
            (a) => a.isDefault,
            orElse: () => addresses.first,
          );
        }
      });
    } catch (e) {
      debugPrint('Error loading checkout: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _placeOrder() async {
    if (_primaryAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a delivery address first'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() {
      isOrdering = true;
    });

    final result = await ApiService.checkout(
      addressId: _primaryAddress!.id,
      kitchenId: widget.kitchenId,
      notes: isAsap ? 'ASAP Delivery' : 'Scheduled Delivery',
    );

    if (mounted) {
      if (result != null && result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OrderCompleteScreen(
            orderId: result['order_id'] ?? 'Unknown',
            kitchenName: result['kitchen_name'] ?? 'Unknown Kitchen',
            totalAmount: (result['total'] ?? 0).toDouble(),
            itemsCount: result['items_count'] ?? 0,
          )),
        );
      } else {
        setState(() {
          isOrdering = false;
        });
        final errorMsg = (result != null && result['error'] != null) ? result['error'].toString() : 'Failed to place order';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppColors.error, duration: const Duration(seconds: 5)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Checkout',
            style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.outlineVariant.withValues(alpha: 0.1), height: 1),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Delivery Address',
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    TextButton(
                      onPressed: () async {
                        final selected = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddressSelectionScreen(
                              isSelectionMode: true,
                              currentAddress: _primaryAddress,
                            ),
                          ),
                        );
                        if (selected != null && selected is AddressModel) {
                          setState(() => _primaryAddress = selected);
                        }
                      },
                      child: Text('Edit', style: AppTextStyles.labelMono(color: AppColors.primary)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final selected = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddressSelectionScreen(
                          isSelectionMode: true,
                          currentAddress: _primaryAddress,
                        ),
                      ),
                    );
                    if (selected != null && selected is AddressModel) {
                      setState(() => _primaryAddress = selected);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_primaryAddress?.label ?? 'No Address Set',
                                style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_primaryAddress != null ? _primaryAddress!.address : 'Please add an address',
                                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant.withValues(alpha: 0.8))),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                ),
                const SizedBox(height: 16),

                // Delivery Time
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isAsap = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isAsap ? const Color(0xFFE42278) : Colors.transparent,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: isAsap
                                  ? [BoxShadow(color: const Color(0xFFE42278).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 4))]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'ASAP (25-35 min)',
                              style: AppTextStyles.bodyMd(
                                color: isAsap ? AppColors.onSurface : AppColors.onSurfaceVariant,
                              ).copyWith(fontWeight: isAsap ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isAsap = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !isAsap ? const Color(0xFFE42278) : Colors.transparent,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: !isAsap
                                  ? [BoxShadow(color: const Color(0xFFE42278).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 4))]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Schedule',
                              style: AppTextStyles.bodyMd(
                                color: !isAsap ? AppColors.onSurface : AppColors.onSurfaceVariant,
                              ).copyWith(fontWeight: !isAsap ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Payment Method
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payment Method',
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    TextButton(
                      onPressed: () {},
                      child: Text('Change', style: AppTextStyles.labelMono(color: AppColors.primary)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                
                // Mastercard
                GestureDetector(
                  onTap: () => setState(() => selectedPayment = 'mastercard'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedPayment == 'mastercard'
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                          ),
                          child: const Icon(Icons.credit_card, color: AppColors.onSurface),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mastercard', style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                              Text('•••• 8829', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedPayment == 'mastercard' ? AppColors.primary : AppColors.outline,
                              width: 2,
                            ),
                          ),
                          child: selectedPayment == 'mastercard'
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : null,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Alt methods
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedPayment = 'apple'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedPayment == 'apple' ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.apple, color: Colors.white, size: 28),
                              const SizedBox(height: 4),
                              Text('Apple Pay', style: AppTextStyles.labelSm(color: AppColors.onSurface)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedPayment = 'google'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selectedPayment == 'google' ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent,
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.g_mobiledata, color: Colors.white, size: 36),
                              Text('Google Pay', style: AppTextStyles.labelSm(color: AppColors.onSurface)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                // Summary
                Text('Order Summary', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                          Text('\$${_grandTotal.toStringAsFixed(2)}', style: AppTextStyles.headlineLgMobile(color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Fixed Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, -5))
                ],
              ),
              child: isOrdering
                  ? Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        elevation: 8,
                        shadowColor: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock, size: 18),
                          const SizedBox(width: 8),
                          Text('Place Order • \$${_grandTotal.toStringAsFixed(2)}',
                              style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
