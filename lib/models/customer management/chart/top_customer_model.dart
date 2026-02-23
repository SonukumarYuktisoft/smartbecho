class TopCustomer {
  final int customerId;
  final String name;
  final double totalSales;

  TopCustomer({
    required this.customerId,
    required this.name,
    required this.totalSales,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    return TopCustomer(
      customerId: json['customerId'] ?? 0,
      name: json['name'] ?? '',
      totalSales: (json['totalSales'] as num).toDouble(),
    );
  }
}

class TopCustomersResponse {
  final String status;
  final String message;
  final List<TopCustomer> payload;
  final int statusCode;

  TopCustomersResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory TopCustomersResponse.fromJson(Map<String, dynamic> json) {
    return TopCustomersResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: (json['payload'] as List)
          .map((e) => TopCustomer.fromJson(e))
          .toList(),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}
