class RolesModel {
  final String status;
  final String message;
  final List<Role> payload;
  final int statusCode;

  RolesModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory RolesModel.fromJson(Map<String, dynamic> json) {
    return RolesModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: (json['payload'] as List<dynamic>?)
              ?.map((item) => Role.fromJson(item as Map<String, dynamic>))
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

class Role {
  final int id;
  final String name;
  final List<String>? permissions;

  Role({
    required this.id,
    required this.name,
    this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      permissions: (json['permissions'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'permissions': permissions,
    };
  }

  @override
  String toString() => 'Role(id: $id, name: $name, permissionCount: ${permissions?.length ?? 0})';
}