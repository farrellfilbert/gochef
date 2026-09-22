import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'order_complete_screen.dart';
import 'payment_webview_screen.dart';
import '../../services/api_service.dart';
import '../../models/address_model.dart';
import '../../models/cart_item_model.dart';
import '../profile/address_selection_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import '../../utils/web_js.dart';

class CheckoutScreen extends StatefulWidget {
  final int kitchenId;
  const CheckoutScreen({super.key, required this.kitchenId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isAsap = true;
  String selectedPayment = 'stripe'; // 'stripe', 'apple', 'google'
  bool isOrdering = false;
  
  // Dine-in fields
  bool isDineIn = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  
  bool _isLoading = true;
  AddressModel? _primaryAddress;
  List<CartItemModel> _cartItems = [];

  // Price components
  double _subtotal = 0.0;
  double _baseDeliveryFee = 4.00;
  double _serviceFee = 2.50;
  double _discountAmount = 0.0;
  double _grandTotal = 0.0;

  // Selected Voucher
  Map<String, dynamic>? _selectedVoucher;

  // Available vouchers
  List<Map<String, dynamic>> _availableVouchers = [
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
      'code': 'FREEDELIV',
      'discount': 'FREE DELIVERY',
      'title': 'Free Delivery This Week',
      'subtitle': 'Zero delivery fee',
      'discountType': 'free_delivery',
      'discountValue': 4.0,
      'minSpend': 0.0,
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

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    setState(() => _isLoading = true);
    try {
      final allItems = await ApiService.getCart();
      _cartItems = allItems.where((i) => i.kitchenId == widget.kitchenId).toList();
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

      double sub = 0;
      for (var item in _cartItems) {
        sub += item.totalPrice;
      }
      _subtotal = sub;
      _baseDeliveryFee = _cartItems.isNotEmpty ? 4.00 : 0.00;
      _serviceFee = _cartItems.isNotEmpty ? 2.50 : 0.00;

      if (addresses.isNotEmpty) {
        _primaryAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
      }

      _recalculateTotal();
    } catch (e) {
      debugPrint('Error loading checkout: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
      if (!isDineIn && _primaryAddress != null) {
        _fetchDeliveryQuote();
      }
    }
  }

  Future<void> _fetchDeliveryQuote() async {
    if (isDineIn || _primaryAddress == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final quote = await ApiService.getDeliveryQuote(
        kitchenId: widget.kitchenId,
        dropoffAddress: _primaryAddress!.address,
        dropoffLat: 0.0, // Replace with actual lat/lng if needed
        dropoffLng: 0.0,
      );
      
      if (quote != null && quote['success'] == true && quote['quote'] != null) {
        double newFee = _baseDeliveryFee;
        final q = quote['quote'];
        if (q['fee'] != null) {
           newFee = double.tryParse(q['fee'].toString()) ?? _baseDeliveryFee;
        } else if (q['quotes'] != null && (q['quotes'] as List).isNotEmpty) {
           newFee = double.tryParse(q['quotes'][0]['fee']?.toString() ?? '') ?? _baseDeliveryFee;
        }
        
        setState(() {
           _baseDeliveryFee = newFee;
        });
        _recalculateTotal();
      }
    } catch (e) {
      debugPrint('Error fetching Uber quote: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _recalculateTotal() {
    double delivery = isDineIn ? 0.0 : _baseDeliveryFee;
    double discount = 0.0;

    if (_selectedVoucher != null) {
      final type = _selectedVoucher!['discountType'] ?? 'percent';
      final val = double.tryParse(_selectedVoucher!['discountValue']?.toString() ?? '') ?? 0.0;

      if (type == 'percent') {
        discount = _subtotal * (val / 100.0);
      } else if (type == 'free_delivery') {
        discount = delivery;
        delivery = 0.0;
      } else if (type == 'fixed') {
        discount = val.clamp(0.0, _subtotal);
      }
    }

    _discountAmount = discount;
    final total = (_subtotal + delivery + _serviceFee - _discountAmount);
    _grandTotal = total.clamp(0.0, 999999.0);
  }

  bool typeIsFreeDelivery() {
    return _selectedVoucher != null && _selectedVoucher!['discountType'] == 'free_delivery';
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  // ==========================================
  // VOUCHER SELECTION MODAL
  // ==========================================
  void _showVoucherSelectionModal() {
    final promoController = TextEditingController();

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
                      if (_selectedVoucher != null)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedVoucher = null;
                              _recalculateTotal();
                            });
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
                          controller: promoController,
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
                          final code = promoController.text.trim().toUpperCase();
                          if (code.isEmpty) return;
                          
                          final is50 = (code == 'FIRST50' || code == 'GOCHEF50');
                          final custom = {
                            'code': code,
                            'discount': is50 ? '50% OFF' : '20% OFF',
                            'title': '$code Promo Code',
                            'subtitle': 'Applied from code',
                            'discountType': 'percent',
                            'discountValue': is50 ? 50.0 : 20.0,
                          };

                          setState(() {
                            _selectedVoucher = custom;
                            _recalculateTotal();
                          });
                          Navigator.pop(ctx);

                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text('Voucher "$code" applied! Saved \$${_discountAmount.toStringAsFixed(2)}'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
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
                        final isApplied = _selectedVoucher != null && _selectedVoucher!['code'] == v['code'];
                        return Material(
                          color: isApplied ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              setState(() {
                                _selectedVoucher = v;
                                _recalculateTotal();
                              });
                              Navigator.pop(ctx);

                              ScaffoldMessenger.of(this.context).showSnackBar(
                                SnackBar(
                                  content: Text('🎉 Applied "${v['title']}"! You saved \$${_discountAmount.toStringAsFixed(2)}'),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
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
                                      ],
                                    ),
                                  ),
                                  Text(
                                    isApplied ? 'Applied ✓' : 'Use',
                                    style: TextStyle(
                                      color: isApplied ? Colors.greenAccent : AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
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

  // ==========================================
  // PLACE ORDER
  // ==========================================
  Future<void> _showErrorDialog(String title, String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!isDineIn && _primaryAddress == null) {
      await _showErrorDialog('Address Required', 'Please add or select a delivery address first.');
      return;
    }
    
    if (isDineIn && (selectedDate == null || selectedTime == null)) {
      await _showErrorDialog('Date & Time Required', 'Please select a Date and Time for Dine-in.');
      return;
    }

    if (!isDineIn && !isAsap && (selectedDate == null || selectedTime == null)) {
      await _showErrorDialog('Date & Time Required', 'Please select a Date and Time for your scheduled delivery.');
      return;
    }

    setState(() {
      isOrdering = true;
    });

    String orderNotes = isDineIn 
        ? 'Dine-in Booking' 
        : (isAsap ? 'ASAP Delivery' : 'Scheduled Delivery');
        
    if (_selectedVoucher != null) {
      orderNotes += ' | Voucher: ${_selectedVoucher!['code']} (${_selectedVoucher!['discount']})';
    }

    final result = await ApiService.createStripeCheckout(
      addressId: isDineIn ? null : _primaryAddress!.id,
      kitchenId: widget.kitchenId,
      notes: orderNotes,
      orderType: isDineIn ? 'dine_in' : 'delivery',
      dineInDate: selectedDate != null ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}" : null,
      dineInTime: selectedTime != null ? "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}" : null,
      promoCode: _selectedVoucher != null ? _selectedVoucher!['code'] : null,
      deliveryFee: _baseDeliveryFee,
      serviceFee: _serviceFee,
    );

    if (mounted) {
      final payUrl = result?['checkout_url'] ?? result?['pay_url'];
      if (result != null && result['success'] == true && payUrl != null) {
        final url = Uri.parse(payUrl);
        setState(() {
          isOrdering = false;
        });
        
        if (mounted) {
          if (kIsWeb) {
            WebJs.openUrl(payUrl, target: '_self');
          } else {
            final resultSuccess = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentWebViewScreen(
                  initialUrl: payUrl,
                  successUrlPattern: 'success',
                  cancelUrlPattern: 'cancel',
                ),
              ),
            );

            if (mounted) {
              final orderId = result?['order_id']?.toString() ?? result?['orderId']?.toString() ?? '1';
                final kitchenIdStr = result?['kitchen_id']?.toString() ?? widget.kitchenId.toString();
                final kitchenNameStr = result?['kitchen_name']?.toString() ?? 'GoChef Kitchen';
                final kitchenAvatarStr = result?['kitchen_avatar']?.toString() ?? '';

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderCompleteScreen(
                      orderId: orderId,
                      kitchenId: kitchenIdStr,
                      kitchenName: kitchenNameStr,
                      totalAmount: _grandTotal,
                      itemsCount: _cartItems.length,
                      kitchenAvatar: kitchenAvatarStr,
                    ),
                  ),
                );
              }
            }
          }
        }
      } else {
        setState(() {
          isOrdering = false;
        });
        final errorMsg = (result != null && result['error'] != null) ? result['error'].toString() : 'Failed to initialize payment from server.';
        _showErrorDialog('Payment Failed', errorMsg);
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
        title: Text('Checkout', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
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
                // Order Type Toggle
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isDineIn = false;
                              _recalculateTotal();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: !isDineIn ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Delivery',
                              style: TextStyle(
                                color: !isDineIn ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isDineIn = true;
                              _recalculateTotal();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isDineIn ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Dine-In Booking',
                              style: TextStyle(
                                color: isDineIn ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                if (!isDineIn) ...[
                  // Delivery Address

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Delivery Address', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
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
                          _fetchDeliveryQuote();
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
                      _fetchDeliveryQuote();
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
                
                const SizedBox(height: 24),
                // Delivery Time
                Text('Delivery Time', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isAsap = true),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isAsap ? AppColors.primaryContainer.withValues(alpha: 0.1) : AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isAsap ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
                              width: isAsap ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.bolt, color: isAsap ? AppColors.primary : AppColors.onSurfaceVariant, size: 20),
                                  const SizedBox(width: 8),
                                  Text('ASAP', style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('25-35 mins', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => isAsap = false);
                          // Open time picker immediately if none selected
                          if (selectedTime == null) {
                            _pickDate().then((_) {
                              if (selectedDate != null) _pickTime();
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: !isAsap ? AppColors.primaryContainer.withValues(alpha: 0.1) : AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: !isAsap ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
                              width: !isAsap ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.schedule, color: !isAsap ? AppColors.primary : AppColors.onSurfaceVariant, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Schedule', style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (!isAsap && selectedDate != null && selectedTime != null) 
                                ? "${selectedDate!.day}/${selectedDate!.month} ${selectedTime!.format(context)}" 
                                : 'Select time', 
                                style: AppTextStyles.labelSm(color: (!isAsap && selectedDate != null) ? AppColors.primary : AppColors.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ] else ...[
                  // Dine-in Schedule
                  Text('Dine-In Schedule', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                                const SizedBox(height: 8),
                                Text(selectedDate != null ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}" : 'Select Date', 
                                    style: AppTextStyles.bodyMd(color: selectedDate != null ? AppColors.onSurface : AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.access_time, color: AppColors.primary, size: 20),
                                const SizedBox(height: 8),
                                Text(selectedTime != null ? selectedTime!.format(context) : 'Select Time', 
                                    style: AppTextStyles.bodyMd(color: selectedTime != null ? AppColors.onSurface : AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                const SizedBox(height: 24),
                Text('Payment Method', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() => selectedPayment = 'stripe'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selectedPayment == 'stripe' ? AppColors.primaryContainer.withValues(alpha: 0.1) : AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedPayment == 'stripe' ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.credit_card, color: AppColors.onSurface),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Credit/Debit Card', style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                              Text('Powered by Stripe', style: AppTextStyles.labelSm(color: AppColors.primary)),
                            ],
                          ),
                        ),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedPayment == 'stripe' ? AppColors.primary : AppColors.outline,
                              width: 2,
                            ),
                          ),
                          child: selectedPayment == 'stripe'
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
                
                // Alt payment methods
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
                // VOUCHER & DISCOUNT SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Voucher & Discounts', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    if (_selectedVoucher != null)
                      GestureDetector(
                        onTap: _showVoucherSelectionModal,
                        child: Text('Change', style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Material(
                  color: _selectedVoucher != null
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceContainerLow.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _showVoucherSelectionModal,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedVoucher != null ? AppColors.primary : Colors.white.withValues(alpha: 0.05),
                          width: _selectedVoucher != null ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _selectedVoucher != null ? AppColors.primary.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.local_offer, color: _selectedVoucher != null ? AppColors.primary : Colors.orange, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _selectedVoucher != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              _selectedVoucher!['discount'] ?? 'PROMO',
                                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _selectedVoucher!['code'] ?? '',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedVoucher!['title'] ?? 'Voucher Applied',
                                        style: AppTextStyles.labelSm(color: Colors.greenAccent).copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Apply Voucher / Promo Code', style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text('Select claimed voucher or enter code', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: AppColors.onSurfaceVariant, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                // Order Summary Breakdown
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
                          Text('Subtotal', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                          Text('\$${_subtotal.toStringAsFixed(2)}', style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (!isDineIn) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Delivery Fee', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                            Text(
                              typeIsFreeDelivery() ? 'FREE' : '\$${_baseDeliveryFee.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyMd(color: typeIsFreeDelivery() ? Colors.greenAccent : AppColors.onSurface).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Service Fee', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                          Text('\$${_serviceFee.toStringAsFixed(2)}', style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (_discountAmount > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Voucher Discount (${_selectedVoucher!['discount']})',
                              style: AppTextStyles.bodyMd(color: Colors.greenAccent),
                            ),
                            Text(
                              '-\$${_discountAmount.toStringAsFixed(2)}',
                              style: AppTextStyles.bodyMd(color: Colors.greenAccent).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Divider(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                          Text('\$${_grandTotal.toStringAsFixed(2)}', style: AppTextStyles.headlineLgMobile(color: Colors.white)),
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
