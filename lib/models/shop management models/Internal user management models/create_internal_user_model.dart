class CreateInternalUserModel {
  final String email;
  final String password;
  final String phone;
  final String name;
  final String adhaarNumber;
  final int roleId;
  final String shopId;

  CreateInternalUserModel({
    required this.email,
    required this.password,
    required this.phone,
    required this.name,
    required this.adhaarNumber,
    required this.roleId,
    required this.shopId,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'phone': phone,
      'name': name,
      'adhaarNumber': adhaarNumber,
      'roleId': roleId,
      'shopId': shopId,
    };
  }
}