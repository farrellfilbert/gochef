import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'cart_provider.dart';
import 'auth_provider.dart';
import 'kitchen_provider.dart';

final supabaseClient = Supabase.instance.client;

class OrderNotifier extends AsyncNotifier<List<OrderModel>> {
  @override
  Future<List<OrderModel>> build() async {
    final user = ref.watch(authProvider).value;
    if (user == null) return [];

    if (user.role == 'chef') {
      final myKitchen = await ref.watch(myKitchenProvider.future);
      if (myKitchen == null) return [];
      
      // Fetch orders for this kitchen
      final response = await supabaseClient
          .from('orders')
          .select('*, order_items(*, menu_items(*))')
          .eq('kitchen_id', myKitchen.id)
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => OrderModel.fromJson(json)).toList();
    } else {
      // Fetch orders for this foodie
      final response = await supabaseClient
          .from('orders')
          .select('*, order_items(*, menu_items(*))')
          .eq('foodie_id', user.id)
          .order('created_at', ascending: false);
      
      return (response as List).map((json) => OrderModel.fromJson(json)).toList();
    }
  }

  Future<void> placeOrder(String kitchenId, String deliveryAddress, List<CartItem> cartItems, double total) async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      // 1. Create order
      final orderResponse = await supabaseClient.from('orders').insert({
        'foodie_id': user.id,
        'kitchen_id': kitchenId,
        'status': 'pending',
        'total_amount': total,
        'delivery_address': deliveryAddress,
      }).select().single();

      final orderId = orderResponse['id'];

      // 2. Create order items
      final itemsToInsert = cartItems.map((item) => {
        'order_id': orderId,
        'menu_item_id': item.menuItem.id,
        'quantity': item.quantity,
        'price_at_time': item.menuItem.price,
      }).toList();

      await supabaseClient.from('order_items').insert(itemsToInsert);

      // Refresh state
      state = const AsyncLoading();
      state = AsyncData(await build());
      
      // Clear cart
      ref.read(cartProvider.notifier).clearCart();
    } catch (e) {
      print('Error placing order: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await supabaseClient.from('orders').update({
      'status': newStatus,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', orderId);

    // Refresh state
    state = const AsyncLoading();
    state = AsyncData(await build());
  }
}

final orderProvider = AsyncNotifierProvider<OrderNotifier, List<OrderModel>>(() {
  return OrderNotifier();
});

// Real-time stream for Chef Dashboard
final activeOrdersStreamProvider = StreamProvider.autoDispose<List<OrderModel>>((ref) async* {
  final user = ref.watch(authProvider).value;
  if (user == null || user.role != 'chef') {
    yield [];
    return;
  }

  final myKitchen = await ref.watch(myKitchenProvider.future);
  if (myKitchen == null) {
    yield [];
    return;
  }

  final stream = supabaseClient
      .from('orders')
      .stream(primaryKey: ['id'])
      .eq('kitchen_id', myKitchen.id)
      .order('created_at', ascending: false);

  await for (final data in stream) {
    // We need to fetch the joined data for each update since stream only returns the base table
    final response = await supabaseClient
          .from('orders')
          .select('*, order_items(*, menu_items(*))')
          .eq('kitchen_id', myKitchen.id)
          .order('created_at', ascending: false);
          
    yield (response as List).map((json) => OrderModel.fromJson(json)).toList();
  }
});
