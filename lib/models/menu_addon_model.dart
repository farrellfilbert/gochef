class MenuAddonModel {
  final int id;
  final String name;
  final double price;

  MenuAddonModel({
    required this.id,
    required this.name,
    this.price = 0.0,
  });

  factory MenuAddonModel.fromJson(Map<String, dynamic> json) {
    return MenuAddonModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
    };
  }
}
