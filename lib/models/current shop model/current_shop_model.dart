class CurrentShopModel {
  final String status;
  final String message;
  final ShopPayload? payload;
  final int statusCode;

  CurrentShopModel({
    required this.status,
    required this.message,
    this.payload,
    required this.statusCode,
  });

  factory CurrentShopModel.fromJson(Map<String, dynamic> json) {
    return CurrentShopModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: json['payload'] != null 
          ? ShopPayload.fromJson(json['payload']) 
          : null,
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload?.toJson(),
      'statusCode': statusCode,
    };
  }

  // Helper getter to check if request was successful
  bool get isSuccess => status.toUpperCase() == 'SUCCESS' && statusCode == 200;
}

class ShopPayload {
  final int id;
  final String shopId;
  final String shopStoreName;
  final ShopAddress? shopAddress;
  final List<SocialMediaLink> socialMediaLinks;
  final List<String> images;
  final String? profilePhotoUrl;
  final String creationDate;
  final String createdAt;
  final String updatedAt;
  final bool isActive;
  final String? gstnumber;

  ShopPayload({
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

  factory ShopPayload.fromJson(Map<String, dynamic> json) {
    return ShopPayload(
      id: json['id'] ?? 0,
      shopId: json['shopId'] ?? '',
      shopStoreName: json['shopStoreName'] ?? '',
      shopAddress: json['shopAddress'] != null
          ? ShopAddress.fromJson(json['shopAddress'])
          : null,
      socialMediaLinks: (json['socialMediaLinks'] as List?)
              ?.map((e) => SocialMediaLink.fromJson(e))
              .toList() ??
          [],
      images: (json['images'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
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
      'shopAddress': shopAddress?.toJson(),
      'socialMediaLinks': socialMediaLinks.map((e) => e.toJson()).toList(),
      'images': images,
      'profilePhotoUrl': profilePhotoUrl,
      'creationDate': creationDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'gstnumber': gstnumber,
    };
  }

  // Helper getters
  String get displayName => shopStoreName;
  String get displayId => shopId;
  bool get hasProfilePhoto => profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty;
  bool get hasGst => gstnumber != null && gstnumber!.isNotEmpty;
  String get hasGstNumber => gstnumber ?? '';
  
  // Format creation date
  String get formattedCreationDate {
    try {
      final date = DateTime.parse(creationDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return creationDate;
    }
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
  
  // Helper method to get full address
  String get fullAddress {
    List<String> parts = [];
    
    if (addressLine1.isNotEmpty) parts.add(addressLine1);
    if (addressLine2.isNotEmpty) parts.add(addressLine2);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (country.isNotEmpty) parts.add(country);
    if (pincode.isNotEmpty) parts.add(pincode);
    
    return parts.join(', ');
  }

  // Short address (without country)
  String get shortAddress {
    List<String> parts = [];
    
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (pincode.isNotEmpty) parts.add(pincode);
    
    return parts.join(', ');
  }
}

class SocialMediaLink {
  final String platform;
  final String url;

  SocialMediaLink({
    required this.platform,
    required this.url,
  });

  factory SocialMediaLink.fromJson(Map<String, dynamic> json) {
    return SocialMediaLink(
      platform: json['platform'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'url': url,
    };
  }
}
