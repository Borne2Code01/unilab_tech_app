class Sku {
  final int? id;
  final String name;
  final String code;
  final double unitPrice;
  final bool isActive;

  Sku({
    this.id,
    required this.name,
    required this.code,
    required this.unitPrice,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'unitPrice': unitPrice,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory Sku.fromMap(Map<String, dynamic> map) {
    return Sku(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      unitPrice: map['unitPrice'],
      isActive: map['isActive'] == 1,
    );
  }
}
