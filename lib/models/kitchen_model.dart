import 'dart:convert';
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
      url: ApiService.formatImageUrl(json['url'] ?? json['image'] ?? json['image_url'] ?? json['file']),
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
  final String bankName;
  final String bankAccountHolder;
  final String bankAccountNumber;
  final String bankRoutingNumber;
  final String stripeAccountId;

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
    this.bankName = '',
    this.bankAccountHolder = '',
    this.bankAccountNumber = '',
    this.bankRoutingNumber = '',
    this.stripeAccountId = '',
  });

  KitchenModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? chefName,
    String? description,
    String? avatar,
    String? coverImage,
    double? rating,
    int? totalReviews,
    String? cuisineType,
    String? deliveryTime,
    String? businessHours,
    bool? isOpen,
    String? location,
    double? latitude,
    double? longitude,
    bool? isVerified,
    bool? isFeatured,
    String? createdAt,
    List<String>? atmosphereImages,
    List<ChefCertificate>? certificates,
    List<MenuItemModel>? menuItems,
    List<ReviewModel>? reviews,
    bool? hasPurchased,
    String? bankName,
    String? bankAccountHolder,
    String? bankAccountNumber,
    String? bankRoutingNumber,
    String? stripeAccountId,
  }) {
    return KitchenModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      chefName: chefName ?? this.chefName,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      coverImage: coverImage ?? this.coverImage,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      cuisineType: cuisineType ?? this.cuisineType,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      businessHours: businessHours ?? this.businessHours,
      isOpen: isOpen ?? this.isOpen,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      atmosphereImages: atmosphereImages ?? this.atmosphereImages,
      certificates: certificates ?? this.certificates,
      menuItems: menuItems ?? this.menuItems,
      reviews: reviews ?? this.reviews,
      hasPurchased: hasPurchased ?? this.hasPurchased,
      bankName: bankName ?? this.bankName,
      bankAccountHolder: bankAccountHolder ?? this.bankAccountHolder,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankRoutingNumber: bankRoutingNumber ?? this.bankRoutingNumber,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
    );
  }

  String get effectiveCoverImage {
    if (coverImage.trim().isNotEmpty) return coverImage.trim();
    if (avatar.trim().isNotEmpty) return avatar.trim();
    return 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80';
  }

  String get effectiveAvatar {
    if (avatar.trim().isNotEmpty) return avatar.trim();
    if (coverImage.trim().isNotEmpty) return coverImage.trim();
    return 'https://images.unsplash.com/photo-1577219491135-ce391730fb2c?auto=format&fit=crop&w=400&q=80';
  }

  /// Returns chef display name with First Name + Last Initial (e.g. "Elizabeth S.")
  /// to protect chef privacy instead of exposing full legal name.
  String get formattedChefName {
    final clean = chefName.trim();
    if (clean.isEmpty) return '';
    final parts = clean.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.length <= 1) return clean;
    final firstName = parts.first;
    final lastInitial = parts.last[0].toUpperCase();
    return '$firstName $lastInitial.';
  }

  /// Returns an approximate location (City, State / Area) similar to Airbnb
  /// to protect chef privacy until an order/purchase is made.
  bool get hasBankLinked => bankAccountNumber.trim().isNotEmpty || stripeAccountId.trim().isNotEmpty;

  String get maskedBankAccount {
    final clean = bankAccountNumber.trim();
    if (clean.isEmpty) return '';
    if (clean.length <= 4) return '•••• ';
    return '•••• ';
  }

  String get maskedRoutingNumber {
    final clean = bankRoutingNumber.trim();
    if (clean.isEmpty) return '';
    if (clean.length <= 4) return '••••• ';
    return '••••• ';
  }

  /// Converts a UTC DateTime to Pacific Time (PST/PDT), the operating timezone
  /// for GoChef kitchens in Los Angeles, California.
  static DateTime getPacificTime([DateTime? utcNow]) {
    final utc = (utcNow ?? DateTime.now().toUtc());
    final year = utc.year;
    // US Daylight Saving Time:
    // Starts second Sunday in March (2:00 AM PST = 10:00 UTC)
    final marchFirst = DateTime.utc(year, 3, 1);
    final dstStartDay = 1 + (7 - marchFirst.weekday) % 7 + 7;
    final dstStart = DateTime.utc(year, 3, dstStartDay, 10);
    // Ends first Sunday in November (2:00 AM PDT = 9:00 UTC)
    final novFirst = DateTime.utc(year, 11, 1);
    final dstEndDay = 1 + (7 - novFirst.weekday) % 7;
    final dstEnd = DateTime.utc(year, 11, dstEndDay, 9);

    final isDst = utc.isAfter(dstStart) && utc.isBefore(dstEnd);
    final offsetHours = isDst ? -7 : -8;
    return utc.add(Duration(hours: offsetHours));
  }

  /// Checks whether the kitchen is open at a specific time (in Pacific Time).
  bool isCurrentlyOpenAt(DateTime targetTime) {
    if (!isOpen) return false;
    final hours = businessHours.trim();
    if (hours.isEmpty) return isOpen;

    try {
      final parts = hours.split(RegExp(r'\s*[-–—]\s*|\s+(?:to|TO|To)\s+'));
      if (parts.length != 2) return isOpen;

      final startMinutes = _parseTimeToMinutes(parts[0]);
      final endMinutes = _parseTimeToMinutes(parts[1]);
      if (startMinutes == null || endMinutes == null) return isOpen;

      final currentMinutes = targetTime.hour * 60 + targetTime.minute;

      if (startMinutes <= endMinutes) {
        // Standard daytime range (e.g., 10:00 AM to 5:00 PM)
        return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
      } else {
        // Overnight range (e.g., 6:00 PM to 2:00 AM)
        return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
      }
    } catch (_) {
      return isOpen;
    }
  }

  /// Checks whether the kitchen is currently open based on both the manual toggle (isOpen)
  /// and the defined business hours in California Pacific Time.
  bool get isCurrentlyOpen => isCurrentlyOpenAt(getPacificTime());

  static int? _parseTimeToMinutes(String timeStr) {
    final clean = timeStr.trim().toUpperCase();
    final match = RegExp(r'(\d{1,2})(?::(\d{2}))?\s*(AM|PM)?').firstMatch(clean);
    if (match == null) return null;

    int hour = int.parse(match.group(1)!);
    int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
    final meridian = match.group(3);

    if (meridian != null) {
      if (meridian == 'PM' && hour < 12) hour += 12;
      if (meridian == 'AM' && hour == 12) hour = 0;
    }

    return hour * 60 + minute;
  }

  String getOpenStatusTextAt(DateTime targetTime) {
    if (!isOpen) return 'Closed';
    return isCurrentlyOpenAt(targetTime) ? 'Open Now' : 'Closed';
  }

  String get openStatusText => getOpenStatusTextAt(getPacificTime());

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
      atmosphereImages: () {
        var raw = json['atmosphere_images'];
        if (raw is String && raw.trim().startsWith('[')) {
          try { raw = jsonDecode(raw); } catch (_) {}
        }
        if (raw is List) {
          return raw.map((e) => ApiService.formatImageUrl(e.toString())).toList();
        }
        return <String>[];
      }(),
      certificates: () {
        var raw = json['certificates'];
        if (raw is String && raw.trim().startsWith('[')) {
          try { raw = jsonDecode(raw); } catch (_) {}
        }
        if (raw is List) {
          return raw.map((e) => ChefCertificate.fromJson(e is Map<String, dynamic> ? e : {})).toList();
        }
        return <ChefCertificate>[];
      }(),
      menuItems: json['menu_items'] != null
          ? (json['menu_items'] as List).map((e) => MenuItemModel.fromJson(e)).toList()
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((e) => ReviewModel.fromJson(e)).toList()
          : null,
      hasPurchased: json['has_purchased'] == true || json['has_purchased']?.toString() == '1',
      bankName: json['bank_name']?.toString() ?? '',
      bankAccountHolder: json['bank_account_holder']?.toString() ?? '',
      bankAccountNumber: json['bank_account_number']?.toString() ?? '',
      bankRoutingNumber: json['bank_routing_number']?.toString() ?? '',
      stripeAccountId: json['stripe_account_id']?.toString() ?? '',
    );
  }
}
