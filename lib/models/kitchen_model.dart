import '../services/api_service.dart';
import 'menu_item_model.dart';
import 'review_model.dart';

class ChefCertificate {
  final String title;
  final String type;
  final String url;
  final String issueDate;

  ChefCertificate({
    required this.title,
    required this.type,
    required this.url,
    this.issueDate = '',
  });

  factory ChefCertificate.fromJson(Map<String, dynamic> json) {
    return ChefCertificate(
      title: json['title'] ?? json['name'] ?? 'Certificate',
      type: json['type'] ?? 'Accreditation',
      url: ApiService.formatImageUrl(json['url'] ?? json['image_url'] ?? json['file']),
      issueDate: json['issue_date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'url': url,
      'issue_date': issueDate,
    };
  }
}

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
  final List<ChefCertificate> certificates;
  final List<MenuItemModel>? menuItems;
  final List<ReviewModel>? reviews;
  final bool hasPurchased;

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
    this.certificates = const [],
    this.menuItems,
    this.reviews,
    this.hasPurchased = false,
  });

  /// Returns an approximate location (City, State / Area) similar to Airbnb
  /// to protect chef privacy until an order/purchase is made.
  String get approximateLocation {
    if (location.trim().isEmpty) return '';
    final rawParts = location.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (rawParts.length <= 2) {
      final first = rawParts.first;
      if (RegExp(r'^\d+\s+').hasMatch(first) && rawParts.length == 2) {
        return rawParts[1];
      }
      return location;
    }

    List<String> meaningful = [];
    for (int i = 0; i < rawParts.length; i++) {
      final p = rawParts[i];
      if (RegExp(r'^\d+$').hasMatch(p)) continue;
      if (i < 2 && RegExp(r'(\b(st|street|ave|avenue|blvd|boulevard|rd|road|dr|drive|lane|ln|way|ct|court|pkwy|parkway)\b|^\d+)', caseSensitive: false).hasMatch(p)) {
        continue;
      }
      meaningful.add(p);
    }

    if (meaningful.isNotEmpty) {
      if (meaningful.length >= 2) {
        final city = meaningful[0];
        String second = meaningful[1];
        if (meaningful.length >= 3 && second.toLowerCase().contains('county')) {
          final state = meaningful[2];
          return '$city, $state';
        }
        return '$city, $second';
      }
      return meaningful.first;
    }

    if (rawParts.length >= 3) {
      return '${rawParts[rawParts.length - 3]}, ${rawParts[rawParts.length - 2]}';
    }
    return location;
  }

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
      certificates: json['certificates'] != null && json['certificates'] is List
          ? (json['certificates'] as List).map((e) => ChefCertificate.fromJson(e is Map<String, dynamic> ? e : {})).toList()
          : [],
      menuItems: json['menu_items'] != null
          ? (json['menu_items'] as List).map((e) => MenuItemModel.fromJson(e)).toList()
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((e) => ReviewModel.fromJson(e)).toList()
          : null,
      hasPurchased: json['has_purchased'] == true || json['has_purchased']?.toString() == '1',
    );
  }
}
