import 'dart:convert';

// ==================== ORIGINAL SUBSCRIPTION PLAN RESPONSE ====================
class SubscriptionPlanResponse {
  final String? status;
  final String? message;
  final List<SubscriptionPlan>? payload;
  final int? statusCode;

  SubscriptionPlanResponse({
    this.status,
    this.message,
    this.payload,
    this.statusCode,
  });

  factory SubscriptionPlanResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanResponse(
      status: json['status'],
      message: json['message'],
      payload: json['payload'] != null
          ? (json['payload'] as List)
              .map((e) => SubscriptionPlan.fromJson(e))
              .toList()
          : null,
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload?.map((e) => e.toJson()).toList(),
      'statusCode': statusCode,
    };
  }
}

class SubscriptionPlan {
  final int? id;
  final String? code;
  final String? name;
  final String? description;
  final String? featuresJson;
  final double? priceMonthly;
  final double? priceYearly;
  final int? trialDays;
  final int? maxShopsAllowed;
  final bool? active;
  final String? createdAt;
  final String? updatedAt;

  SubscriptionPlan({
    this.id,
    this.code,
    this.name,
    this.description,
    this.featuresJson,
    this.priceMonthly,
    this.priceYearly,
    this.trialDays,
    this.maxShopsAllowed,
    this.active,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      featuresJson: json['featuresJson'],
      priceMonthly: json['priceMonthly']?.toDouble(),
      priceYearly: json['priceYearly']?.toDouble(),
      trialDays: json['trialDays'],
      maxShopsAllowed: json['maxShopsAllowed'],
      active: json['active'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'featuresJson': featuresJson,
      'priceMonthly': priceMonthly,
      'priceYearly': priceYearly,
      'trialDays': trialDays,
      'maxShopsAllowed': maxShopsAllowed,
      'active': active,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  List<String> get features {
    if (featuresJson == null) return [];
    try {
      final List<dynamic> decoded = json.decode(featuresJson!);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }
}

// ==================== NEW: SUBSCRIPTION PLAN WITH UPGRADE PRICE ====================
class SubscriptionPlanWithUpgradeResponse {
  final String? status;
  final String? message;
  final List<SubscriptionPlanWithUpgrade>? payload;
  final int? statusCode;

  SubscriptionPlanWithUpgradeResponse({
    this.status,
    this.message,
    this.payload,
    this.statusCode,
  });

  factory SubscriptionPlanWithUpgradeResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanWithUpgradeResponse(
      status: json['status'],
      message: json['message'],
      payload: json['payload'] != null
          ? (json['payload'] as List)
              .map((e) => SubscriptionPlanWithUpgrade.fromJson(e))
              .toList()
          : null,
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload?.map((e) => e.toJson()).toList(),
      'statusCode': statusCode,
    };
  }
}

class SubscriptionPlanWithUpgrade {
  final double? upgradePrice;
  final double? gstAmount;
  final bool? canPurchase;
  final String? period;
  final double? currentPlanPrice;
  final String? planName;
  final bool? isSamePlan;
  final double? finalAmountWithGst;
  final bool? isUpgrade;
  final String? message;
  final String? planCode;
  final double? basePrice;
  
  // Additional fields that might be in the full plan details
  final int? id;
  final String? description;
  final String? featuresJson;
  final int? trialDays;
  final int? maxShopsAllowed;
  final bool? active;

  SubscriptionPlanWithUpgrade({
    this.upgradePrice,
    this.gstAmount,
    this.canPurchase,
    this.period,
    this.currentPlanPrice,
    this.planName,
    this.isSamePlan,
    this.finalAmountWithGst,
    this.isUpgrade,
    this.message,
    this.planCode,
    this.basePrice,
    this.id,
    this.description,
    this.featuresJson,
    this.trialDays,
    this.maxShopsAllowed,
    this.active,
  });

  factory SubscriptionPlanWithUpgrade.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanWithUpgrade(
      upgradePrice: json['upgradePrice']?.toDouble(),
      gstAmount: json['gstAmount']?.toDouble(),
      canPurchase: json['canPurchase'],
      period: json['period'],
      currentPlanPrice: json['currentPlanPrice']?.toDouble(),
      planName: json['planName'],
      isSamePlan: json['isSamePlan'],
      finalAmountWithGst: json['finalAmountWithGst']?.toDouble(),
      isUpgrade: json['isUpgrade'],
      message: json['message'],
      planCode: json['planCode'],
      basePrice: json['basePrice']?.toDouble(),
      id: json['id'],
      description: json['description'],
      featuresJson: json['featuresJson'],
      trialDays: json['trialDays'],
      maxShopsAllowed: json['maxShopsAllowed'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upgradePrice': upgradePrice,
      'gstAmount': gstAmount,
      'canPurchase': canPurchase,
      'period': period,
      'currentPlanPrice': currentPlanPrice,
      'planName': planName,
      'isSamePlan': isSamePlan,
      'finalAmountWithGst': finalAmountWithGst,
      'isUpgrade': isUpgrade,
      'message': message,
      'planCode': planCode,
      'basePrice': basePrice,
      'id': id,
      'description': description,
      'featuresJson': featuresJson,
      'trialDays': trialDays,
      'maxShopsAllowed': maxShopsAllowed,
      'active': active,
    };
  }

  List<String> get features {
    if (featuresJson == null) return [];
    try {
      final List<dynamic> decoded = json.decode(featuresJson!);
      return decoded.map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  // Helper getters
  bool get isFree => (upgradePrice ?? 0) <= 0;
  bool get isDisabled => isSamePlan == true || canPurchase == false;
  
  String get buttonText {
    if (isSamePlan == true) return 'Current Plan';
    if (basePrice == 0) return 'Get Started';
    if (isUpgrade == true) return 'Upgrade';
    return 'Subscribe Now';
  }
}