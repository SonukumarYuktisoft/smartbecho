
class NotifyCustomerRequest {
  final List<int> customerIds;

  NotifyCustomerRequest({required this.customerIds});

  Map<String, dynamic> toJson() {
    return {
      'customerIds': customerIds,
    };
  }
}

class NotifyCustomerResponse {
  final String status;
  final String message;
  final NotifyCustomerPayload payload;
  final int statusCode;

  NotifyCustomerResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory NotifyCustomerResponse.fromJson(Map<String, dynamic> json) {
    return NotifyCustomerResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: NotifyCustomerPayload.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }

  bool get isSuccess => status.toLowerCase() == 'success' && statusCode == 200;
}

class NotifyCustomerPayload {
  final List<int> notified;
  final List<int> notFound;
  final int totalRequested;

  NotifyCustomerPayload({
    required this.notified,
    required this.notFound,
    required this.totalRequested,
  });

  factory NotifyCustomerPayload.fromJson(Map<String, dynamic> json) {
    return NotifyCustomerPayload(
      notified: List<int>.from(json['notified'] ?? []),
      notFound: List<int>.from(json['notFound'] ?? []),
      totalRequested: json['totalRequested'] ?? 0,
    );
  }

  bool get hasNotifiedCustomers => notified.isNotEmpty;
  bool get hasNotFoundCustomers => notFound.isNotEmpty;
  bool get allCustomersNotified => notified.length == totalRequested;
}