import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'auth_provider.dart';

final supabaseClient = Supabase.instance.client;

class KitchenNotifier extends AsyncNotifier<List<Kitchen>> {
  @override
  Future<List<Kitchen>> build() async {
    return _fetchKitchens();
  }

  Future<List<Kitchen>> _fetchKitchens() async {
    final response = await supabaseClient.from('kitchens').select();
    return (response as List).map((json) => Kitchen.fromJson(json)).toList();
  }

  Future<void> toggleKitchenStatus(String kitchenId, bool isOpen) async {
    await supabaseClient.from('kitchens').update({'is_open': isOpen}).eq('id', kitchenId);
    state = AsyncData(await _fetchKitchens());
  }
}

final kitchenProvider = AsyncNotifierProvider<KitchenNotifier, List<Kitchen>>(() {
  return KitchenNotifier();
});

// A specific provider to get the currently logged-in chef's kitchen
final myKitchenProvider = FutureProvider<Kitchen?>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null || user.role != 'chef') return null;

  try {
    final response = await supabaseClient.from('kitchens').select().eq('chef_id', user.id).maybeSingle();
    if (response == null) return null;
    return Kitchen.fromJson(response);
  } catch (e) {
    print('Error fetching my kitchen: $e');
    return null;
  }
});
