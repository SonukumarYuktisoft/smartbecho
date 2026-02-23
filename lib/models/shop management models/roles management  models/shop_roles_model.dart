class ShopRolesModel {
  final String status;
  final String message;
  final List<ShopRole> payload;
  final int statusCode;

  ShopRolesModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory ShopRolesModel.fromJson(Map<String, dynamic> json) {
    return ShopRolesModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: (json['payload'] as List<dynamic>?)
              ?.map((item) => ShopRole.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload.map((item) => item.toJson()).toList(),
      'statusCode': statusCode,
    };
  }
}

class ShopRole {
  final String name;
  final bool isGlobal;
  final int id;

  ShopRole({
    required this.name,
    required this.isGlobal,
    required this.id,
  });

  factory ShopRole.fromJson(Map<String, dynamic> json) {
    return ShopRole(
      name: json['name'] ?? '',
      isGlobal: json['isGlobal'] ?? false,
      id: json['id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isGlobal': isGlobal,
      'id': id,
    };
  }

  @override
  String toString() => 'ShopRole(id: $id, name: $name, isGlobal: $isGlobal)';
}