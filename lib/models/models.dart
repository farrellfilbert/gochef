class AppUser {
  final String id;
  final String role;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;

  AppUser({
    required this.id,
    required this.role,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      role: json['role'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class Kitchen {
  final String id;
  final String chefId;
  final String name;
  final String? description;
  final bool isOpen;
  final double? latitude;
  final double? longitude;
  final String? address;
  final double rating;
  final String? coverImageUrl;

  Kitchen({
    required this.id,
    required this.chefId,
    required this.name,
    this.description,
    required this.isOpen,
    this.latitude,
    this.longitude,
    this.address,
    required this.rating,
    this.coverImageUrl,
  });

  factory Kitchen.fromJson(Map<String, dynamic> json) {
    return Kitchen(
      id: json['id'] as String,
      chefId: json['chef_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      isOpen: json['is_open'] as bool? ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      coverImageUrl: json['cover_image_url'] as String?,
    );
  }
}

class MenuItem {
  final String id;
  final String kitchenId;
  final String name;
  final String? description;
  final double price;
  final String? category;
  final String? cuisine;
  final String? imageUrl;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.kitchenId,
    required this.name,
    this.description,
    required this.price,
    this.category,
    this.cuisine,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      kitchenId: json['kitchen_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String?,
      cuisine: json['cuisine'] as String?,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }
}

class OrderItem {
  final String id;
  final String orderId;
  final String menuItemId;
  final int quantity;
  final double priceAtTime;
  final MenuItem? menuItem; // Optional joined data

  OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.priceAtTime,
    this.menuItem,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      menuItemId: json['menu_item_id'] as String,
      quantity: json['quantity'] as int,
      priceAtTime: (json['price_at_time'] as num).toDouble(),
      menuItem: json['menu_items'] != null ? MenuItem.fromJson(json['menu_items']) : null,
    );
  }
}

class OrderModel {
  final String id;
  final String foodieId;
  final String kitchenId;
  final String status;
  final double totalAmount;
  final String? deliveryAddress;
  final DateTime createdAt;
  final List<OrderItem> items; // Joined items
  final AppUser? foodie; // Joined foodie profile

  OrderModel({
    required this.id,
    required this.foodieId,
    required this.kitchenId,
    required this.status,
    required this.totalAmount,
    this.deliveryAddress,
    required this.createdAt,
    this.items = const [],
    this.foodie,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItem> parsedItems = [];
    if (json['order_items'] != null) {
      parsedItems = (json['order_items'] as List).map((i) => OrderItem.fromJson(i)).toList();
    }

    return OrderModel(
      id: json['id'] as String,
      foodieId: json['foodie_id'] as String,
      kitchenId: json['kitchen_id'] as String,
      status: json['status'] as String,
      totalAmount: (json['total_amount'] as num).toDouble(),
      deliveryAddress: json['delivery_address'] as String?,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      items: parsedItems,
      foodie: json['profiles'] != null ? AppUser.fromJson(json['profiles']) : null,
    );
  }
}
