class MonthlyDueSummaryResponse {
  final String status;
  final String message;
  final MonthlyDueSummaryPayload payload;
  final int statusCode;

  MonthlyDueSummaryResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory MonthlyDueSummaryResponse.fromJson(Map<String, dynamic> json) {
    return MonthlyDueSummaryResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: MonthlyDueSummaryPayload.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
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

class MonthlyDueSummaryPayload {
  final double totalDue;
  final double totalPaid;
  final double remainingDue;
  final double totalCollected;

  MonthlyDueSummaryPayload({
    required this.totalDue,
    required this.totalPaid,
    required this.remainingDue,
    required this.totalCollected,
  });

  factory MonthlyDueSummaryPayload.fromJson(Map<String, dynamic> json) {
    return MonthlyDueSummaryPayload(
      totalDue: (json['totalDue'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      remainingDue: (json['remainingDue'] ?? 0).toDouble(),
      totalCollected: (json['totalCollected'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDue': totalDue,
      'totalPaid': totalPaid,
      'remainingDue': remainingDue,
      'totalCollected': totalCollected,
    };
  }
}
