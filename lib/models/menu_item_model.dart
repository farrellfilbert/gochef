import '../services/api_service.dart';
import 'review_model.dart';
import 'menu_addon_model.dart';

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
  final int categoryId;
  final String createdAt;
  final String categoryName;
  final List<ReviewModel>? reviews;
  final List<MenuAddonModel>? addons;
  final List<MenuAddonCategoryModel>? addonCategories;

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
    this.categoryId = 0,
    this.createdAt = '',
    this.categoryName = '',
    this.reviews,
    this.addons,
    this.addonCategories,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kitchenId: int.tryParse(json['kitchen_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      image: ApiService.formatImageUrl(json['image'] ?? json['image_url']),
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      totalReviews: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      prepTime: json['prep_time'] ?? '15-20 min',
      isAvailable: json['is_available']?.toString() != '0',
      isPopular: json['is_popular']?.toString() == '1',
      kitchenName: json['kitchen_name'] ?? '',
      kitchenAvatar: ApiService.formatImageUrl(json['kitchen_avatar']),
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] ?? '',
      categoryName: json['category_name'] ?? '',
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((i) => ReviewModel.fromJson(i)).toList()
          : null,
      addons: json['addons'] != null
          ? (json['addons'] as List).map((i) => MenuAddonModel.fromJson(i)).toList()
          : null,
      addonCategories: json['addon_categories'] != null
          ? (json['addon_categories'] as List).map((i) => MenuAddonCategoryModel.fromJson(i)).toList()
          : null,
    );
  }
}
