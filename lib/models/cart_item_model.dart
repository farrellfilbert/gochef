import '../services/api_service.dart';

class CartItemModel {
  final int cartItemId;
  final int menuItemId;
  final String name;
  final double price;
  final String image;
  final String prepTime;
  int quantity;
  final String notes;
  final String kitchenName;
  final String kitchenAvatar;
  final int kitchenId;
  final List<CartAddonModel> addons;

  CartItemModel({
    required this.cartItemId,
    required this.menuItemId,
    required this.name,
    required this.price,
    required this.image,
    required this.prepTime,
    required this.quantity,
    this.notes = '',
    this.kitchenName = '',
    this.kitchenAvatar = '',
    this.kitchenId = 0,
    this.addons = const [],
  });

  double get totalPrice {
    double addonTotal = addons.fold(0.0, (sum, a) => sum + a.price);
    return (price + addonTotal) * quantity;
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: int.tryParse(json['cart_item_id']?.toString() ?? '0') ?? 0,
      menuItemId: int.tryParse(json['menu_item_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      image: ApiService.formatImageUrl(json['image'] ?? json['image_url']),
      prepTime: json['prep_time'] ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      notes: json['notes'] ?? '',
      kitchenName: json['kitchen_name'] ?? '',
      kitchenAvatar: ApiService.formatImageUrl(json['kitchen_avatar']),
      kitchenId: int.tryParse(json['kitchen_id']?.toString() ?? '0') ?? 0,
      addons: json['addons'] != null
          ? (json['addons'] as List).map((e) => CartAddonModel.fromJson(e)).toList()
          : [],
    );
  }
}

class CartAddonModel {
  final String name;
  final double price;

  CartAddonModel({required this.name, this.price = 0.0});

  factory CartAddonModel.fromJson(Map<String, dynamic> json) {
    return CartAddonModel(
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}
