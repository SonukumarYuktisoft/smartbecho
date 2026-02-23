class InternalUsersModel {
  final String status;
  final String message;
  final List<InternalUser> payload;
  final int statusCode;

  InternalUsersModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory InternalUsersModel.fromJson(Map<String, dynamic> json) {
    return InternalUsersModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: (json['payload'] as List<dynamic>?)
              ?.map((e) => InternalUser.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload.map((e) => e.toJson()).toList(),
      'statusCode': statusCode,
    };
  }
}

class InternalUser {
  final int id;
  final String email;
  final String phone;
  final String name;
  final String? adhaarNumber;
  final int roleId;
  final String? roleName;
  final int shopId;
  final String? profilePhotoUrl;
  final String? gstNumber;
  final int? status;
  final bool? notifyByEmail;
  final bool? notifyBySms;
  final bool? notifyByWhatsApp;
  final UserAddress? userAddress;
  final String createdAt;
  final String updatedAt;

  InternalUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    this.adhaarNumber,
    required this.roleId,
    this.roleName,
    required this.shopId,
    this.profilePhotoUrl,
    this.gstNumber,
    this.status,
    this.notifyByEmail,
    this.notifyBySms,
    this.notifyByWhatsApp,
    this.userAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InternalUser.fromJson(Map<String, dynamic> json) {
    return InternalUser(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      adhaarNumber: json['adhaarNumber'],
      roleId: json['roleId'] ?? 0,
      roleName: json['roleName'],
      shopId: json['shopId'] ?? 0,
      profilePhotoUrl: json['profilePhotoUrl'],
      gstNumber: json['gstNumber'],
      status: json['status'],
      notifyByEmail: json['notifyByEmail'],
      notifyBySms: json['notifyBySms'],
      notifyByWhatsApp: json['notifyByWhatsApp'],
      userAddress: json['userAddress'] != null
          ? UserAddress.fromJson(json['userAddress'])
          : null,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'adhaarNumber': adhaarNumber,
      'roleId': roleId,
      'roleName': roleName,
      'shopId': shopId,
      'profilePhotoUrl': profilePhotoUrl,
      'gstNumber': gstNumber,
      'status': status,
      'notifyByEmail': notifyByEmail,
      'notifyBySms': notifyBySms,
      'notifyByWhatsApp': notifyByWhatsApp,
      'userAddress': userAddress?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class UserAddress {
  final String label;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;

  UserAddress({
    required this.label,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      label: json['label'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
  }
}