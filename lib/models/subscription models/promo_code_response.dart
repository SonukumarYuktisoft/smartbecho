class PromoCodeResponse {
  final String status;
  final String message;
  final PromoCodePayload payload;
  final int statusCode;

  PromoCodeResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory PromoCodeResponse.fromJson(Map<String, dynamic> json) {
    return PromoCodeResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: PromoCodePayload.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }

  bool get isValid => status == 'SUCCESS' && payload.valid;
}

class PromoCodePayload {
  final bool valid;
  final double? finalAmount;
  final double? discountAmount;
  final PromoCode? promoCode;

  PromoCodePayload({
    required this.valid,
    this.finalAmount,
    this.discountAmount,
    this.promoCode,
  });

  factory PromoCodePayload.fromJson(Map<String, dynamic> json) {
    return PromoCodePayload(
      valid: json['valid'] ?? false,
      finalAmount: json['finalAmount']?.toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      promoCode: json['promoCode'] != null 
          ? PromoCode.fromJson(json['promoCode']) 
          : null,
    );
  }
}

class PromoCode {
  final int id;
  final String code;
  final String description;
  final String discountType;
  final double discountValue;
  final String validFrom;
  final String validTo;
  final String applicablePlanCodes;
  final bool applicableToNewSubscription;
  final bool applicableToUpgrade;
  final bool isUsed;
  final String? usedAt;
  final int? usedByUserId;
  final int maxUses;
  final int currentUses;
  final double? minPurchaseAmount;
  final bool active;
  final String createdAt;
  final String updatedAt;

  PromoCode({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.validFrom,
    required this.validTo,
    required this.applicablePlanCodes,
    required this.applicableToNewSubscription,
    required this.applicableToUpgrade,
    required this.isUsed,
    this.usedAt,
    this.usedByUserId,
    required this.maxUses,
    required this.currentUses,
    this.minPurchaseAmount,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      discountType: json['discountType'] ?? '',
      discountValue: json['discountValue']?.toDouble() ?? 0.0,
      validFrom: json['validFrom'] ?? '',
      validTo: json['validTo'] ?? '',
      applicablePlanCodes: json['applicablePlanCodes'] ?? '',
      applicableToNewSubscription: json['applicableToNewSubscription'] ?? false,
      applicableToUpgrade: json['applicableToUpgrade'] ?? false,
      isUsed: json['isUsed'] ?? false,
      usedAt: json['usedAt'],
      usedByUserId: json['usedByUserId'],
      maxUses: json['maxUses'] ?? 0,
      currentUses: json['currentUses'] ?? 0,
      minPurchaseAmount: json['minPurchaseAmount']?.toDouble(),
      active: json['active'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}