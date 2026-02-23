class PaymentDistributionResponse {
  final int totalPayments;
  final List<PaymentDistribution> distributions;

  PaymentDistributionResponse({
    required this.totalPayments,
    required this.distributions,
  });

  factory PaymentDistributionResponse.fromJson(Map<String, dynamic> json) {
    return PaymentDistributionResponse(
      totalPayments: json["payload"]["totalPayments"] ?? 0,
      distributions: (json["payload"]["distributions"] as List)
          .map((e) => PaymentDistribution.fromJson(e))
          .toList(),
    );
  }
}

class PaymentDistribution {
  final String paymentMethod;
  final String paymentType;
  final int count;
  final double totalAmount;
  final double percentage;

  PaymentDistribution({
    required this.paymentMethod,
    required this.paymentType,
    required this.count,
    required this.totalAmount,
    required this.percentage,
  });

  factory PaymentDistribution.fromJson(Map<String, dynamic> json) {
    return PaymentDistribution(
      paymentMethod: json["paymentMethod"] ?? "",
      paymentType: json["paymentType"] ?? "",
      count: json["count"] ?? 0,
      totalAmount: (json["totalAmount"] as num).toDouble(),
      percentage: (json["percentage"] as num).toDouble(),
    );
  }
}
