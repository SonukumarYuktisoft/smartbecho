class MonthlyDuesResponse {
  final String status;
  final String message;
  final List<MonthlyDues> payload;
  final int statusCode;

  MonthlyDuesResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory MonthlyDuesResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyDuesResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: (json['payload'] as List<dynamic>? ?? [])
          .map((e) => MonthlyDues.fromJson(e as Map<String, dynamic>))
          .toList(),
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'payload': payload.map((e) => e.toJson()).toList(),
        'statusCode': statusCode,
      };

  // Helpers
  bool get isSuccess => status.toLowerCase() == 'success' && statusCode == 200;

  /// Total collected across months
  double get totalCollected =>
      payload.fold(0.0, (sum, item) => sum + item.collected);

  /// Total remaining across months
  double get totalRemaining =>
      payload.fold(0.0, (sum, item) => sum + item.remaining);

  /// Chart data by collected dues
  Map<String, double> get chartDataCollected {
    return {
      for (var item in payload) item.month: item.collected,
    };
  }

  /// Chart data by remaining dues
  Map<String, double> get chartDataRemaining {
    return {
      for (var item in payload) item.month: item.remaining,
    };
  }

  /// Chart data by collected percentage
  Map<String, double> get chartCollectedPercentage {
    return {
      for (var item in payload) item.month: item.collectedPercentage,
    };
  }

  /// Chart data by remaining percentage
  Map<String, double> get chartRemainingPercentage {
    return {
      for (var item in payload) item.month: item.remainingPercentage,
    };
  }

  @override
  String toString() =>
      'MonthlyDuesResponse(status: $status, message: $message, statusCode: $statusCode, payload count: ${payload.length})';
}

class MonthlyDues {
  final String month;
  final double remainingPercentage;
  final double collected;
  final double collectedPercentage;
  final double remaining;

  MonthlyDues({
    required this.month,
    required this.remainingPercentage,
    required this.collected,
    required this.collectedPercentage,
    required this.remaining,
  });

  factory MonthlyDues.fromJson(Map<String, dynamic> json) {
    return MonthlyDues(
      month: json['month'] ?? '',
      remainingPercentage:
          (json['remainingPercentage'] as num?)?.toDouble() ?? 0.0,
      collected: (json['collected'] as num?)?.toDouble() ?? 0.0,
      collectedPercentage:
          (json['collectedPercentage'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'remainingPercentage': remainingPercentage,
        'collected': collected,
        'collectedPercentage': collectedPercentage,
        'remaining': remaining,
      };

  @override
  String toString() {
    return 'MonthlyDues(month: $month, collected: $collected, remaining: $remaining)';
  }
}
