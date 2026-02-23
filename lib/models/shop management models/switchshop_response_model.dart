class SwitchShopResponseModel {
  final String status;
  final String message;
  final SwitchShopPayload payload;
  final int statusCode;

  SwitchShopResponseModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory SwitchShopResponseModel.fromJson(Map<String, dynamic> json) {
    return SwitchShopResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: SwitchShopPayload.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload.toJson(),
      'statusCode': statusCode,
    };
  }
}

class SwitchShopPayload {
  final UserShop userShop;
  final String accessToken;
  final String refreshToken;

  SwitchShopPayload({
    required this.userShop,
    required this.accessToken,
    required this.refreshToken,
  });

  factory SwitchShopPayload.fromJson(Map<String, dynamic> json) {
    return SwitchShopPayload(
      userShop: UserShop.fromJson(json['userShop'] ?? {}),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userShop': userShop.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }
}

class UserShop {
  final int id;
  final ShopDetails shop;
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
      shop: ShopDetails.fromJson(json['shop'] ?? {}),
      isOwner: json['isOwner'] ?? false,
      isActive: json['isActive'] ?? false,
      joinedAt: json['joinedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop': shop.toJson(),
      'isOwner': isOwner,
      'isActive': isActive,
      'joinedAt': joinedAt,
    };
  }
}

class ShopDetails {
  final int id;
  final String shopId;
  final String shopStoreName;
  final ShopAddressDetails shopAddress;
  final List<dynamic> socialMediaLinks;
  final List<dynamic> images;
  final String? profilePhotoUrl;
  final String creationDate;
  final String createdAt;
  final String updatedAt;
  final bool isActive;
  final String? gstnumber;

  ShopDetails({
    required this.id,
    required this.shopId,
    required this.shopStoreName,
    required this.shopAddress,
    required this.socialMediaLinks,
    required this.images,
    this.profilePhotoUrl,
    required this.creationDate,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    this.gstnumber,
  });

  factory ShopDetails.fromJson(Map<String, dynamic> json) {
    return ShopDetails(
      id: json['id'] ?? 0,
      shopId: json['shopId'] ?? '',
      shopStoreName: json['shopStoreName'] ?? '',
      shopAddress: ShopAddressDetails.fromJson(json['shopAddress'] ?? {}),
      socialMediaLinks: json['socialMediaLinks'] ?? [],
      images: json['images'] ?? [],
      profilePhotoUrl: json['profilePhotoUrl'],
      creationDate: json['creationDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isActive: json['isActive'] ?? false,
      gstnumber: json['gstnumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'shopStoreName': shopStoreName,
      'shopAddress': shopAddress.toJson(),
      'socialMediaLinks': socialMediaLinks,
      'images': images,
      'profilePhotoUrl': profilePhotoUrl,
      'creationDate': creationDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'gstnumber': gstnumber,
    };
  }
}

class ShopAddressDetails {
  final int id;
  final String? label;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;

  ShopAddressDetails({
    required this.id,
    this.label,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
  });

  factory ShopAddressDetails.fromJson(Map<String, dynamic> json) {
    return ShopAddressDetails(
      id: json['id'] ?? 0,
      label: json['label'],
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
    };
  }
}