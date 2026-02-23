class CustomerStatsResponse {
  final String status;
  final String message;
  final CustomerStatsPayload payload;
  final int statusCode;

  CustomerStatsResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory CustomerStatsResponse.fromJson(Map<String, dynamic> json) {
    return CustomerStatsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: CustomerStatsPayload.fromJson(json['payload'] ?? {}),
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

class CustomerStatsPayload {
  final int totalCustomers;
  final int repeatedCustomers;
  final int newCustomersThisMonth;

  CustomerStatsPayload({
    required this.totalCustomers,
    required this.repeatedCustomers,
    required this.newCustomersThisMonth,
  });

  factory CustomerStatsPayload.fromJson(Map<String, dynamic> json) {
    return CustomerStatsPayload(
      totalCustomers: json['totalCustomers'] ?? 0,
      repeatedCustomers: json['repeatedCustomers'] ?? 0,
      newCustomersThisMonth: json['newCustomersThisMonth'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCustomers': totalCustomers,
      'repeatedCustomers': repeatedCustomers,
      'newCustomersThisMonth': newCustomersThisMonth,
    };
  }
}
