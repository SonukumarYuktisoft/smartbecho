class MyShopsModel {
  final String status;
  final String message;
  final List<Shop> payload;
  final int statusCode;

  MyShopsModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory MyShopsModel.fromJson(Map<String, dynamic> json) {
    return MyShopsModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: (json['payload'] as List<dynamic>?)
              ?.map((e) => Shop.fromJson(e as Map<String, dynamic>))
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

class Shop {
  final int id;
  final String shopId;
  final String shopStoreName;
  final ShopAddress shopAddress;
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

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? 0,
      shopId: json['shopId'] ?? '',
      shopStoreName: json['shopStoreName'] ?? '',
      shopAddress: ShopAddress.fromJson(json['shopAddress'] ?? {}),
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

class ShopAddress {
  final int id;
  final String? label;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;

  ShopAddress({
    required this.id,
    this.label,
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