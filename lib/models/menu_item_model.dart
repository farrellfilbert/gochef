import 'dart:convert';
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
  final int calories;
  final String createdAt;
  final String categoryName;
  final String status;
  final String? rejectionReason;
  final List<String> dietaryTags;
  final int dailyQuota;
  final int portionsSoldToday;
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
    this.calories = 650,
    this.createdAt = '',
    this.categoryName = '',
    this.status = 'approved',
    this.rejectionReason,
    this.dietaryTags = const [],
    this.dailyQuota = 20,
    this.portionsSoldToday = 0,
    this.reviews,
    this.addons,
    this.addonCategories,
  });

  int get remainingPortions => (dailyQuota > 0) ? (dailyQuota - portionsSoldToday).clamp(0, dailyQuota) : 99;
  bool get isLowStock => dailyQuota > 0 && remainingPortions > 0 && remainingPortions <= 5;
  bool get isSoldOutForToday => dailyQuota > 0 && remainingPortions <= 0;

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedTags = [];
    final rawTags = json['dietary_tags'];
    if (rawTags is String && rawTags.trim().isNotEmpty) {
      if (rawTags.trim().startsWith('[')) {
        try {
          final list = jsonDecode(rawTags);
          if (list is List) parsedTags = list.map((e) => e.toString()).toList();
        } catch (_) {}
      } else {
        parsedTags = rawTags.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
    } else if (rawTags is List) {
      parsedTags = rawTags.map((e) => e.toString()).toList();
    }

    return MenuItemModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      kitchenId: int.tryParse(json['kitchen_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      image: ApiService.formatImageUrl(json['image'] ?? json['image_url']),
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      totalReviews: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      prepTime: (json['prep_time'] != null && json['prep_time'].toString().isNotEmpty)
          ? json['prep_time'].toString()
          : (json['delivery_time'] != null && json['delivery_time'].toString().isNotEmpty
              ? json['delivery_time'].toString()
              : '15-20 min'),
      isAvailable: json['is_available'] == null
          ? true
          : (json['is_available'].toString() != '0' && json['is_available'].toString().toLowerCase() != 'false'),
      isPopular: json['is_popular']?.toString() == '1',
      kitchenName: json['kitchen_name'] ?? '',
      kitchenAvatar: ApiService.formatImageUrl(json['kitchen_avatar']),
      categoryId: int.tryParse(json['category_id']?.toString() ?? '0') ?? 0,
      calories: int.tryParse(json['calories']?.toString() ?? '') ?? 650,
      createdAt: json['created_at'] ?? '',
      categoryName: json['category_name'] ?? '',
      status: json['status']?.toString() ?? 'approved',
      rejectionReason: json['rejection_reason']?.toString(),
      dietaryTags: parsedTags,
      dailyQuota: int.tryParse(json['daily_quota']?.toString() ?? '20') ?? 20,
      portionsSoldToday: int.tryParse(json['portions_sold_today']?.toString() ?? '0') ?? 0,
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
