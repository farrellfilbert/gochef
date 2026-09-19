import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/kitchen_model.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../models/cart_item_model.dart';
import '../models/review_model.dart';
import '../models/notification_model.dart';
import '../models/promotion_model.dart';
import '../models/address_model.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty && !origin.contains('localhost') && !origin.contains('127.0.0.1')) {
        return '$origin/api';
      }
    }
    return 'https://thegrubnextdoor.com/api';
  }

  static String formatImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    var cleanUrl = url.trim();
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.isNotEmpty && !origin.contains('localhost') && !origin.contains('127.0.0.1')) {
        cleanUrl = cleanUrl
            .replaceAll('https://thegrubnextdoor.com', origin)
            .replaceAll('http://thegrubnextdoor.com', origin)
            .replaceAll('https://www.thegrubnextdoor.com', origin)
            .replaceAll('http://www.thegrubnextdoor.com', origin)
            .replaceAll('https://astroboomin.co', origin)
            .replaceAll('http://astroboomin.co', origin);
      }
    }
    return cleanUrl;
  }
  
  static String? _cachedUserId;
  static String? _cachedRole;
  static String? _cachedKitchenId;

  // =============================================
  // AUTH / USER
  // =============================================

  static Future<String?> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId;
    final prefs = await SharedPreferences.getInstance();
    _cachedUserId = prefs.getString('user_id');
    return _cachedUserId;
  }
  
  static Future<String?> getUserRole() async {
    if (_cachedRole != null) return _cachedRole;
    final prefs = await SharedPreferences.getInstance();
    _cachedRole = prefs.getString('user_role');
    return _cachedRole;
  }
  
  static Future<String?> getKitchenId() async {
    if (_cachedKitchenId != null && _cachedKitchenId!.isNotEmpty) return _cachedKitchenId;
    final prefs = await SharedPreferences.getInstance();
    _cachedKitchenId = prefs.getString('kitchen_id');
    if (_cachedKitchenId != null && _cachedKitchenId!.isNotEmpty) return _cachedKitchenId;

    // Auto-resolve from getProfile() if user is logged in
    try {
      final userId = await getUserId();
      if (userId != null && userId.isNotEmpty) {
        final profile = await getProfile();
        if (profile.kitchenId != null && profile.kitchenId!.isNotEmpty) {
          _cachedKitchenId = profile.kitchenId;
          await prefs.setString('kitchen_id', profile.kitchenId!);
          return _cachedKitchenId;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<void> saveUserId(String userId, {String role = 'user', String? kitchenId}) async {
    _cachedUserId = userId;
    _cachedRole = role;
    _cachedKitchenId = kitchenId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    await prefs.setString('user_role', role);
    if (kitchenId != null) {
      await prefs.setString('kitchen_id', kitchenId);
    } else {
      await prefs.remove('kitchen_id');
    }
  }

  static Future<void> logout() async {
    _cachedUserId = null;
    _cachedRole = null;
    _cachedKitchenId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_role');
    await prefs.remove('kitchen_id');
  }

  static Future<bool> deleteAccount() async {
    final userId = await getUserId();
    if (userId == null) return false;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/delete_account.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          await logout();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return false;
    }
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
  // MOCK DATA FOR SIMULATION
  // =============================================
  
  static final List<KitchenModel> _mockKitchens = [
    KitchenModel(
      id: 1,
      name: "Chef's Kitchen",
      coverImage: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=600&auto=format&fit=crop',
      avatar: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=600&auto=format&fit=crop',
      rating: 4.8,
      deliveryTime: '15-25 min',
      description: 'Premium quality meals cooked with passion.',
    ),
    KitchenModel(
      id: 2,
      name: 'Spice Symphony',
      coverImage: 'https://images.unsplash.com/photo-1549488344-c5d0137a28eb?q=80&w=600&auto=format&fit=crop',
      avatar: 'https://images.unsplash.com/photo-1549488344-c5d0137a28eb?q=80&w=600&auto=format&fit=crop',
      rating: 4.6,
      deliveryTime: '25-40 min',
      description: 'Experience the magic of authentic spices.',
    ),
  ];

  static final List<MenuItemModel> _mockMenuItems = [
    MenuItemModel(
      id: 1,
      kitchenId: 1,
      name: 'Grilled Salmon Bowl',
      description: 'Fresh grilled salmon with quinoa and roasted vegetables.',
      price: 45000,
      image: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop',
      isPopular: true,
      categoryName: 'Healthy',
    ),
    MenuItemModel(
      id: 2,
      kitchenId: 1,
      name: 'Avocado Toast',
      description: 'Smashed avocado on sourdough with poached egg.',
      price: 25000,
      image: 'https://images.unsplash.com/photo-1525351484163-9e45e514869e?q=80&w=600&auto=format&fit=crop',
      isPopular: false,
      categoryName: 'Breakfast',
    ),
    MenuItemModel(
      id: 3,
      kitchenId: 2,
      name: 'Spicy Chicken Burger',
      description: 'Crispy chicken patty with spicy mayo and fresh lettuce.',
      price: 35000,
      image: 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?q=80&w=600&auto=format&fit=crop',
      isPopular: true,
      categoryName: 'Fast Food',
    ),
  ];

  static final List<CartItemModel> _mockCart = [];
  static int _cartIdCounter = 1;


  // =============================================
  // KITCHEN
  // =============================================

  static Future<List<ReviewModel>> getKitchenReviews(int kitchenId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reviews.php?kitchen_id=$kitchenId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] && data['data'] != null) {
          return (data['data'] as List).map((e) => ReviewModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Error getting kitchen reviews: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getKitchenAnalytics(int kitchenId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/analytics.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'kitchen_id': kitchenId}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
    } catch (e) {
      print('Error getting analytics: $e');
    }
    return null;
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
    try {
      final response = await http.get(Uri.parse('$baseUrl/kitchen_detail.php?id=$id')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return KitchenModel.fromJson(data['data']);
        }
      }
    } catch (e) {
      debugPrint('Error getting kitchen detail: $e');
    }
    return null;
  }

  static Future<KitchenModel?> getKitchenDetailByUserId(int userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/kitchen_detail.php?user_id=$userId')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return KitchenModel.fromJson(data['data']);
        }
      }
    } catch (e) {
      debugPrint('Error getting kitchen detail by user id: $e');
    }
    return null;
  }

  // =============================================
  // CATEGORIES
  // =============================================

  static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories.php')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((e) => CategoryModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Error getting categories: $e');
    }
    return [];
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
  // CALORIES TRACKER
  // =============================================

  static Future<Map<String, dynamic>?> getUserCalories(dynamic userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user_calories.php?user_id=$userId')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data;
        }
      }
    } catch (e) {
      print('Error getting user calories: $e');
    }
    return null;
  }

  static Future<bool> updateUserCaloriesGoal(dynamic userId, int dailyGoal) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user_calories.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'daily_goal': dailyGoal,
        }),
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error updating user calories goal: $e');
    }
    return false;
  }

  // =============================================
  // CART
  // =============================================

  static Future<List<CartItemModel>> getCart() async {
    final userId = await getUserId();
    if (userId == null) return [];
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/cart.php?user_id=$userId')).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((e) => CartItemModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Error getting cart: $e');
    }
    return [];
  }

  static Future<bool> addToCart(int menuItemId, {int quantity = 1, String notes = '', List<int> addonIds = const []}) async {
    final userId = await getUserId();
    if (userId == null) return false;
    
    try {
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
    } catch (e) {
      print('Error adding to cart: $e');
    }
    return false;
  }

  static Future<bool> removeFromCart(int cartItemId) async {
    final userId = await getUserId();
    if (userId == null) return false;
    
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/cart.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'cart_item_id': cartItemId}),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error removing from cart: $e');
    }
    return false;
  }

  static Future<bool> updateCartQuantity(int cartItemId, int quantity) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/cart.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'cart_item_id': cartItemId,
          'quantity': quantity,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error updating cart quantity: $e');
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

  static Future<bool> markAllNotificationsRead() async {
    final userId = await getUserId();
    if (userId == null) return false;

    final response = await http.post(
      Uri.parse('$baseUrl/notifications.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'mark_all_read', 'user_id': userId}),
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
    final role = await getUserRole();
    final kitchenId = await getKitchenId();
    if (userId == null) return [];

    var url = '$baseUrl/orders.php?';
    if (role == 'chef' && kitchenId != null) {
      url += 'kitchen_id=$kitchenId';
    } else {
      url += 'user_id=$userId';
    }

    final response = await http.get(
      Uri.parse(url),
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
  // CHECKOUT & UBER DELIVERY
  // =============================================

  static Future<Map<String, dynamic>?> getDeliveryQuote({
    required int kitchenId,
    required String dropoffAddress,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_delivery_quote.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'kitchen_id': kitchenId,
          'dropoff_address': dropoffAddress,
          'dropoff_lat': dropoffLat,
          'dropoff_lng': dropoffLng,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error getting delivery quote: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> requestUberDelivery(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request_uber_delivery.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'order_id': orderId}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error requesting Uber delivery: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> checkout({
    int? addressId, 
    required int kitchenId, 
    String notes = '',
    String orderType = 'delivery',
    String? dineInDate,
    String? dineInTime,
    String? promoCode,
  }) async {
    final userId = await getUserId();
    if (userId == null) return null;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkout.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': int.parse(userId),
          'kitchen_id': kitchenId,
          'address_id': addressId,
          'notes': notes,
          'order_type': orderType,
          'dine_in_date': dineInDate,
          'dine_in_time': dineInTime,
          'promo_code': promoCode,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error during checkout: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createStripeCheckout({
    int? addressId, 
    required int kitchenId, 
    String notes = '',
    String orderType = 'delivery',
    String? dineInDate,
    String? dineInTime,
    String? promoCode,
    double deliveryFee = 4.0,
    double serviceFee = 2.50,
  }) async {
    final userId = await getUserId();
    if (userId == null) return null;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create_stripe_payment_intent.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': int.parse(userId),
          'kitchen_id': kitchenId,
          'address_id': addressId,
          'notes': notes,
          'order_type': orderType,
          'dine_in_date': dineInDate,
          'dine_in_time': dineInTime,
          'promo_code': promoCode,
          'delivery_fee': deliveryFee,
          'service_fee': serviceFee,
        }),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Error creating stripe payment intent: $e');
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

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/addresses.php?user_id=$userId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List).map((e) => AddressModel.fromJson(e)).toList();
        }
      }
    } catch (e) {
      print('Error getting addresses: $e');
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

    String fileName = image.name;
    if (fileName.isEmpty || fileName.contains('blob:') || !fileName.contains('.')) {
      fileName = 'image.jpg';
    }

    // Detect MIME type from extension; default to image/jpeg for web compatibility
    String ext = fileName.split('.').last.toLowerCase();
    String mimeType;
    switch (ext) {
      case 'png': mimeType = 'image/png'; break;
      case 'webp': mimeType = 'image/webp'; break;
      case 'gif': mimeType = 'image/gif'; break;
      default: mimeType = 'image/jpeg'; break;
    }

    request.files.add(http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: fileName,
      contentType: MediaType.parse(mimeType),
    ));

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

  static Future<bool> updateMenuItem(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/menu_item_update.php'),
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
  
  static Future<bool> updateOrderStatus(String orderId, String status) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_order_status.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'order_id': orderId,
        'status': status,
      }),
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
  

  // =============================================
  static Future<Map<String, dynamic>> getUnreadCounts({String? lastOpenTime}) async {
    final userId = await getUserId();
    if (userId == null) return {'unread_notifications': 0, 'unread_chats': 0, 'total_unread': 0};

    try {
      String urlStr = '$baseUrl/unread_counts.php?user_id=$userId';
      if (lastOpenTime != null) {
        urlStr += '&last_open_time=${Uri.encodeComponent(lastOpenTime)}';
      }
      final url = Uri.parse(urlStr);
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return {'unread_notifications': 0, 'unread_chats': 0, 'total_unread': 0};
    } catch (e) {
      debugPrint('Error getting unread counts: $e');
      return {'unread_notifications': 0, 'unread_chats': 0, 'total_unread': 0};
    }
  }

  // CHAT
  // =============================================
  
  static Future<bool> sendChatMessage(String receiverId, String message, {String? kitchenId, String? orderId, String? imageUrl}) async {
    final senderId = await getUserId();
    if (senderId == null) return false;

    try {
      final url = Uri.parse('$baseUrl/chat_send.php');
      final body = {
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
      };
      if (kitchenId != null) body['kitchen_id'] = kitchenId;
      if (orderId != null) body['order_id'] = orderId;
      if (imageUrl != null) body['image_url'] = imageUrl;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  static Future<bool> updateAddress(int id, String address, String label) async {
      try {
        final userId = await getUserId();
        if (userId == null) return false;
        
        final response = await http.put(
          Uri.parse('$baseUrl/addresses.php'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'id': id,
            'label': label,
            'address': address,
          }),
        );
        return response.statusCode == 200;
      } catch (e) {
        print('Error updating address: $e');
        return false;
      }
  }

  static Future<String?> uploadImageBase64(String base64Str) async {
    try {
      final url = Uri.parse('$baseUrl/upload.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image': base64Str}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['url'] != null) {
          return data['url'] as String;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  static Future<bool> submitReview({
    required int rating,
    String? comment,
    int? kitchenId,
    int? menuItemId,
    String? orderId,
  }) async {
    try {
      final userId = await getUserId();
      if (userId == null) return false;

      final url = Uri.parse('$baseUrl/reviews.php');
      final body = {
        'user_id': int.tryParse(userId) ?? 0,
        'rating': rating,
        'comment': comment ?? '',
      };
      if (kitchenId != null) body['kitchen_id'] = kitchenId;
      if (menuItemId != null) body['menu_item_id'] = menuItemId;
      if (orderId != null) body['order_id'] = orderId;

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error submitting review: $e');
      return false;
    }
  }
  
  static Future<List<Map<String, dynamic>>> getChatMessages(String otherUserId, {String? orderId}) async {
    try {
      final userId = await getUserId();
      if (userId == null) return [];
      
      String urlStr = '$baseUrl/chat_messages.php?user1_id=$userId&user2_id=$otherUserId';
      if (orderId != null) {
        urlStr += '&order_id=$orderId';
      }
      final url = Uri.parse(urlStr);
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['messages']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting messages: $e');
      return [];
    }
  }
  
  static Future<List<Map<String, dynamic>>> getChatInbox() async {
    try {
      final userId = await getUserId();
      final role = await getUserRole() ?? 'user';
      if (userId == null) return [];
      
      final url = Uri.parse('$baseUrl/chat_inbox.php?user_id=$userId&role=$role');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['inbox']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting inbox: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getSupportAdmin() async {
    try {
      final url = Uri.parse('$baseUrl/get_support_admin.php');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['admin'] != null) {
          return Map<String, dynamic>.from(data['admin']);
        }
      }
    } catch (e) {
      debugPrint('Error getting support admin: $e');
    }
    return null;
  }

  // =============================================
  // ADMIN CONTROL PANEL
  // =============================================

  static Future<List<Map<String, dynamic>>> getAdminChefs({String filter = 'all'}) async {
    try {
      final url = Uri.parse('$baseUrl/admin_chefs.php?filter=$filter');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting admin chefs: $e');
      return [];
    }
  }

  static Future<bool> approveChef(int kitchenId, {String? userId}) async {
    try {
      final url = Uri.parse('$baseUrl/admin_chefs.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'approve',
          'kitchen_id': kitchenId,
          if (userId != null) 'user_id': userId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error approving chef: $e');
      return false;
    }
  }

  static Future<bool> rejectChef(int kitchenId, {String? userId, String reason = 'Requirements not met'}) async {
    try {
      final url = Uri.parse('$baseUrl/admin_chefs.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'reject',
          'kitchen_id': kitchenId,
          if (userId != null) 'user_id': userId,
          'reason': reason,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error rejecting chef: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getAdminPromotions() async {
    try {
      final url = Uri.parse('$baseUrl/admin_promotions.php');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting admin promotions: $e');
      return [];
    }
  }

  static Future<bool> createPromotion({
    required String title,
    String subtitle = '',
    String image = '',
    int discountPercent = 0,
    String code = '',
    bool isActive = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/admin_promotions.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'create',
          'title': title,
          'subtitle': subtitle,
          'image': image,
          'discount_percent': discountPercent,
          'code': code,
          'is_active': isActive ? 1 : 0,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error creating promotion: $e');
      return false;
    }
  }

  static Future<bool> togglePromotion(int promoId, bool isActive) async {
    try {
      final url = Uri.parse('$baseUrl/admin_promotions.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'toggle',
          'id': promoId,
          'is_active': isActive ? 1 : 0,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error toggling promotion: $e');
      return false;
    }
  }

  static Future<bool> deletePromotion(int promoId) async {
    try {
      final url = Uri.parse('$baseUrl/admin_promotions.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'delete',
          'id': promoId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting promotion: $e');
      return false;
    }
  }

  // ==========================================
  // ADMIN USERS & KITCHENS MODERATION METHODS
  // ==========================================

  static Future<List<Map<String, dynamic>>> getAdminUsers({String type = 'all', String search = ''}) async {
    try {
      final queryParams = <String, String>{};
      if (type != 'all') queryParams['type'] = type;
      if (search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/admin_users.php').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching admin users: $e');
      return [];
    }
  }

  static Future<bool> adminSuspendUser({String? userId, String? kitchenId, String reason = 'Terms Violation'}) async {
    try {
      final url = Uri.parse('$baseUrl/admin_users.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'suspend',
          'user_id': userId,
          'kitchen_id': kitchenId,
          'reason': reason,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error suspending user: $e');
      return false;
    }
  }

  static Future<bool> adminUnsuspendUser({String? userId, String? kitchenId}) async {
    try {
      final url = Uri.parse('$baseUrl/admin_users.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'unsuspend',
          'user_id': userId,
          'kitchen_id': kitchenId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error unsuspending user: $e');
      return false;
    }
  }

  static Future<bool> adminDeleteUser({String? userId, String? kitchenId}) async {
    try {
      final url = Uri.parse('$baseUrl/admin_users.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'delete',
          'user_id': userId,
          'kitchen_id': kitchenId,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }
}
