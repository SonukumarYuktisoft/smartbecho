class ShopAddress {
  final int? id;
  final String? label;
  final String? name;
  final String? phone;
  final String? addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final bool? defaultAddress;

  ShopAddress({
    this.id,
    this.label,
    this.name,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.landmark,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.defaultAddress,
  });

  factory ShopAddress.fromJson(Map<String, dynamic> json) {
    return ShopAddress(
      id: json['id'],
      label: json['label'],
      name: json['name'],
      phone: json['phone'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      landmark: json['landmark'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'],
      defaultAddress: json['default'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'name': name,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'default': defaultAddress,
    };
  }
}

class SignupPayload {
  final int? id;
  final String? shopId;
  final String? shopStoreName;
  final String? email;
  final String? password;
  final List<int>? passwordUpdatedAt;
  final ShopAddress? shopAddress;
  final dynamic socialMediaLinks;
  final dynamic images;
  final int? Status;
  final int? status;
  final List<int>? creationDate;
  final String? gstnumber;
  final String? adhaarNumer;

  SignupPayload({
    this.id,
    this.shopId,
    this.shopStoreName,
    this.email,
    this.password,
    this.passwordUpdatedAt,
    this.shopAddress,
    this.socialMediaLinks,
    this.images,
    this.Status,
    this.status,
    this.creationDate,
    this.gstnumber,
    this.adhaarNumer,
  });

  factory SignupPayload.fromJson(Map<String, dynamic> json) {
    return SignupPayload(
      id: json['id'],
      shopId: json['shopId'],
      shopStoreName: json['shopStoreName'],
      email: json['email'],
      password: json['password'],
      passwordUpdatedAt: json['passwordUpdatedAt'] != null 
          ? List<int>.from(json['passwordUpdatedAt']) 
          : null,
      shopAddress: json['shopAddress'] != null 
          ? ShopAddress.fromJson(json['shopAddress']) 
          : null,
      socialMediaLinks: json['socialMediaLinks'],
      images: json['images'],
      Status: json['Status'],
      status: json['status'],
      creationDate: json['creationDate'] != null 
          ? List<int>.from(json['creationDate']) 
          : null,
      gstnumber: json['gstnumber'],
      adhaarNumer: json['adhaarNumer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'shopStoreName': shopStoreName,
      'email': email,
      'password': password,
      'passwordUpdatedAt': passwordUpdatedAt,
      'shopAddress': shopAddress?.toJson(),
      'socialMediaLinks': socialMediaLinks,
      'images': images,
      'Status': Status,
      'status': status,
      'creationDate': creationDate,
      'gstnumber': gstnumber,
      'adhaarNumer': adhaarNumer,
    };
  }
}
class SignupResponse {
  final String? message;
  final SignupPayload? payload;
  final String? error;
  final int? status; // Added status field

  SignupResponse({
    
    this.message,
    this.payload,
    this.error,
   required this.status,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
     
      message: json['message'],
      payload: json['payload'] != null || json['data'] != null
          ? SignupPayload.fromJson(json['payload'] ?? json['data'])
          : null,
      error: json['error'],
      status: json['status'] ?? json['Status'], // Handle both lowercase and uppercase
    );
  }

  Map<String, dynamic> toJson() {
    return {
 
      'message': message,
      'payload': payload?.toJson(),
      'error': error,
      'status': status,
    };
  }

  // Helper method to check if signup was successful
  bool get isSignupSuccessful {
    return ( status == 1) && payload != null;
  }
}




class CreateShopModel {
  final String email;
  final String password;
  final String phone;
  final String adhaarNumber;
  final String shopStoreName;
  final String shopGstNumber;
  final ShopAddressCreate shopAddress;
  final List<SocialMediaLink> socialMediaLinks;

  CreateShopModel({
    required this.email,
    required this.password,
    required this.phone,
    required this.adhaarNumber,
    required this.shopStoreName,
    required this.shopGstNumber,
    required this.shopAddress,
    required this.socialMediaLinks,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'phone': phone,
      'adhaarNumber': adhaarNumber,
      'shopStoreName': shopStoreName,
      'shopGstNumber': shopGstNumber,
      'shopAddress': shopAddress.toJson(),
      'socialMediaLinks': socialMediaLinks.map((e) => e.toJson()).toList(),
    };
  }
}

class ShopAddressCreate {
  final String label;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;

  ShopAddressCreate({
    required this.label,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

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

class SocialMediaLink {
  final String platform;
  final String url;

  SocialMediaLink({
    required this.platform,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'url': url,
    };
  }
}