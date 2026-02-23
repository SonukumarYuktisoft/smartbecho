class GstResponseModel {
  final bool flag;
  final String message;
  final GstData? data;

  GstResponseModel({
    required this.flag,
    required this.message,
    this.data,
  });

  factory GstResponseModel.fromJson(Map<String, dynamic> json) {
    return GstResponseModel(
      flag: json['flag'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? GstData.fromJson(json['data']) : null,
    );
  }
}

class GstData {
  final String lgnm; // Legal name
  final String tradeNam; // Trade name
  final String sts; // Status
  final PrincipalAddress? pradr; // Principal address
  final String ctb; // Constitution of business
  final String rgdt; // Registration date
  final String gstin;

  GstData({
    required this.lgnm,
    required this.tradeNam,
    required this.sts,
    this.pradr,
    required this.ctb,
    required this.rgdt,
    required this.gstin,
  });

  factory GstData.fromJson(Map<String, dynamic> json) {
    return GstData(
      lgnm: json['lgnm'] ?? '',
      tradeNam: json['tradeNam'] ?? '',
      sts: json['sts'] ?? '',
      pradr: json['pradr'] != null 
          ? PrincipalAddress.fromJson(json['pradr']) 
          : null,
      ctb: json['ctb'] ?? '',
      rgdt: json['rgdt'] ?? '',
      gstin: json['gstin'] ?? '',
    );
  }
}

class PrincipalAddress {
  final String adr; // Full address string
  final AddressDetails? addr; // Detailed address

  PrincipalAddress({
    required this.adr,
    this.addr,
  });

  factory PrincipalAddress.fromJson(Map<String, dynamic> json) {
    return PrincipalAddress(
      adr: json['adr'] ?? '',
      addr: json['addr'] != null 
          ? AddressDetails.fromJson(json['addr']) 
          : null,
    );
  }
}

class AddressDetails {
  final String flno; // Floor number
  final String bnm; // Building name
  final String st; // Street
  final String loc; // Location
  final String bno; // Building number
  final String dst; // District
  final String city;
  final String stcd; // State code
  final String pncd; // Pincode

  AddressDetails({
    required this.flno,
    required this.bnm,
    required this.st,
    required this.loc,
    required this.bno,
    required this.dst,
    required this.city,
    required this.stcd,
    required this.pncd,
  });

  factory AddressDetails.fromJson(Map<String, dynamic> json) {
    return AddressDetails(
      flno: json['flno'] ?? '',
      bnm: json['bnm'] ?? '',
      st: json['st'] ?? '',
      loc: json['loc'] ?? '',
      bno: json['bno']?.toString() ?? '',
      dst: json['dst'] ?? '',
      city: json['city'] ?? '',
      stcd: json['stcd'] ?? '',
      pncd: json['pncd'] ?? '',
    );
  }
}