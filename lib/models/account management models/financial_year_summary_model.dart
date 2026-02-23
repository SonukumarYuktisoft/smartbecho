class FinancialSummaryResponse {
  final String status;
  final String message;
  final List<FinancialSummaryModel> payload;
  final int statusCode;

  FinancialSummaryResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory FinancialSummaryResponse.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: (json['payload'] as List<dynamic>?)
          ?.map((item) => FinancialSummaryModel.fromJson(item))
          .toList() ?? [],
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class FinancialSummaryModel {
  final int month;
  final double totalBillsPaid;
  final double totalSalesAmount;
  final double totalCommissions;

  FinancialSummaryModel({
    required this.month,
    required this.totalBillsPaid,
    required this.totalSalesAmount,
    required this.totalCommissions,
  });

  factory FinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    return FinancialSummaryModel(
      month: json['month'] ?? 0,
      totalBillsPaid: (json['totalBillsPaid'] ?? 0).toDouble(),
      totalSalesAmount: (json['totalSalesAmount'] ?? 0).toDouble(),
      totalCommissions: (json['totalCommissions'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'totalBillsPaid': totalBillsPaid,
      'totalSalesAmount': totalSalesAmount,
      'totalCommissions': totalCommissions,
    };
  }

  String get monthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}