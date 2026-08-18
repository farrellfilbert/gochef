import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../screens/cart/cart_screen.dart';
import 'dart:async';

class CartIconButton extends StatefulWidget {
  final Color iconColor;

  const CartIconButton({super.key, this.iconColor = Colors.white});

  @override
  State<CartIconButton> createState() => _CartIconButtonState();
}

class _CartIconButtonState extends State<CartIconButton> {
  int _cartCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchCartCount();
    // Poll every 3 seconds to keep cart badge synchronized across all pages
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _fetchCartCount();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchCartCount() async {
    if (!mounted) return;
    try {
      final cartItems = await ApiService.getCart();
      if (mounted) {
        setState(() {
          _cartCount = cartItems.length;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined, color: widget.iconColor),
          tooltip: 'Shopping Cart',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            ).then((_) => _fetchCartCount());
          },
        ),
        if (_cartCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$_cartCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
