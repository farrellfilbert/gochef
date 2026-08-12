class MenuAddonCategoryModel {
  final int id;
  final String name;
  final bool isRequired;
  final bool isMultiple;
  final List<MenuAddonModel> options;

  MenuAddonCategoryModel({
    required this.id,
    required this.name,
    this.isRequired = false,
    this.isMultiple = false,
    this.options = const [],
  });

  factory MenuAddonCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuAddonCategoryModel(
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      name: json['name'] ?? '',
      isRequired: json['is_required'] == 1 || json['is_required'] == true,
      isMultiple: json['is_multiple'] == 1 || json['is_multiple'] == true,
      options: json['options'] != null
          ? (json['options'] as List).map((i) => MenuAddonModel.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'is_required': isRequired,
      'is_multiple': isMultiple,
      'options': options.map((e) => e.toJson()).toList(),
    };
  }
}

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
      id: json['id'] is String ? int.tryParse(json['id']) ?? 0 : (json['id'] ?? 0),
      name: json['name'] ?? '',
      price: json['price'] is String
          ? double.tryParse(json['price']) ?? 0.0
          : (json['price'] ?? 0.0).toDouble(),
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
