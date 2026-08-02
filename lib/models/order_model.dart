class OrderItemModel {
  final String name;
  final String options;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.name,
    required this.options,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] ?? '',
      options: json['options'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String kitchenName;
  final String date;
  final String status;
  final double totalAmount;
  final int itemsCount;
  final String avatar;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.kitchenName,
    required this.date,
    required this.status,
    required this.totalAmount,
    required this.itemsCount,
    required this.avatar,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItemModel> parsedItems = itemsList.map((i) => OrderItemModel.fromJson(i)).toList();
    
    return OrderModel(
      id: json['id']?.toString() ?? '',
      kitchenName: json['kitchenName'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'Completed',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      itemsCount: json['itemsCount'] ?? parsedItems.length,
      avatar: json['avatar'] ?? '',
      items: parsedItems,
    );
  }
}
