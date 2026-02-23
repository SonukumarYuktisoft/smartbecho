class SalesInsightsStatsModel {
  final String status;
  final String message;
  final Payload payload;
  final int statusCode;

  SalesInsightsStatsModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory SalesInsightsStatsModel.fromJson(Map<String, dynamic> json) {
    return SalesInsightsStatsModel(
      status: json['status'],
      message: json['message'],
      payload: Payload.fromJson(json['payload']),
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload.toJson(),
      'statusCode': statusCode,
    };
  }
}

class Payload {
  final double totalSaleAmount;
  final double averageSaleAmountGrowth;
  final double averageSaleAmount;
  final double totalUnitsSoldGrowth;
  final int totalUnitsSold;
  final double totalSaleAmountGrowth;
  final double totalEmiSalesAmount;
  final double totalEmiSalesAmountGrowth;

  Payload({
    required this.totalSaleAmount,
    required this.averageSaleAmountGrowth,
    required this.averageSaleAmount,
    required this.totalUnitsSoldGrowth,
    required this.totalUnitsSold,
    required this.totalSaleAmountGrowth,
    required this.totalEmiSalesAmount,
    required this.totalEmiSalesAmountGrowth,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      totalSaleAmount: (json['totalSaleAmount'] as num).toDouble(),
      averageSaleAmountGrowth: (json['averageSaleAmountGrowth'] as num).toDouble(),
      averageSaleAmount: (json['averageSaleAmount'] as num).toDouble(),
      totalUnitsSoldGrowth: (json['totalUnitsSoldGrowth'] as num).toDouble(),
      totalUnitsSold: json['totalUnitsSold'],
      totalSaleAmountGrowth: (json['totalSaleAmountGrowth'] as num).toDouble(),
      totalEmiSalesAmount: (json['totalEmiSalesAmount'] as num).toDouble(),
      totalEmiSalesAmountGrowth: (json['totalEmiSalesAmountGrowth'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSaleAmount': totalSaleAmount,
      'averageSaleAmountGrowth': averageSaleAmountGrowth,
      'averageSaleAmount': averageSaleAmount,
      'totalUnitsSoldGrowth': totalUnitsSoldGrowth,
      'totalUnitsSold': totalUnitsSold,
      'totalSaleAmountGrowth': totalSaleAmountGrowth,
      'totalEmiSalesAmount': totalEmiSalesAmount,
      'totalEmiSalesAmountGrowth': totalEmiSalesAmountGrowth,
    };
  }
}
