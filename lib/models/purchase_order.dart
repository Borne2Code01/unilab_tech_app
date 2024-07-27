class PurchaseOrder {
  final String id;
  final String customerId;
  final DateTime dateOfDelivery;
  final String status;
  final double amountDue;
  final DateTime dateCreated;
  final String createdBy;
  final DateTime timestamp;
  final String userId;
  final bool isActive;

  PurchaseOrder({
    required this.id,
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

  Map<String, dynamic> toJson() {
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

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    return PurchaseOrder(
      id: json['id'],
      customerId: json['customerId'],
      dateOfDelivery: DateTime.parse(json['dateOfDelivery']),
      status: json['status'],
      amountDue: json['amountDue'],
      dateCreated: DateTime.parse(json['dateCreated']),
      createdBy: json['createdBy'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      isActive: json['isActive'] == 1,
    );
  }
}
