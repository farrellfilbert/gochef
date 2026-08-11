class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatar;
  final String? role;
  final String? kitchenId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    this.role,
    this.kitchenId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'] ?? '',
      role: json['role']?.toString(),
      kitchenId: json['kitchen_id']?.toString(),
    );
  }
}
