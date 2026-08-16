import '../services/api_service.dart';

class ReviewModel {
  final int id;
  final int rating;
  final String comment;
  final String userName;
  final String userAvatar;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.rating,
    this.comment = '',
    this.userName = '',
    this.userAvatar = '',
    this.createdAt = '',
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      rating: int.tryParse(json['rating']?.toString() ?? '5') ?? 5,
      comment: json['comment'] ?? '',
      userName: json['user_name'] ?? '',
      userAvatar: ApiService.formatImageUrl(json['user_avatar'] ?? json['avatar']),
      createdAt: json['created_at'] ?? '',
    );
  }
}
