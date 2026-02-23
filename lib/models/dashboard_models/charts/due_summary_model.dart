class DuesSummaryResponse {
  final String status;
  final String message;
  final DuesSummaryPayload payload;
  final int statusCode;

  DuesSummaryResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory DuesSummaryResponse.fromJson(Map<String, dynamic> json) {
    return DuesSummaryResponse(
      status: json['status'],
      message: json['message'],
      payload: DuesSummaryPayload.fromJson(json['payload']),
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'payload': payload.toJson(),
    'statusCode': statusCode,
  };
}

class DuesSummaryPayload {
  final double remainingPercentage;
  final double collected;
  final double collectedPercentage;
  final double remaining;

  DuesSummaryPayload({
    required this.remainingPercentage,
    required this.collected,
    required this.collectedPercentage,
    required this.remaining,
  });

  factory DuesSummaryPayload.fromJson(Map<String, dynamic> json) {
    return DuesSummaryPayload(
      remainingPercentage: (json['remainingPercentage'] as num).toDouble(),
      collected: (json['collected'] as num).toDouble(),
      collectedPercentage: (json['collectedPercentage'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'remainingPercentage': remainingPercentage,
    'collected': collected,
    'collectedPercentage': collectedPercentage,
    'remaining': remaining,
  };
}
