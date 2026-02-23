class UpdateInternalUserModel {
  final String name;
  final String email;
  
  final String phone;
  final String adhaarNumber;
  final String? pan;
  final int? status;
  final bool notifyByEmail;
  final bool notifyBySms;
  final bool notifyByWhatsApp;
  final UserAddressUpdate userAddress;

  UpdateInternalUserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.adhaarNumber,
    this.pan,
    this.status,
    required this.notifyByEmail,
    required this.notifyBySms,
    required this.notifyByWhatsApp,
    required this.userAddress, required int roleId,
  });

  Map<String, dynamic> toJson() {
    return {
       'name': name,
      'email': email,
      "password": "",
      'phone': phone,
      'AdhaarNumber': adhaarNumber,
      'pan': pan,
      'Status': status,
      'notifyByEmail': notifyByEmail,
      'notifyBySms': notifyBySms,
      'notifyByWhatsApp': notifyByWhatsApp,
      'userAddress': userAddress.toJson(),
    };
  }
}

class UserAddressUpdate {
  final String label;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;

  UserAddressUpdate({
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