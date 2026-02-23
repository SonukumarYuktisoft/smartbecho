class BusinessSummaryModel {
  final String status;
  final String message;
  final Payload payload;
  final int statusCode;

  BusinessSummaryModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory BusinessSummaryModel.fromJson(Map<String, dynamic> json) {
    return BusinessSummaryModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: Payload.fromJson(json['payload']),
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "payload": payload.toJson(),
      "statusCode": statusCode,
    };
  }
}

class Payload {
  final int totalCompanies;
  final int totalModelsAvailable;
  final int totalStockAvailable;
  final int totalUnitsSold;
  final String topSellingBrandAndModel;
  final double totalRevenue;

  Payload({
    required this.totalCompanies,
    required this.totalModelsAvailable,
    required this.totalStockAvailable,
    required this.totalUnitsSold,
    required this.topSellingBrandAndModel,
    required this.totalRevenue,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      totalCompanies: json['totalCompanies'] ?? 0,
      totalModelsAvailable: json['totalModelsAvailable'] ?? 0,
      totalStockAvailable: json['totalStockAvailable'] ?? 0,
      totalUnitsSold: json['totalUnitsSold'] ?? 0,
      topSellingBrandAndModel: json['topSellingBrandAndModel'] ?? '',
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "totalCompanies": totalCompanies,
      "totalModelsAvailable": totalModelsAvailable,
      "totalStockAvailable": totalStockAvailable,
      "totalUnitsSold": totalUnitsSold,
      "topSellingBrandAndModel": topSellingBrandAndModel,
      "totalRevenue": totalRevenue,
    };
  }
}