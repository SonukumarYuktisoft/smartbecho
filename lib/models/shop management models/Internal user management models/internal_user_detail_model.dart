// internal_user_detail_model.dart

class InternalUserDetailResponse {
  final String status;
  final String message;
  final InternalUserDetail payload;
  final int statusCode;

  InternalUserDetailResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory InternalUserDetailResponse.fromJson(Map<String, dynamic> json) {
    return InternalUserDetailResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: InternalUserDetail.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class InternalUserDetail {
  final int id;
  final String name;
  final String email;
  final String? pan;
  final String phone;
  final String? lastLoginTime;
  final String? lastActivityTime;
  final String? referralCode;
  final UserAddressDetail? userAddress;
  final List<UserShop> userShops;
  final String? profilePhotoUrl;
  final int status;
  final bool notifyByEmail;
  final bool notifyBySMS;
  final bool notifyByWhatsApp;
  final String? adhaarNumber;
  final String creationDate;
  final int? roleId; // Added roleId
  final String? roleName; // Added roleName

  InternalUserDetail({
    required this.id,
    required this.name,
    required this.email,
    this.pan,
    required this.phone,
    this.lastLoginTime,
    this.lastActivityTime,
    this.referralCode,
    this.userAddress,
    required this.userShops,
    this.profilePhotoUrl,
    required this.status,
    required this.notifyByEmail,
    required this.notifyBySMS,
    required this.notifyByWhatsApp,
    this.adhaarNumber,
    required this.creationDate,
    this.roleId,
    this.roleName,
  });

  factory InternalUserDetail.fromJson(Map<String, dynamic> json) {
    return InternalUserDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      pan: json['pan'],
      phone: json['phone'] ?? '',
      lastLoginTime: json['lastLoginTime'],
      lastActivityTime: json['lastActivityTime'],
      referralCode: json['referralCode'],
      userAddress: json['userAddress'] != null
          ? UserAddressDetail.fromJson(json['userAddress'])
          : null,
      userShops: (json['userShops'] as List?)
              ?.map((shop) => UserShop.fromJson(shop))
              .toList() ??
          [],
      profilePhotoUrl: json['profilePhotoUrl'],
      status: json['status'] ?? 1,
      notifyByEmail: json['notifyByEmail'] ?? false,
      notifyBySMS: json['notifyBySMS'] ?? false,
      notifyByWhatsApp: json['notifyByWhatsApp'] ?? false,
      adhaarNumber: json['adhaarNumber'],
      creationDate: json['creationDate'] ?? '',
      roleId: json['roleId'],
      roleName: json['roleName'],
    );
  }
}

class UserAddressDetail {
  final int id;
  final String label;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;

  UserAddressDetail({
    required this.id,
    required this.label,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  factory UserAddressDetail.fromJson(Map<String, dynamic> json) {
    return UserAddressDetail(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}

class UserShop {
  final int id;
  final Shop shop;
  final bool isOwner;
  final bool isActive;
  final String joinedAt;

  UserShop({
    required this.id,
    required this.shop,
    required this.isOwner,
    required this.isActive,
    required this.joinedAt,
  });

  factory UserShop.fromJson(Map<String, dynamic> json) {
    return UserShop(
      id: json['id'] ?? 0,
      shop: Shop.fromJson(json['shop'] ?? {}),
      isOwner: json['isOwner'] ?? false,
      isActive: json['isActive'] ?? true,
      joinedAt: json['joinedAt'] ?? '',
    );
  }
}

class Shop {
  final int id;
  final String shopId;
  final String shopStoreName;
  final ShopAddress? shopAddress;
  final List<dynamic> socialMediaLinks;
  final List<dynamic> images;
  final String? profilePhotoUrl;
  final String creationDate;
  final String createdAt;
  final String updatedAt;
  final bool isActive;
  final String? gstnumber;

  Shop({
    required this.id,
    required this.shopId,
    required this.shopStoreName,
    this.shopAddress,
    required this.socialMediaLinks,
    required this.images,
    this.profilePhotoUrl,
    required this.creationDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.gstnumber,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? 0,
      shopId: json['shopId'] ?? '',
      shopStoreName: json['shopStoreName'] ?? '',
      shopAddress: json['shopAddress'] != null
          ? ShopAddress.fromJson(json['shopAddress'])
          : null,
      socialMediaLinks: json['socialMediaLinks'] ?? [],
      images: json['images'] ?? [],
      profilePhotoUrl: json['profilePhotoUrl'],
      creationDate: json['creationDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isActive: json['isActive'] ?? true,
      gstnumber: json['gstnumber'],
    );
  }
}

class ShopAddress {
  final int id;
  final String label;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;

  ShopAddress({
    required this.id,
    required this.label,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  factory ShopAddress.fromJson(Map<String, dynamic> json) {
    return ShopAddress(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}