class EmiSettlementChartResponse {
  final String status;
  final String message;
  final List<MonthlyEmiData> payload;
  final int statusCode;

  EmiSettlementChartResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory EmiSettlementChartResponse.fromJson(Map<String, dynamic> json) {
    return EmiSettlementChartResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: (json['payload'] as List<dynamic>?)
          ?.map((item) => MonthlyEmiData.fromJson(item))
          .toList() ?? [],
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload.map((item) => item.toJson()).toList(),
      'statusCode': statusCode,
    };
  }
}

class MonthlyEmiData {
  final String month;
  final double amount;

  MonthlyEmiData({
    required this.month,
    required this.amount,
  });

  factory MonthlyEmiData.fromJson(Map<String, dynamic> json) {
    return MonthlyEmiData(
      month: json['month'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'amount': amount,
    };
  }
}