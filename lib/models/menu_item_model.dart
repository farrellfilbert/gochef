class AddonModel {
  final int id;
  final String name;
  final double price;

  AddonModel({required this.id, required this.name, this.price = 0.0});

  factory AddonModel.fromJson(Map<String, dynamic> json) {
    return AddonModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class MenuItemModel {
  final int id;
  final int kitchenId;
  final String name;
  final String description;
  final double price;
  final String image;
  final double rating;
  final int totalReviews;
  final String prepTime;
  final bool isAvailable;
  final bool isPopular;
  final String kitchenName;
  final String kitchenAvatar;
  final String categoryName;
  final List<AddonModel>? addons;

  MenuItemModel({
    required this.id,
    this.kitchenId = 0,
    required this.name,
    this.description = '',
    required this.price,
    this.image = '',
    this.rating = 0.0,
    this.totalReviews = 0,
    this.prepTime = '15-20 min',
    this.isAvailable = true,
    this.isPopular = false,
    this.kitchenName = '',
    this.kitchenAvatar = '',
    this.categoryName = '',
    this.addons,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kitchenId: int.tryParse(json['kitchen_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      image: json['image'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      totalReviews: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      prepTime: json['prep_time'] ?? '15-20 min',
      isAvailable: json['is_available']?.toString() != '0',
      isPopular: json['is_popular']?.toString() == '1',
      kitchenName: json['kitchen_name'] ?? '',
      kitchenAvatar: json['kitchen_avatar'] ?? '',
      categoryName: json['category_name'] ?? '',
      addons: json['addons'] != null
          ? (json['addons'] as List).map((e) => AddonModel.fromJson(e)).toList()
          : null,
    );
  }
}
