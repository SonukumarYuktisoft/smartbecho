// models/profile/user_profile_model.dart
class ProfileResponse {
  final String status;
  final String message;
  final UserProfile payload;
  final int statusCode;

  ProfileResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: UserProfile.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? lastLoginTime;
  final String? lastActivityTime;
  final String? referralCode;
  final UserAddress? userAddress;
  final List<UserShop> userShops;
  final String? profilePhotoUrl;
  final int status;
  final String? creationDate;
  final String? gstnumber;
  final String? adhaarNumber;
  final bool notifyByEmail;
  final bool notifyBySMS;
  final bool notifyByWhatsApp;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.lastLoginTime,
    this.lastActivityTime,
    this.referralCode,
    this.userAddress,
    required this.userShops,
    this.profilePhotoUrl,
    required this.status,
    this.creationDate,
    this.gstnumber,
    this.adhaarNumber,
    this.notifyByEmail = false,
    this.notifyBySMS = false,
    this.notifyByWhatsApp = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      lastLoginTime: json['lastLoginTime'],
      lastActivityTime: json['lastActivityTime'],
      referralCode: json['referralCode'],
      userAddress: json['userAddress'] != null 
          ? UserAddress.fromJson(json['userAddress']) 
          : null,
      userShops: (json['userShops'] as List? ?? [])
          .map((item) => UserShop.fromJson(item))
          .toList(),
      profilePhotoUrl: json['profilePhotoUrl'],
      status: json['status'] ?? json['Status'] ?? 0,
      creationDate: json['creationDate'],
      gstnumber: json['gstnumber'],
      adhaarNumber: json['adhaarNumber'],
      notifyByEmail: json['notifyByEmail'] ?? false,
      notifyBySMS: json['notifyBySMS'] ?? false,
      notifyByWhatsApp: json['notifyByWhatsApp'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'lastLoginTime': lastLoginTime,
      'lastActivityTime': lastActivityTime,
      'referralCode': referralCode,
      'userAddress': userAddress?.toJson(),
      'profilePhotoUrl': profilePhotoUrl,
      'Status': status,
      'notifyByEmail': notifyByEmail,
      'notifyBySMS': notifyBySMS,
      'notifyByWhatsApp': notifyByWhatsApp,
      'gstnumber': gstnumber,
      'adhaarNumber': adhaarNumber,
      'creationDate': creationDate,
      'status': status,
    };
  }

  // Helper method to get the primary/owner shop
  Shop? get primaryShop {
    try {
      return userShops.firstWhere((userShop) => userShop.isOwner).shop;
    } catch (e) {
      return userShops.isNotEmpty ? userShops.first.shop : null;
    }
  }

  // Helper method to get all active shops
  List<Shop> get activeShops {
    return userShops
        .where((userShop) => userShop.isActive)
        .map((userShop) => userShop.shop)
        .toList();
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

class Shop {
  final int id;
  final String shopId;
  final String shopStoreName;
  final ShopAddress? shopAddress;
  final List<SocialMediaLink> socialMediaLinks;
  final List<ShopImage> images;
  final String? profilePhotoUrl;
  final String? creationDate;
  final String? createdAt;
  final String? updatedAt;
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
    this.creationDate,
    this.createdAt,
    this.updatedAt,
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
      socialMediaLinks: (json['socialMediaLinks'] as List? ?? [])
          .map((item) => SocialMediaLink.fromJson(item))
          .toList(),
      images: (json['images'] as List? ?? [])
          .map((item) => ShopImage.fromJson(item))
          .toList(),
      profilePhotoUrl: json['profilePhotoUrl'],
      creationDate: json['creationDate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isActive: json['isActive'] ?? false,
      gstnumber: json['gstnumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'shopStoreName': shopStoreName,
      'shopAddress': shopAddress?.toJson(),
      'socialMediaLinks': socialMediaLinks.map((link) => link.toJson()).toList(),
      'images': images.map((img) => img.toJson()).toList(),
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
  final String? addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final String country;

  ShopAddress({
    required this.id,
    this.label,
    this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  factory ShopAddress.fromJson(Map<String, dynamic> json) {
    return ShopAddress(
      id: json['id'] ?? 0,
      label: json['label'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      landmark: json['landmark'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode']?.toString() ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
    };
  }
}

class UserAddress {
  final int id;
  final String? label;
  final String? addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final bool? defaultAddress;

  UserAddress({
    required this.id,
    this.label,
    this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    this.defaultAddress,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['id'] ?? 0,
      label: json['label'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      landmark: json['landmark'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode']?.toString() ?? '',
      country: json['country'] ?? '',
      defaultAddress: json['default'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'default': defaultAddress,
    };
  }
}

class SocialMediaLink {
  final int id;
  final String platform;
  final String url;

  SocialMediaLink({
    required this.id,
    required this.platform,
    required this.url,
  });

  factory SocialMediaLink.fromJson(Map<String, dynamic> json) {
    return SocialMediaLink(
      id: json['id'] ?? 0,
      platform: json['platform'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'url': url,
    };
  }
}

class ShopImage {
  final int id;
  final String imageUrl;

  ShopImage({
    required this.id,
    required this.imageUrl,
  });

  factory ShopImage.fromJson(Map<String, dynamic> json) {
    return ShopImage(
      id: json['id'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
    };
  }
}