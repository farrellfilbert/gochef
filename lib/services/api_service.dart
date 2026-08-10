import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/kitchen_model.dart';
import '../models/menu_item_model.dart';
import '../models/cart_item_model.dart';
import '../models/review_model.dart';
import '../models/notification_model.dart';
import '../models/promotion_model.dart';
import '../models/category_model.dart';
import '../models/address_model.dart';

class ApiService {
  static const String baseUrl = 'https://astroboomin.co/api';
  
  static String? _cachedUserId;

  // =============================================
  // AUTH / USER
  // =============================================

  static Future<String?> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId;
    final prefs = await SharedPreferences.getInstance();
    _cachedUserId = prefs.getString('user_id');
    return _cachedUserId;
  }

  static Future<void> saveUserId(String userId) async {
    _cachedUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  static Future<void> logout() async {
    _cachedUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  static Future<UserModel> getProfile() async {
    final userId = await getUserId();
    if (userId == null) {
      final prefs = await SharedPreferences.getInstance();
      final rawPrefs = prefs.getString('user_id');
      throw Exception('Not logged in (Cache: $_cachedUserId, Prefs: $rawPrefs)');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/profile.php?user_id=$userId'),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return UserModel.fromJson(data['data']);
      }
      throw Exception(data['error'] ?? 'Failed to get profile');
    }
    throw Exception('Server error: ${response.statusCode}');
  }

  static Future<bool> updateProfile({String? name, String? phone, XFile? avatarImage}) async {
    final userId = await getUserId();
    if (userId == null) return false;

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/update_profile.php'));
    request.fields['user_id'] = userId;
    if (name != null) request.fields['name'] = name;
    if (phone != null) request.fields['phone'] = phone;

    if (avatarImage != null) {
      final bytes = await avatarImage.readAsBytes();
      final String fileName = avatarImage.name.isNotEmpty ? avatarImage.name : 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      request.files.add(http.MultipartFile.fromBytes('avatar', bytes, filename: fileName));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw Exception('Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // =============================================
  // HOME
  // =============================================

  static Future<Map<String, dynamic>> getHomeData() async {
    final response = await http.get(Uri.parse('$baseUrl/home.php')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final d = data['data'];
        return {
          'featured_kitchens': (d['featured_kitchens'] as List).map((e) => KitchenModel.fromJson(e)).toList(),
          'popular_meals': (d['popular_meals'] as List).map((e) => MenuItemModel.fromJson(e)).toList(),
          'categories': (d['categories'] as List).map((e) => CategoryModel.fromJson(e)).toList(),
          'promotions': (d['promotions'] as List).map((e) => PromotionModel.fromJson(e)).toList(),
        };
      }
    }
    return {'featured_kitchens': [], 'popular_meals': [], 'categories': [], 'promotions': []};
  }

  // =============================================
  // KITCHENS
  // =============================================

  static Future<List<KitchenModel>> getKitchens({bool featured = false, String? search, String? cuisine}) async {
    var url = '$baseUrl/kitchens.php?';
    if (featured) url += 'featured=1&';
    if (search != null) url += 'q=${Uri.encodeComponent(search)}&';
    if (cuisine != null) url += 'cuisine=${Uri.encodeComponent(cuisine)}&';

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((e) => KitchenModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  static Future<KitchenModel?> getKitchenDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/kitchen_detail.php?id=$id')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return KitchenModel.fromJson(data['data']);
      }
    }
    return null;
  }

  // =============================================
  // MENU ITEMS
  // =============================================

  static Future<List<MenuItemModel>> getMenuItems({int? kitchenId, int? categoryId, bool popular = false, String? search}) async {
    var url = '$baseUrl/menu_items.php?';
    if (kitchenId != null) url += 'kitchen_id=$kitchenId&';
    if (categoryId != null) url += 'category_id=$categoryId&';
    if (popular) url += 'popular=1&';
    if (search != null) url += 'q=${Uri.encodeComponent(search)}&';

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((e) => MenuItemModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  static Future<MenuItemModel?> getMenuDetail(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/menu_detail.php?id=$id')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return MenuItemModel.fromJson(data['data']);
      }
    }
    return null;
  }

  // =============================================
  // CART
  // =============================================

  static Future<List<CartItemModel>> getCart() async {
    final userId = await getUserId();
    if (userId == null) return [];

    final response = await http.get(Uri.parse('$baseUrl/cart.php?user_id=$userId')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((e) => CartItemModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  static Future<bool> addToCart(int menuItemId, {int quantity = 1, String notes = '', List<int> addonIds = const []}) async {
    final userId = await getUserId();
    if (userId == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/cart.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': int.parse(userId),
        'menu_item_id': menuItemId,
        'quantity': quantity,
        'notes': notes,
        'addon_ids': addonIds,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  static Future<bool> removeFromCart(int cartItemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/cart.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'cart_item_id': cartItemId}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  static Future<bool> updateCartQuantity(int cartItemId, int quantity) async {
    final response = await http.put(
      Uri.parse('$baseUrl/cart.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'cart_item_id': cartItemId, 'quantity': quantity}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  // =============================================
  // FAVORITES
  // =============================================

  static Future<List<Map<String, dynamic>>> getFavorites({String type = 'dish'}) async {
    final userId = await getUserId();
    if (userId == null) return [];

    final response = await http.get(Uri.parse('$baseUrl/favorites.php?user_id=$userId&type=$type')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }
    return [];
  }

  static Future<bool> addFavorite({int? menuItemId, int? kitchenId, String type = 'dish'}) async {
    final userId = await getUserId();
    if (userId == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/favorites.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': int.parse(userId),
        'menu_item_id': menuItemId,
        'kitchen_id': kitchenId,
        'type': type,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  static Future<bool> removeFavorite(int favoriteId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/favorites.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'favorite_id': favoriteId}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  // =============================================
  // REVIEWS
  // =============================================

  static Future<List<ReviewModel>> getReviews({int? kitchenId, int? menuItemId}) async {
    var url = '$baseUrl/reviews.php?';
    if (kitchenId != null) url += 'kitchen_id=$kitchenId&';
    if (menuItemId != null) url += 'menu_item_id=$menuItemId&';

    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((e) => ReviewModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  static Future<bool> addReview({int? kitchenId, int? menuItemId, required int rating, String comment = ''}) async {
    final userId = await getUserId();
    if (userId == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/reviews.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': int.parse(userId),
        'kitchen_id': kitchenId,
        'menu_item_id': menuItemId,
        'rating': rating,
        'comment': comment,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  // =============================================
  // NOTIFICATIONS
  // =============================================

  static Future<Map<String, dynamic>> getNotifications() async {
    final userId = await getUserId();
    if (userId == null) return {'notifications': <NotificationModel>[], 'unread_count': 0};

    final response = await http.get(Uri.parse('$baseUrl/notifications.php?user_id=$userId')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return {
          'notifications': (data['data'] as List).map((e) => NotificationModel.fromJson(e)).toList(),
          'unread_count': data['unread_count'] ?? 0,
        };
      }
    }
    return {'notifications': <NotificationModel>[], 'unread_count': 0};
  }

  static Future<bool> markNotificationRead(int notificationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'mark_read', 'notification_id': notificationId}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  // =============================================
  // ORDERS
  // =============================================

  static Future<List<OrderModel>> getOrders() async {
    final userId = await getUserId();
    if (userId == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/orders.php?user_id=$userId'),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((e) => OrderModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  // =============================================
  // CHECKOUT
  // =============================================

  static Future<Map<String, dynamic>?> checkout({int? addressId, String notes = ''}) async {
    final userId = await getUserId();
    if (userId == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/checkout.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': int.parse(userId),
        'address_id': addressId,
        'notes': notes,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return data;
      }
    }
    return null;
  }

  // =============================================
  // SEARCH
  // =============================================

  static Future<Map<String, dynamic>> search(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search.php?q=${Uri.encodeComponent(query)}'),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return {
          'kitchens': (data['kitchens'] as List).map((e) => KitchenModel.fromJson(e)).toList(),
          'menu_items': (data['menu_items'] as List).map((e) => MenuItemModel.fromJson(e)).toList(),
        };
      }
    }
    return {'kitchens': <KitchenModel>[], 'menu_items': <MenuItemModel>[]};
  }

  // =============================================
  // ADDRESSES
  // =============================================

  static Future<List<AddressModel>> getAddresses() async {
    final userId = await getUserId();
    if (userId == null) return [];

    final response = await http.get(Uri.parse('$baseUrl/addresses.php?user_id=$userId')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((e) => AddressModel.fromJson(e)).toList();
      }
    }
    return [];
  }

  static Future<bool> addAddress(String address, {String label = 'Home', bool isDefault = false}) async {
    final userId = await getUserId();
    if (userId == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/addresses.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_id': int.parse(userId),
        'label': label,
        'address': address,
        'is_default': isDefault ? 1 : 0,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  // =============================================
  // IMAGE UPLOAD
  // =============================================

  static Future<String?> uploadImage(XFile image) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload.php'));
    final bytes = await image.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['url'];
        }
      }
    } catch (e) {
      // ignore
    }
    return null;
  }

  // =============================================
  // PROMOTIONS
  // =============================================

  static Future<List<PromotionModel>> getPromotions() async {
    final response = await http.get(Uri.parse('$baseUrl/promotions.php')).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List).map((e) => PromotionModel.fromJson(e)).toList();
      }
    }
    return [];
  }
  static Future<bool> createMenuItem(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/menu_item_create.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final resData = json.decode(response.body);
      return resData['success'] == true;
    }
    return false;
  }

  static Future<bool> deleteMenuItem(int id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/menu_item_delete.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    }
    return false;
  }

  static Future<bool> updateKitchen(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/kitchen_update.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final resData = json.decode(response.body);
      return resData['success'] == true;
    }
    return false;
  }
}
