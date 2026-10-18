import '../services/api_service.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final String? role;
  final String? kitchenId;
  final String? kitchenName;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    this.role,
    this.kitchenId,
    this.kitchenName,
  });

  String get effectiveAvatar {
    if (avatar.trim().isNotEmpty) return avatar.trim();
    final encoded = Uri.encodeComponent(name.trim().isNotEmpty ? name.trim() : 'Chef');
    return 'https://ui-avatars.com/api/?name=$encoded&background=E53935&color=fff&size=200';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: ApiService.formatImageUrl(json['avatar']),
      role: json['role']?.toString(),
      kitchenId: json['kitchen_id']?.toString(),
      kitchenName: json['kitchen_name']?.toString(),
    );
  }
}
