import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../checkout/checkout_screen.dart';
import '../../services/api_service.dart';
import '../../models/cart_item_model.dart';
import '../../models/address_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;
  List<CartItemModel> _cartItems = [];
  AddressModel? _primaryAddress;

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    setState(() => _isLoading = true);
    try {
      final items = await ApiService.getCart();
      final addresses = await ApiService.getAddresses();
      
      setState(() {
        _cartItems = items;
        if (addresses.isNotEmpty) {
          try {
            _primaryAddress = addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            );
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQuantity(int cartItemId, int newQuantity) async {
    // Basic quantity update logic - for now, assuming delete if 0, else we'd need an updateCart API
    if (newQuantity <= 0) {
      await _removeFromCart(cartItemId);
    } else {
      // If we had an update endpoint, we'd call it here. 
      // Since we don't, we'll just local update or suggest remove/add.
      // We will skip actual backend update for quantity if endpoint is missing, 
      // but let's assume we can remove and re-add or just do local update for UI demonstration.
      final index = _cartItems.indexWhere((i) => i.cartItemId == cartItemId);
      if (index != -1) {
        setState(() {
          _cartItems[index] = CartItemModel(
            cartItemId: _cartItems[index].cartItemId,
            menuItemId: _cartItems[index].menuItemId,
            name: _cartItems[index].name,
            price: _cartItems[index].price,
            image: _cartItems[index].image,
            prepTime: _cartItems[index].prepTime,
            quantity: newQuantity,
            notes: _cartItems[index].notes,
            kitchenName: _cartItems[index].kitchenName,
            kitchenAvatar: _cartItems[index].kitchenAvatar,
            kitchenId: _cartItems[index].kitchenId,
            addons: _cartItems[index].addons,
          );
        });
      }
    }
  }

  Future<void> _removeFromCart(int cartItemId) async {
    final success = await ApiService.removeFromCart(cartItemId);
    if (success) {
      setState(() {
        _cartItems.removeWhere((item) => item.cartItemId == cartItemId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from cart'), backgroundColor: AppColors.primary),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate totals
    double subtotal = 0;
    for (var item in _cartItems) {
      subtotal += item.totalPrice;
    }
    double deliveryFee = _cartItems.isNotEmpty ? 4.00 : 0.00;
    double serviceFee = _cartItems.isNotEmpty ? 2.50 : 0.00;
    double grandTotal = subtotal + deliveryFee + serviceFee;

    return Scaffold(
      backgroundColor: AppColors.midnight,
      body: Stack(
        children: [
          // ─── Main Scrollable Content ───
          SafeArea(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      top: 80, // Space for fixed header
                      bottom: 140, // Space for fixed footer
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Delivery Address ───
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.glassBackground,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.location_on, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Deliver to',
                                            style: AppTextStyles.labelSm(
                                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                                            ),
                                          ),
                                          Text(
                                            _primaryAddress?.label ?? 'No address set',
                                            style: AppTextStyles.bodyMd(color: AppColors.onSurface)
                                                .copyWith(fontWeight: FontWeight.bold),
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                          ),
                                          if (_primaryAddress != null)
                                            Text(
                                              _primaryAddress!.address,
                                              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                                              maxLines: 1, overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'Change',
                                  style: AppTextStyles.labelMono(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Order Details ───
                        Text(
                          'Order Details',
                          style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                        ),
                        const SizedBox(height: 12),
                        
                        if (_cartItems.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text('Your cart is empty', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
                            ),
                          )
                        else
                          ..._cartItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildCartItem(item),
                            );
                          }),
                        
                        const SizedBox(height: 12),

                        // ─── Promo Code ───
                        if (_cartItems.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.glassBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.loyalty, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                                    decoration: InputDecoration(
                                      hintText: 'Promo code or coupon',
                                      hintStyle: AppTextStyles.bodyMd(
                                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Apply',
                                    style: AppTextStyles.labelMono(color: AppColors.primary)
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),

                        // ─── Order Summary ───
                        if (_cartItems.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.glassBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: Column(
                              children: [
                                _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                                const SizedBox(height: 12),
                                _buildSummaryRow('Delivery Fee', '\$${deliveryFee.toStringAsFixed(2)}'),
                                const SizedBox(height: 12),
                                _buildSummaryRow('Service Fee', '\$${serviceFee.toStringAsFixed(2)}'),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(color: AppColors.ghostBorder),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total',
                                      style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                                    ),
                                    Text(
                                      '\$${grandTotal.toStringAsFixed(2)}',
                                      style: AppTextStyles.headlineMd(color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
          ),

          // ─── Fixed Header ───
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: kToolbarHeight + MediaQuery.of(context).padding.top,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 16,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    border: Border(
                      bottom: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                            onPressed: () {
                              if (Navigator.canPop(context)) Navigator.pop(context);
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your Cart',
                            style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                          ),
                        ],
                      ),
                      if (_cartItems.isNotEmpty)
                        GestureDetector(
                          onTap: () async {
                            // Implement clear cart if needed. For now just clear local.
                            setState(() => _cartItems.clear());
                          },
                          child: Text(
                            'CLEAR ALL',
                            style: AppTextStyles.labelMono(color: AppColors.primary)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Fixed Footer Checkout ───
          if (_cartItems.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.only(top: 16, left: 20, right: 20, bottom: 32),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.9),
                      border: Border(
                        top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GRAND TOTAL',
                                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)
                                      .copyWith(letterSpacing: 2),
                                ),
                                Text(
                                  '\$${grandTotal.toStringAsFixed(2)}',
                                  style: AppTextStyles.headlineLgMobile(color: AppColors.onSurface),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.timer, color: AppColors.primary, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '35-45 min',
                                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF4A90), Color(0xFFBA005E)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                                );
                              },
                              borderRadius: BorderRadius.circular(28),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Proceed to Checkout',
                                    style: AppTextStyles.headlineMd(color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, color: Colors.white),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        Text(
          value,
          style: AppTextStyles.labelMono(color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    String addonsText = '';
    if (item.addons.isNotEmpty) {
      addonsText = item.addons.map((a) => a.name).join(', ');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: AppColors.surfaceContainer),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: AppTextStyles.bodyLg(color: AppColors.onSurface)
                            .copyWith(fontWeight: FontWeight.bold, height: 1.2),
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMd(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 14, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'by ${item.kitchenName}',
                        style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (addonsText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    addonsText,
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity Selector
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 16),
                            onPressed: () => _updateQuantity(item.cartItemId, item.quantity - 1),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            color: AppColors.onSurface,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${item.quantity}',
                              style: AppTextStyles.labelMono(color: AppColors.onSurface)
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 16),
                            onPressed: () => _updateQuantity(item.cartItemId, item.quantity + 1),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                            color: AppColors.onSurface,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () => _removeFromCart(item.cartItemId),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
