class MonthlyRevenueChartModel {
  final String status;
  final String message;
  final Map<String, double> payload;
  final int statusCode;

  MonthlyRevenueChartModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory MonthlyRevenueChartModel.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'] as Map<String, dynamic>;
    final revenueMap = rawPayload.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return MonthlyRevenueChartModel(
      status: json['status'],
      message: json['message'],
      payload: revenueMap,
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'payload': payload,
        'statusCode': statusCode,
      };
}
