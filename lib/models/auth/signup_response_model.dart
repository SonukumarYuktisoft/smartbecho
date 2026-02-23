class SignupResponseModel {
  final String status;
  final String message;
  final SignupPayload? payload;
  final int statusCode;

  SignupResponseModel({
    required this.status,
    required this.message,
    this.payload,
    required this.statusCode,
  });

  factory SignupResponseModel.fromJson(Map<String, dynamic> json) {
    return SignupResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: json['payload'] != null ? SignupPayload.fromJson(json['payload']) : null,
      statusCode: json['statusCode'] ?? 0,
    );
  }

  bool get isSuccess => status.toUpperCase() == 'SUCCESS' && statusCode == 200;
}

class SignupPayload {
  final User user;
  final Shop shop;
  final String accessToken;
  final String refreshToken;
  final String message;

  SignupPayload({
    required this.user,
    required this.shop,
    required this.accessToken,
    required this.refreshToken,
    required this.message,
  });

  factory SignupPayload.fromJson(Map<String, dynamic> json) {
    return SignupPayload(
      user: User.fromJson(json['user'] ?? {}),
      shop: Shop.fromJson(json['shop'] ?? {}),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

class User {
  final int id;
  final String? name;
  final String email;
  final String? pan;
  final String phone;
  final String? lastLoginTime;
  final String? lastActivityTime;
  final String? referralCode;
  final dynamic userAddress;
  final dynamic userShops;
  final String? profilePhotoUrl;
  final int status;
  final bool notifyByEmail;
  final bool notifyBySMS;
  final bool notifyByWhatsApp;
  final String adhaarNumber;
  final String creationDate;

  User({
    required this.id,
    this.name,
    required this.email,
    this.pan,
    required this.phone,
    this.lastLoginTime,
    this.lastActivityTime,
    this.referralCode,
    this.userAddress,
    this.userShops,
    this.profilePhotoUrl,
    required this.status,
    required this.notifyByEmail,
    required this.notifyBySMS,
    required this.notifyByWhatsApp,
    required this.adhaarNumber,
    required this.creationDate,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'] ?? '',
      pan: json['pan'],
      phone: json['phone'] ?? '',
      lastLoginTime: json['lastLoginTime'],
      lastActivityTime: json['lastActivityTime'],
      referralCode: json['referralCode'],
      userAddress: json['userAddress'],
      userShops: json['userShops'],
      profilePhotoUrl: json['profilePhotoUrl'],
      status: json['Status'] ?? json['status'] ?? 0,
      notifyByEmail: json['notifyByEmail'] ?? false,
      notifyBySMS: json['notifyBySMS'] ?? false,
      notifyByWhatsApp: json['notifyByWhatsApp'] ?? false,
      adhaarNumber: json['adhaarNumber'] ?? '',
      creationDate: json['creationDate'] ?? '',
    );
  }
}

class Shop {
  final int id;
  final String shopId;
  final String shopStoreName;
  final ShopAddress shopAddress;
  final dynamic socialMediaLinks;
  final dynamic images;
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
    this.socialMediaLinks,
    this.images,
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
      socialMediaLinks: json['socialMediaLinks'],
      images: json['images'],
      profilePhotoUrl: json['profilePhotoUrl'],
      creationDate: json['creationDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isActive: json['isActive'] ?? false,
      gstnumber: json['gstnumber'],
    );
  }
}

class ShopAddress {
  final int id;
  final String? label;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final String pincode;

  ShopAddress({
    required this.id,
    this.label,
    required this.addressLine1,
    this.addressLine2,
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
      addressLine2: json['addressLine2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? '',
    );
  }
}

// Request Model
class SignupRequestModel {
  final String email;
  final String password;
  final String phone;
  final String adhaarNumber;
  final String shopStoreName;
  final String? shopGstNumber;
  final ShopAddressRequest shopAddress;

  SignupRequestModel({
    required this.email,
    required this.password,
    required this.phone,
    required this.adhaarNumber,
    required this.shopStoreName,
    this.shopGstNumber,
    required this.shopAddress,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'phone': phone,
      'adhaarNumber': adhaarNumber,
      'shopStoreName': shopStoreName,
      'shopAddress': shopAddress.toJson(),
    };

    if (shopGstNumber != null && shopGstNumber!.isNotEmpty) {
      data['shopGstNumber'] = shopGstNumber;
    }

    return data;
  }
}

class ShopAddressRequest {
  final String label;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;

  ShopAddressRequest({
    required this.label,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'label': label,
      'addressLine1': addressLine1,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };

    if (addressLine2 != null && addressLine2!.isNotEmpty) {
      data['addressLine2'] = addressLine2;
    }

    return data;
  }
}