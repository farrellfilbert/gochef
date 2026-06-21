import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

class CartItem {
  final MenuItem menuItem;
  final int quantity;

  CartItem({required this.menuItem, required this.quantity});

  CartItem copyWith({MenuItem? menuItem, int? quantity}) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice {
    return menuItem.price * quantity;
  }
}

class CartNotifier extends Notifier<Map<String, CartItem>> {
  @override
  Map<String, CartItem> build() {
    return {};
  }

  void addItem(MenuItem item) {
    if (state.containsKey(item.id)) {
      state = {
        ...state,
        item.id: state[item.id]!.copyWith(quantity: state[item.id]!.quantity + 1),
      };
    } else {
      state = {
        ...state,
        item.id: CartItem(menuItem: item, quantity: 1),
      };
    }
  }

  void removeItem(String itemId) {
    if (!state.containsKey(itemId)) return;

    final currentQuantity = state[itemId]!.quantity;
    if (currentQuantity > 1) {
      state = {
        ...state,
        itemId: state[itemId]!.copyWith(quantity: currentQuantity - 1),
      };
    } else {
      final newState = Map<String, CartItem>.from(state);
      newState.remove(itemId);
      state = newState;
    }
  }

  void clearCart() {
    state = {};
  }

  double get totalCartPrice {
    double total = 0;
    for (final item in state.values) {
      total += item.totalPrice;
    }
    return total;
  }

  int get totalItems {
    int total = 0;
    for (final item in state.values) {
      total += item.quantity;
    }
    return total;
  }
}

final cartProvider = NotifierProvider<CartNotifier, Map<String, CartItem>>(() {
  return CartNotifier();
});
