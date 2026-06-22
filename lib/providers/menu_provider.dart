import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class MenuNotifier extends AsyncNotifier<List<MenuItem>> {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<MenuItem>> build() async {
    try {
      final response = await _supabase.from('menu_items').select().order('name', ascending: true);
      return response.map((json) => MenuItem.fromJson(json)).toList();
    } catch (e) {
      // In case table is missing or network error, return empty list gracefully
      return [];
    }
  }

  Future<void> addMenuItem(MenuItem item) async {
    try {
      await _supabase.from('menu_items').insert({
        'id': item.id,
        'kitchen_id': item.kitchenId,
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'category': item.category,
        'cuisine': item.cuisine,
        'image_url': item.imageUrl,
        'is_available': item.isAvailable,
      });

      final currentState = state.value ?? [];
      state = AsyncData([...currentState, item]);
    } catch (e) {
      print('Error saving to Supabase: $e');
      rethrow;
    }
  }

  Future<void> toggleAvailability(String id) async {
    final currentState = state.value ?? [];
    final item = currentState.firstWhere((i) => i.id == id);
    final newStatus = !item.isAvailable;

    try {
      await _supabase.from('menu_items').update({
        'is_available': newStatus,
      }).eq('id', id);

      state = const AsyncLoading();
      state = AsyncData(await build());
    } catch (e) {
      print('Error updating Supabase: $e');
    }
  }
}

final menuProvider = AsyncNotifierProvider<MenuNotifier, List<MenuItem>>(() {
  return MenuNotifier();
});
