import 'dart:convert';

class UpgradePriceResponse {
  final String? status;
  final String? message;
  final UpgradePricePayload? payload;
  final int? statusCode;

  UpgradePriceResponse({
    this.status,
    this.message,
    this.payload,
    this.statusCode,
  });

  factory UpgradePriceResponse.fromJson(Map<String, dynamic> json) {
    return UpgradePriceResponse(
      status: json['status'],
      message: json['message'],
      payload: json['payload'] != null
          ? UpgradePricePayload.fromJson(json['payload'])
          : null,
      statusCode: json['statusCode'],
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
}

class UpgradePricePayload {
  // Core pricing fields
  final double? upgradePrice;
  final double? currentPlanPrice;
  final double? newPlanPrice;
  
  // Plan information
  final String? currentPlanCode;
  final String? newPlanCode;
  
  // Status fields
  final bool? hasActivePlan;
  final bool? isSamePlan;
  
  // Legacy fields (for backwards compatibility)
  final double? originalPrice;
  final double? creditApplied;
  final String? planCode;
  final String? period;
  
  // Message from backend
  final String? message;

  UpgradePricePayload({
    this.upgradePrice,
    this.currentPlanPrice,
    this.newPlanPrice,
    this.currentPlanCode,
    this.newPlanCode,
    this.hasActivePlan,
    this.isSamePlan,
    this.originalPrice,
    this.creditApplied,
    this.planCode,
    this.period,
    this.message,
  });

  factory UpgradePricePayload.fromJson(Map<String, dynamic> json) {
    return UpgradePricePayload(
      // New fields
      upgradePrice: _toDouble(json['upgradePrice']),
      currentPlanPrice: _toDouble(json['currentPlanPrice']),
      newPlanPrice: _toDouble(json['newPlanPrice']),
      currentPlanCode: json['currentPlanCode']?.toString().trim(),
      newPlanCode: json['newPlanCode']?.toString().trim(),
      hasActivePlan: json['hasActivePlan'] is bool
          ? json['hasActivePlan']
          : (json['hasActivePlan']?.toString().toLowerCase() == 'true'),
      isSamePlan: json['isSamePlan'] is bool
          ? json['isSamePlan']
          : (json['isSamePlan']?.toString().toLowerCase() == 'true'),
      
      // Legacy fields
      originalPrice: _toDouble(json['originalPrice']),
      creditApplied: _toDouble(json['creditApplied']),
      planCode: json['planCode'],
      period: json['period'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upgradePrice': upgradePrice,
      'currentPlanPrice': currentPlanPrice,
      'newPlanPrice': newPlanPrice,
      'currentPlanCode': currentPlanCode,
      'newPlanCode': newPlanCode,
      'hasActivePlan': hasActivePlan,
      'isSamePlan': isSamePlan,
      'originalPrice': originalPrice,
      'creditApplied': creditApplied,
      'planCode': planCode,
      'period': period,
      'message': message,
    };
  }

  /// Helper method to convert any type to double safely
  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  /// Check if upgrade is needed (downgrade scenario)
  bool get isDowngrade {
    if (newPlanPrice == null || currentPlanPrice == null) return false;
    return newPlanPrice! < currentPlanPrice!;
  }

  /// Get formatted price display
  String get formattedUpgradePrice {
    if (upgradePrice == null) return '₹0.00';
    return '₹${upgradePrice!.toStringAsFixed(2)}';
  }

  String get formattedCurrentPlanPrice {
    if (currentPlanPrice == null) return '₹0.00';
    return '₹${currentPlanPrice!.toStringAsFixed(2)}';
  }

  String get formattedNewPlanPrice {
    if (newPlanPrice == null) return '₹0.00';
    return '₹${newPlanPrice!.toStringAsFixed(2)}';
  }

  /// Get upgrade summary message
  String get upgradeSummary {
    if (message != null && message!.isNotEmpty) {
      return message!;
    }
    
    return 'Upgrading from ${currentPlanCode?.trim()} (${formattedCurrentPlanPrice}) '
        'to ${newPlanCode?.trim()} (${formattedNewPlanPrice}). '
        'You need to pay ${formattedUpgradePrice}.';
  }

  /// Check if same plan
  bool get isSamePlanWarning {
    return isSamePlan ?? false;
  }

  /// Check if no upgrade needed (credit covers it)
  bool get isFullyCredited {
    return upgradePrice == 0.0;
  }
}