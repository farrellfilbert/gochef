import '../services/api_service.dart';
import 'menu_item_model.dart';
import 'review_model.dart';

class KitchenModel {
  final int id;
  final int userId;
  final String name;
  final String chefName;
  final String description;
  final String avatar;
  final String coverImage;
  final double rating;
  final int totalReviews;
  final String cuisineType;
  final String deliveryTime;
  final String businessHours;
  final bool isOpen;
  final String location;
  final double? latitude;
  final double? longitude;
  final bool isVerified;
  final bool isFeatured;
  final String createdAt;
  final List<String> atmosphereImages;
  final List<MenuItemModel>? menuItems;
  final List<ReviewModel>? reviews;

  KitchenModel({
    required this.id,
    this.userId = 0,
    required this.name,
    this.chefName = '',
    this.description = '',
    this.avatar = '',
    this.coverImage = '',
    this.rating = 0.0,
    this.totalReviews = 0,
    this.cuisineType = '',
    this.deliveryTime = '20-30 min',
    this.businessHours = '09:00 AM - 10:00 PM',
    this.isOpen = true,
    this.location = '',
    this.latitude,
    this.longitude,
    this.isVerified = false,
    this.isFeatured = false,
    this.createdAt = '',
    this.atmosphereImages = const [],
    this.menuItems,
    this.reviews,
  });

  factory KitchenModel.fromJson(Map<String, dynamic> json) {
    return KitchenModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      chefName: json['chef_name'] ?? '',
      description: json['description'] ?? '',
      avatar: ApiService.formatImageUrl(json['avatar']),
      coverImage: ApiService.formatImageUrl(json['cover_image']),
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      totalReviews: int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      cuisineType: json['cuisine_type'] ?? '',
      deliveryTime: json['delivery_time'] ?? '20-30 min',
      businessHours: json['business_hours'] != null && json['business_hours'].toString().isNotEmpty
          ? json['business_hours'].toString()
          : '09:00 AM - 10:00 PM',
      isOpen: json['is_open'] == null ? true : (json['is_open'].toString() == '1' || json['is_open'] == true),
      location: json['location'] ?? '',
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      isVerified: json['is_verified']?.toString() == '1',
      isFeatured: json['is_featured']?.toString() == '1',
      createdAt: json['created_at'] ?? '',
      atmosphereImages: json['atmosphere_images'] != null && json['atmosphere_images'] is List
          ? (json['atmosphere_images'] as List).map((e) => ApiService.formatImageUrl(e.toString())).toList()
          : [],
      menuItems: json['menu_items'] != null
          ? (json['menu_items'] as List).map((e) => MenuItemModel.fromJson(e)).toList()
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((e) => ReviewModel.fromJson(e)).toList()
          : null,
    );
  }
}
