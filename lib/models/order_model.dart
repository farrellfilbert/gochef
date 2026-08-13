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
      quantity: json['quantity'] != null ? int.tryParse(json['quantity'].toString()) ?? 1 : 1,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String customerPhone;
  final String customerAvatar;
  final String kitchenId;
  final String kitchenUserId;
  final String kitchenName;
  final String date;
  final String status;
  final double totalAmount;
  final int itemsCount;
  final String avatar;
  final String? notes;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    this.userId = '',
    this.customerName = '',
    this.customerPhone = '',
    this.customerAvatar = '',
    this.kitchenId = '',
    this.kitchenUserId = '',
    required this.kitchenName,
    required this.date,
    required this.status,
    required this.totalAmount,
    required this.itemsCount,
    required this.avatar,
    this.notes,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItemModel> parsedItems = itemsList.map((i) => OrderItemModel.fromJson(i)).toList();
    
    String dateStr = json['date'] ?? '';
    try {
      if (dateStr.contains('T')) {
        final utcDate = DateTime.parse(dateStr);
        final localDate = utcDate.toLocal();
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final month = months[localDate.month - 1];
        final day = localDate.day.toString().padLeft(2, '0');
        final year = localDate.year;
        final hour = localDate.hour.toString().padLeft(2, '0');
        final minute = localDate.minute.toString().padLeft(2, '0');
        dateStr = '$month $day, $year - $hour:$minute';
      }
    } catch (e) {}

    return OrderModel(
      id: json['id'].toString(),
      userId: json['user_id']?.toString() ?? '',
      customerName: json['customer_name'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      customerAvatar: json['customer_avatar'] ?? '',
      kitchenId: json['kitchen_id']?.toString() ?? '',
      kitchenUserId: json['kitchen_user_id']?.toString() ?? '',
      kitchenName: json['kitchen_name'] ?? '',
      date: dateStr,
      status: json['status'] ?? 'Completed',
      totalAmount: json['total_amount'] != null 
          ? double.tryParse(json['total_amount'].toString()) ?? 0.0 
          : (json['totalAmount'] != null ? double.tryParse(json['totalAmount'].toString()) ?? 0.0 : 0.0),
      itemsCount: json['items_count'] != null 
          ? int.tryParse(json['items_count'].toString()) ?? parsedItems.length
          : (json['itemsCount'] != null ? int.tryParse(json['itemsCount'].toString()) ?? parsedItems.length : parsedItems.length),
      avatar: json['avatar'] ?? '',
      notes: json['notes'],
      items: parsedItems,
    );
  }
}
