class MonthlyDuesAnalyticsResponse {
  final String status;
  final String message;
  final List<MonthlyDuesSummary> payload;
  final int statusCode;

  MonthlyDuesAnalyticsResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory MonthlyDuesAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyDuesAnalyticsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload:
          (json['payload'] as List<dynamic>?)
              ?.map((item) => MonthlyDuesSummary.fromJson(item))
              .toList() ??
          [],
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class MonthlyDuesSummary {
  final String month;
  final double remainingPercentage;
  final double collected;
  final double collectedPercentage;
  final double remaining;

  MonthlyDuesSummary({
    required this.month,
    required this.remainingPercentage,
    required this.collected,
    required this.collectedPercentage,
    required this.remaining,
  });

  factory MonthlyDuesSummary.fromJson(Map<String, dynamic> json) {
    return MonthlyDuesSummary(
      month: json['month'] ?? '',
      remainingPercentage: (json['remainingPercentage'] ?? 0).toDouble(),
      collected: (json['collected'] ?? 0).toDouble(),
      collectedPercentage: (json['collectedPercentage'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'remainingPercentage': remainingPercentage,
      'collected': collected,
      'collectedPercentage': collectedPercentage,
      'remaining': remaining,
    };
  }

  // Helper getters for easy access
  double get totalAmount => collected + remaining;
  String get monthShort => month.substring(0, 3).toUpperCase();
}
