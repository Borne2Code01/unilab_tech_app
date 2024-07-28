class PurchaseOrder {
  String? id;
  String customerId;
  DateTime dateOfDelivery;
  String status;
  double amountDue;
  DateTime dateCreated;
  String createdBy;
  DateTime timestamp;
  String userId;
  bool isActive;

  PurchaseOrder({
    this.id,
    required this.customerId,
    required this.dateOfDelivery,
    required this.status,
    required this.amountDue,
    required this.dateCreated,
    required this.createdBy,
    required this.timestamp,
    required this.userId,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'dateOfDelivery': dateOfDelivery.toIso8601String(),
      'status': status,
      'amountDue': amountDue,
      'dateCreated': dateCreated.toIso8601String(),
      'createdBy': createdBy,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory PurchaseOrder.fromMap(Map<String, dynamic> map) {
    return PurchaseOrder(
      id: map['id'].toString(),
      customerId: map['customerId'],
      dateOfDelivery: DateTime.parse(map['dateOfDelivery']),
      status: map['status'],
      amountDue: map['amountDue'],
      dateCreated: DateTime.parse(map['dateCreated']),
      createdBy: map['createdBy'],
      timestamp: DateTime.parse(map['timestamp']),
      userId: map['userId'],
      isActive: map['isActive'] == 1,
    );
  }
}
