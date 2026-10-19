import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../checkout/checkout_screen.dart';
import '../../services/api_service.dart';
import '../../models/cart_item_model.dart';
import '../../models/address_model.dart';
import '../../models/menu_item_model.dart';
import '../profile/address_selection_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;
  List<CartItemModel> _cartItems = [];
  List<MenuItemModel> _recommendedItems = [];
  AddressModel? _primaryAddress;
  int? _selectedKitchenId;

  final TextEditingController _promoController = TextEditingController();
  String? _appliedPromoCode;
  String? _appliedPromoTitle;
  double _discountPercent = 0.0;
  bool _isFreeDelivery = false;

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromoCode() {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final isFree = (code == 'FREEDEL' || code == 'FREEDELIV' || code == 'FREESHIP');
    final is50 = (code == 'FIRST50' || code == 'GOCHEF50');
    final minSpend = isFree ? 20.0 : (code == 'GOCHEF40' ? 20.0 : 0.0);

    final selectedItems = _cartItems.where((i) => i.kitchenId == _selectedKitchenId).toList();
    double currentSubtotal = 0;
    for (var item in selectedItems) {
      currentSubtotal += item.totalPrice;
    }
    if (currentSubtotal <= 0) {
      for (var item in _cartItems) {
        currentSubtotal += item.totalPrice;
      }
    }

    if (currentSubtotal < minSpend) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('⚠️ Promo code "$code" requires a minimum order of \$${minSpend.toStringAsFixed(2)}. (Current subtotal: \$${currentSubtotal.toStringAsFixed(2)})'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() {
      _appliedPromoCode = code;
      if (isFree) {
        _isFreeDelivery = true;
        _discountPercent = 0.0;
        _appliedPromoTitle = '$code (Free Delivery)';
      } else {
        _isFreeDelivery = false;
        _discountPercent = is50 ? 50.0 : 20.0;
        _appliedPromoTitle = '$code (${_discountPercent.toInt()}% OFF)';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Promo Code "$code" applied! ${isFree ? "Free Delivery activated!" : ""}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removePromoCode() {
    setState(() {
      _appliedPromoCode = null;
      _appliedPromoTitle = null;
      _discountPercent = 0.0;
      _isFreeDelivery = false;
      _promoController.clear();
    });
  }

  Future<void> _clearAllCart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _cartItems.clear();
        _removePromoCode();
      });
      await ApiService.clearCart();
      if (mounted) {
        _loadCartData();
      }
    }
  }

  Future<void> _loadCartData() async {
    setState(() => _isLoading = true);
    try {
      final items = await ApiService.getCart();
      final addresses = await ApiService.getAddresses();
      
      setState(() {
        _cartItems = items;
        if (_cartItems.isNotEmpty) {
          _selectedKitchenId = _cartItems.first.kitchenId;
        }
        if (addresses.isNotEmpty) {
          try {
            _primaryAddress = addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            );
          } catch (_) {}
        }
      });
      
      if (_cartItems.isEmpty) {
        final popularItems = await ApiService.getMenuItems(popular: true);
        if (mounted) {
          setState(() {
            _recommendedItems = popularItems.take(5).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQuantity(int cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      await _removeFromCart(cartItemId);
    } else {
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
      // Sync quantity update to backend
      ApiService.updateCartQuantity(cartItemId, newQuantity);
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
    // Group items by kitchen
    Map<int, List<CartItemModel>> groupedItems = {};
    for (var item in _cartItems) {
      groupedItems.putIfAbsent(item.kitchenId, () => []).add(item);
    }
    
    // Fallback if selected kitchen is no longer in cart
    if (_selectedKitchenId != null && !groupedItems.containsKey(_selectedKitchenId)) {
      _selectedKitchenId = groupedItems.keys.isNotEmpty ? groupedItems.keys.first : null;
    }

    final selectedItems = _cartItems.where((i) => i.kitchenId == _selectedKitchenId).toList();

    // Calculate totals for selected kitchen only
    double subtotal = 0;
    for (var item in selectedItems) {
      subtotal += item.totalPrice;
    }
    double deliveryFee = selectedItems.isNotEmpty ? (_isFreeDelivery ? 0.0 : 4.00) : 0.00;
    double serviceFee = selectedItems.isNotEmpty ? 2.50 : 0.00;
    double discountAmount = _discountPercent > 0 ? (subtotal * (_discountPercent / 100.0)) : 0.0;
    double grandTotal = (subtotal - discountAmount + deliveryFee + serviceFee).clamp(0.0, 999999.0);

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
                      bottom: 220, // Space for fixed footer
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Delivery Address ───
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
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                                      ),
                                      child: const Icon(Icons.location_on, color: Colors.white),
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  'Change',
                                  style: AppTextStyles.labelMono(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Column(
                                    children: [
                                      const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.onSurfaceVariant),
                                      const SizedBox(height: 16),
                                      Text('Your cart is empty', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                              ),
                              if (_recommendedItems.isNotEmpty) ...[
                                Text('Recommended for You', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 220,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _recommendedItems.length,
                                    itemBuilder: (context, index) {
                                      final item = _recommendedItems[index];
                                      return _buildRecommendedCard(item);
                                    },
                                  ),
                                ),
                              ],
                            ],
                          )
                        else
                          ...groupedItems.entries.map((entry) {
                            final kId = entry.key;
                            final kItems = entry.value;
                            final isSelected = _selectedKitchenId == kId;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.glassBorder),
                                  borderRadius: BorderRadius.circular(12),
                                  color: AppColors.glassBackground,
                                ),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Radio<int>(
                                        value: kId,
                                        groupValue: _selectedKitchenId,
                                        activeColor: AppColors.primary,
                                        onChanged: (val) {
                                          setState(() => _selectedKitchenId = val);
                                        },
                                      ),
                                      title: Text(
                                        kItems.first.kitchenName, 
                                        style: AppTextStyles.headlineMd(color: AppColors.onSurface)
                                      ),
                                    ),
                                    const Divider(color: AppColors.ghostBorder),
                                    ...kItems.map((item) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                                        child: _buildCartItem(item),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            );
                          }),
                        
                        const SizedBox(height: 12),

                        // ─── Promo Code ───
                        if (_cartItems.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.glassBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _appliedPromoCode != null 
                                    ? Colors.green.withValues(alpha: 0.6) 
                                    : AppColors.glassBorder,
                              ),
                            ),
                            child: _appliedPromoCode != null
                                ? Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'Promo: $_appliedPromoTitle',
                                          style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _removePromoCode,
                                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                                        child: const Text('Remove', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      const Icon(Icons.loyalty, color: Colors.white70, size: 20),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: _promoController,
                                          textCapitalization: TextCapitalization.characters,
                                          style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                                          decoration: InputDecoration(
                                            hintText: 'Promo code (e.g. FIRST50)',
                                            hintStyle: AppTextStyles.bodyMd(
                                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: _applyPromoCode,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
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
                                _buildSummaryRow(
                                  _isFreeDelivery ? 'Delivery Fee (Free)' : 'Delivery Fee',
                                  _isFreeDelivery ? '\$0.00' : '\$${deliveryFee.toStringAsFixed(2)}',
                                  valueColor: _isFreeDelivery ? Colors.greenAccent : null,
                                ),
                                const SizedBox(height: 12),
                                _buildSummaryRow('Service Fee', '\$${serviceFee.toStringAsFixed(2)}'),
                                if (discountAmount > 0) ...[
                                  const SizedBox(height: 12),
                                  _buildSummaryRow(
                                    'Discount ($_appliedPromoCode)',
                                    '-\$${discountAmount.toStringAsFixed(2)}',
                                    valueColor: Colors.greenAccent,
                                  ),
                                ],
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
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                          onTap: _clearAllCart,
                          child: Text(
                            'CLEAR ALL',
                            style: AppTextStyles.labelMono(color: Colors.white)
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
                              onTap: _selectedKitchenId == null ? null : () {
                                final typedPromo = _promoController.text.trim().toUpperCase();
                                final promoToPass = _appliedPromoCode ?? (typedPromo.isNotEmpty ? typedPromo : null);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutScreen(
                                      kitchenId: _selectedKitchenId!,
                                      initialPromoCode: promoToPass,
                                    ),
                                  ),
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

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        Text(
          value,
          style: AppTextStyles.labelMono(color: valueColor ?? AppColors.onSurface),
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
                      style: AppTextStyles.bodyMd(color: Colors.white)
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

  Widget _buildRecommendedCard(MenuItemModel item) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            item.image,
            height: 100,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(height: 100, color: AppColors.surfaceContainer),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.labelMono(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: AppTextStyles.labelMono(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      await ApiService.addToCart(item.id, quantity: 1, addonIds: []);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('${item.name} added to cart'),
                        backgroundColor: AppColors.primary,
                      ));
                      _loadCartData();
                    },
                    child: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
