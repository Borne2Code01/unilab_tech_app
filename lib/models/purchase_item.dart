class PurchaseItem {
  String id;
  String purchaseOrderId;
  String skuId;
  int quantity;
  double price;
  DateTime timestamp;
  String userId;

  PurchaseItem({
    required this.id,
    required this.purchaseOrderId,
    required this.skuId,
    required this.quantity,
    required this.price,
    required this.timestamp,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaseOrderId': purchaseOrderId,
      'skuId': skuId,
      'quantity': quantity,
      'price': price,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'],
      purchaseOrderId: json['purchaseOrderId'],
      skuId: json['skuId'],
      quantity: json['quantity'],
      price: json['price'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
    );
  }
}
