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
