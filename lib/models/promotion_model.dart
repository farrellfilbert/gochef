class PromotionModel {
  final int id;
  final String title;
  final String subtitle;
  final String image;
  final int discountPercent;
  final String code;

  PromotionModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.image = '',
    this.discountPercent = 0,
    this.code = '',
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: json['image'] ?? '',
      discountPercent: int.tryParse(json['discount_percent']?.toString() ?? '0') ?? 0,
      code: json['code'] ?? '',
    );
  }
}
