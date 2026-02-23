class ShopSettingsModel {
  final String? id;
  final String? shopId;
  final String? invoiceTemplateNo;
  final int? lowStockQty;
  final int? criticalStockQty;
  final bool? qrCodeScannerEnabled;
  final bool? upiPaymentEnabled;
  final bool? stampEnabled;
  final bool? signatureEnabled;
  final String? shopStampImageUrl;
  final String? shopSignatureImageUrl;
  final String? upiId;
  final String? scannerImageUrl;
  final bool? isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  ShopSettingsModel({
    this.id,
    this.shopId,
    this.invoiceTemplateNo,
    this.lowStockQty,
    this.criticalStockQty,
    this.qrCodeScannerEnabled,
    this.upiPaymentEnabled,
    this.stampEnabled,
    this.signatureEnabled,
    this.shopStampImageUrl,
    this.shopSignatureImageUrl,
    this.upiId,
    this.scannerImageUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory ShopSettingsModel.fromJson(Map<String, dynamic> json) {
    return ShopSettingsModel(
      id: json['id']?.toString(),
      shopId: json['shopId']?.toString(),
      invoiceTemplateNo: json['invoiceTemplateNo']?.toString(),
      lowStockQty: json['lowStockQty'] != null 
          ? int.tryParse(json['lowStockQty'].toString()) 
          : null,
      criticalStockQty: json['criticalStockQty'] != null
          ? int.tryParse(json['criticalStockQty'].toString())
          : null,
      qrCodeScannerEnabled: json['qrCodeScannerEnabled'],
      upiPaymentEnabled: json['upiPaymentEnabled'],
      stampEnabled: json['stampEnabled'],
      signatureEnabled: json['signatureEnabled'],
      shopStampImageUrl: json['shopStampImageUrl']?.toString(),
      shopSignatureImageUrl: json['shopSignatureImageUrl']?.toString(),
      upiId: json['upiId']?.toString(),
      scannerImageUrl: json['scannerImageUrl']?.toString(),
      isActive: json['isActive'],
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      createdBy: json['createdBy']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'invoiceTemplateNo': invoiceTemplateNo,
      'lowStockQty': lowStockQty,
      'criticalStockQty': criticalStockQty,
      'qrCodeScannerEnabled': qrCodeScannerEnabled,
      'upiPaymentEnabled': upiPaymentEnabled,
      'stampEnabled': stampEnabled,
      'signatureEnabled': signatureEnabled,
      'shopStampImageUrl': shopStampImageUrl,
      'shopSignatureImageUrl': shopSignatureImageUrl,
      'upiId': upiId,
      'scannerImageUrl': scannerImageUrl,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  ShopSettingsModel copyWith({
    String? id,
    String? shopId,
    String? invoiceTemplateNo,
    int? lowStockQty,
    int? criticalStockQty,
    bool? qrCodeScannerEnabled,
    bool? upiPaymentEnabled,
    bool? stampEnabled,
    bool? signatureEnabled,
    String? shopStampImageUrl,
    String? shopSignatureImageUrl,
    String? upiId,
    String? scannerImageUrl,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return ShopSettingsModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      invoiceTemplateNo: invoiceTemplateNo ?? this.invoiceTemplateNo,
      lowStockQty: lowStockQty ?? this.lowStockQty,
      criticalStockQty: criticalStockQty ?? this.criticalStockQty,
      qrCodeScannerEnabled: qrCodeScannerEnabled ?? this.qrCodeScannerEnabled,
      upiPaymentEnabled: upiPaymentEnabled ?? this.upiPaymentEnabled,
      stampEnabled: stampEnabled ?? this.stampEnabled,
      signatureEnabled: signatureEnabled ?? this.signatureEnabled,
      shopStampImageUrl: shopStampImageUrl ?? this.shopStampImageUrl,
      shopSignatureImageUrl: shopSignatureImageUrl ?? this.shopSignatureImageUrl,
      upiId: upiId ?? this.upiId,
      scannerImageUrl: scannerImageUrl ?? this.scannerImageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}

class ShopSettingsResponse {
  final String? status;
  final String? message;
  final ShopSettingsModel? payload;
  final int? statusCode;

  ShopSettingsResponse({
    this.status,
    this.message,
    this.payload,
    this.statusCode,
  });

  factory ShopSettingsResponse.fromJson(Map<String, dynamic> json) {
    return ShopSettingsResponse(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      payload: json['payload'] != null
          ? ShopSettingsModel.fromJson(json['payload'])
          : null,
      statusCode: json['statusCode'] != null
          ? int.tryParse(json['statusCode'].toString())
          : null,
    );
  }
}