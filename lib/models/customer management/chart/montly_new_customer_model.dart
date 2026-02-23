class CustomerMonthlyDataResponse {
  final String status;
  final String message;
  final Map<String, double> payload;
  final int statusCode;

  CustomerMonthlyDataResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory CustomerMonthlyDataResponse.fromJson(Map<String, dynamic> json) {
    return CustomerMonthlyDataResponse(
      status: json['status'],
      message: json['message'],
      payload: Map<String, dynamic>.from(json['payload'])
          .map((key, value) => MapEntry(key, (value as num).toDouble())),
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload,
      'statusCode': statusCode,
    };
  }
}
