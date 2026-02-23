class CreateRoleModel {
  final String roleName;
  final String shopId;
  final List<String> permissions;

  
  CreateRoleModel({
    required this.roleName,
    required this.shopId,
    required this.permissions,
  });

  Map<String, dynamic> toJson() {
    return {
      'roleName': roleName,
      'permissions': permissions,
    };
  }
}