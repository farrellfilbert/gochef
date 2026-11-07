import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../legal/terms_of_service_screen.dart';
import '../legal/privacy_policy_screen.dart';
import '../legal/disclaimer_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic>? _selectedVoucher;
  final List<Map<String, dynamic>> _availableVouchers = [
    {
      'code': 'FIRST50',
      'discount': '50% OFF',
      'title': '50% Off Your First Order',
      'subtitle': 'Exclusive University student voucher',
      'discountType': 'percent',
      'discountValue': 50.0,
      'minSpend': 0.0,
    },
    {
      'code': 'FREEDEL',
      'discount': 'FREE DELIVERY',
      'title': 'Free Delivery This Week',
      'subtitle': 'On all orders above \$20',
      'discountType': 'free_delivery',
      'discountValue': 4.0,
      'minSpend': 20.0,
    },
    {
      'code': 'FREEDELIV',
      'discount': 'FREE DELIVERY',
      'title': 'Free Delivery This Week',
      'subtitle': 'On all orders above \$20',
      'discountType': 'free_delivery',
      'discountValue': 4.0,
      'minSpend': 20.0,
    },
    {
      'code': 'B2G1RAMEN',
      'discount': 'BUY 2 GET 1',
      'title': 'Buy 2 Get 1 Free Promo',
      'subtitle': 'Special discount voucher',
      'discountType': 'fixed',
      'discountValue': 12.0,
      'minSpend': 15.0,
    },
    {
      'code': 'GOCHEF40',
      'discount': '40% OFF',
      'title': 'Gourmet Feast Special',
      'subtitle': '40% discount on entire order',
      'discountType': 'percent',
      'discountValue': 40.0,
      'minSpend': 20.0,
    },
    {
      'code': 'PLUSVIP15',
      'discount': '15% OFF',
      'title': 'GoChef PLUS VIP Member',
      'subtitle': 'VIP 15% discount',
      'discountType': 'percent',
      'discountValue': 15.0,
      'minSpend': 0.0,
    },
  ];
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

  void _applyVoucherMap(Map<String, dynamic> v) {
    final code = (v['code'] ?? '').toString().toUpperCase();
    final minSpend = double.tryParse(v['minSpend']?.toString() ?? '0') ?? 0.0;
    
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
          content: Text('⚠️ "${v['title']}" requires a minimum order of \$${minSpend.toStringAsFixed(2)}. (Current subtotal: \$${currentSubtotal.toStringAsFixed(2)})'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final isFree = v['discountType'] == 'free_delivery';
    final discountVal = double.tryParse(v['discountValue']?.toString() ?? '0') ?? 0.0;
    
    setState(() {
      _selectedVoucher = v;
      _appliedPromoCode = code;
      _promoController.text = code;
      if (isFree) {
        _isFreeDelivery = true;
        _discountPercent = 0.0;
        _appliedPromoTitle = v['title'] ?? '$code (Free Delivery)';
      } else if (v['discountType'] == 'percent') {
        _isFreeDelivery = false;
        _discountPercent = discountVal;
        _appliedPromoTitle = v['title'] ?? '$code (${discountVal.toInt()}% OFF)';
      } else {
        _isFreeDelivery = false;
        _discountPercent = 0.0;
        _appliedPromoTitle = v['title'] ?? '$code (Special Promo)';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎉 Promo "${v['title']}" applied! ${isFree ? "Free Delivery activated!" : ""}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _applyCodeDirectly(String code) {
    code = code.trim().toUpperCase();
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

    final matched = _availableVouchers.firstWhere(
      (v) => (v['code']?.toString().toUpperCase() == code),
      orElse: () => {
        'code': code,
        'discount': isFree ? 'FREE DELIVERY' : (is50 ? '50% OFF' : '20% OFF'),
        'title': isFree ? 'Free Delivery This Week' : '$code Promo Code',
        'subtitle': isFree ? 'On all orders above \$20' : 'Applied from code',
        'discountType': isFree ? 'free_delivery' : 'percent',
        'discountValue': isFree ? 4.0 : (is50 ? 50.0 : 20.0),
        'minSpend': minSpend,
      },
    );

    _applyVoucherMap(matched);
  }

  void _showVoucherSelectionModal() {
    final promoInputController = TextEditingController(text: _appliedPromoCode ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Apply Voucher / Promo', style: AppTextStyles.headlineMd(color: Colors.white)),
                      if (_selectedVoucher != null || _appliedPromoCode != null)
                        TextButton(
                          onPressed: () {
                            _removePromoCode();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Remove', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Promo Code Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: promoInputController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            hintText: 'Enter Promo Code (e.g. FIRST50)',
                            hintStyle: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 13),
                            filled: true,
                            fillColor: AppColors.surfaceContainerLow,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final code = promoInputController.text.trim().toUpperCase();
                          if (code.isEmpty) return;
                          Navigator.pop(ctx);
                          _applyCodeDirectly(code);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Your Available Vouchers', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _availableVouchers.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, idx) {
                        final v = _availableVouchers[idx];
                        final isApplied = (_selectedVoucher != null && _selectedVoucher!['code'] == v['code']) ||
                            (_appliedPromoCode != null && _appliedPromoCode == v['code']);
                        return Material(
                          color: isApplied ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.pop(ctx);
                              _applyVoucherMap(v);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isApplied ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.1),
                                  width: isApplied ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isApplied ? AppColors.primary.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.confirmation_number, color: isApplied ? AppColors.primary : Colors.orange, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(v['discount'] ?? 'PROMO', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                            const SizedBox(width: 6),
                                            Text('• ${v['code']}', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 11)),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(v['title'] ?? '', style: AppTextStyles.bodyMd(color: Colors.white).copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                                        if (v['subtitle'] != null)
                                          Text(v['subtitle'], style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  if (isApplied)
                                    const Icon(Icons.check_circle, color: AppColors.primary, size: 22)
                                  else
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                        _applyVoucherMap(v);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        visualDensity: VisualDensity.compact,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Apply', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _removePromoCode() {
    setState(() {
      _selectedVoucher = null;
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
      
      // Load claimed vouchers from storage
      try {
        final userId = await ApiService.getUserId();
        if (userId != null && userId.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          final savedVouchersJson = prefs.getString('user_claimed_vouchers_$userId');
          if (savedVouchersJson != null) {
            final List decoded = jsonDecode(savedVouchersJson);
            final customVouchers = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
            for (var v in customVouchers) {
              if (!_availableVouchers.any((existing) => existing['code'] == v['code'])) {
                _availableVouchers.insert(0, v);
              }
            }
          }
        }
      } catch (_) {}
      
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
    double discountAmount = 0.0;
    if (_selectedVoucher != null) {
      if (_selectedVoucher!['discountType'] == 'free_delivery') {
        deliveryFee = 0.0;
      } else if (_selectedVoucher!['discountType'] == 'percent') {
        final p = double.tryParse(_selectedVoucher!['discountValue']?.toString() ?? '0') ?? 0.0;
        discountAmount = subtotal * (p / 100.0);
      } else if (_selectedVoucher!['discountType'] == 'fixed') {
        discountAmount = double.tryParse(_selectedVoucher!['discountValue']?.toString() ?? '0') ?? 0.0;
      }
    } else if (_discountPercent > 0) {
      discountAmount = subtotal * (_discountPercent / 100.0);
    }
    if (discountAmount > subtotal) {
      discountAmount = subtotal;
    }
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
                                        child: InkWell(
                                          onTap: _showVoucherSelectionModal,
                                          child: Text(
                                            _promoController.text.isNotEmpty 
                                                ? _promoController.text 
                                                : 'Apply Voucher / Promo Code',
                                            style: AppTextStyles.bodyMd(
                                              color: _promoController.text.isNotEmpty 
                                                  ? AppColors.onSurface 
                                                  : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: _showVoucherSelectionModal,
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
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'By purchasing you agree to GoChef’s: ',
                                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 11),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsOfServiceScreen())),
                                  child: const Text(
                                    'Terms and Conditions',
                                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11, decoration: TextDecoration.underline),
                                  ),
                                ),
                                Text(
                                  ', ',
                                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 11),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                                  child: const Text(
                                    'Privacy Policy',
                                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11, decoration: TextDecoration.underline),
                                  ),
                                ),
                                Text(
                                  ' and ',
                                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontSize: 11),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DisclaimerScreen())),
                                  child: const Text(
                                    'Disclaimer',
                                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11, decoration: TextDecoration.underline),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                                final hasUnavailable = selectedItems.any((i) => !i.isAvailable);
                                if (hasUnavailable) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please remove out of stock items from your cart before proceeding.'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }
                                final typedPromo = _promoController.text.trim().toUpperCase();
                                final promoToPass = _appliedPromoCode ?? (_selectedVoucher != null ? _selectedVoucher!['code'] as String? : (typedPromo.isNotEmpty ? typedPromo : null));
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
                if (!item.isAvailable) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'OUT OF STOCK - Please remove',
                          style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
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
