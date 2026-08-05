class AddressModel {
  final int id;
  final String label;
  final String address;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.address,
    this.label = 'Home',
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      label: json['label'] ?? 'Home',
      address: json['address'] ?? '',
      isDefault: json['is_default']?.toString() == '1',
    );
  }
}
