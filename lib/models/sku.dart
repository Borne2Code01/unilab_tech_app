class Sku {
  final String id;
  final String name;
  final String code;
  final double unitPrice;
  final bool isActive;

  Sku({
    required this.id,
    required this.name,
    required this.code,
    required this.unitPrice,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'unitPrice': unitPrice,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Sku.fromJson(Map<String, dynamic> json) {
    return Sku(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      unitPrice: json['unitPrice'],
      isActive: json['isActive'] == 1,
    );
  }
}
