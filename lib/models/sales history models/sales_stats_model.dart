class SalesStats {
  final double totalSaleAmount;
  final double totalEmiAmount;
  final double upiAmount;
  final double cashAmount;
  final double cardAmount;
  final int totalPhonesSold;

  SalesStats({
    required this.totalSaleAmount,
    required this.totalEmiAmount,
    required this.upiAmount,
    required this.cashAmount,
    required this.cardAmount,
    required this.totalPhonesSold,
  });

  factory SalesStats.fromJson(Map<String, dynamic> json) {
    return SalesStats(
      totalSaleAmount: json['totalSaleAmount'].toDouble(),
      totalEmiAmount: json['totalEmiAmount'].toDouble(),
      upiAmount: json['upiAmount'].toDouble(),
      cashAmount: json['cashAmount'].toDouble(),
      cardAmount: json['cardAmount'].toDouble(),
      totalPhonesSold: json['totalPhonesSold'],
    );
  }
}

class SalesStatsResponse {
  final String status;
  final String message;
  final SalesStats payload;
  final int statusCode;

  SalesStatsResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory SalesStatsResponse.fromJson(Map<String, dynamic> json) {
    return SalesStatsResponse(
      status: json['status'],
      message: json['message'],
      payload: SalesStats.fromJson(json['payload']),
      statusCode: json['statusCode'],
    );
  }
}