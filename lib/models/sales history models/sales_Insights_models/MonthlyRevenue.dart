class MonthlyRevenueResponse {
  final String status;
  final String message;
  final Map<String, double> payload;
  final int statusCode;

  MonthlyRevenueResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory MonthlyRevenueResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyRevenueResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: Map<String, double>.from(json['payload']),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}
