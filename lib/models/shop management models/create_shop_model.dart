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