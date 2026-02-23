class PartialPaymentResponseModel {
  final String status;
  final String message;
  final PartialPaymentPayload payload;
  final int statusCode;

  PartialPaymentResponseModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory PartialPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return PartialPaymentResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: PartialPaymentPayload.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class PartialPaymentPayload {
  final int id;
  final String shopId;
  final double totalDue;
  final double totalPaid;
  final double remainingDue;
  final List<int> creationDate;
  final List<int> paymentRetriableDate;
  final bool paid;

  PartialPaymentPayload({
    required this.id,
    required this.shopId,
    required this.totalDue,
    required this.totalPaid,
    required this.remainingDue,
    required this.creationDate,
    required this.paymentRetriableDate,
    required this.paid,
  });

  factory PartialPaymentPayload.fromJson(Map<String, dynamic> json) {
    return PartialPaymentPayload(
      id: json['id'] ?? 0,
      shopId: json['shopId'] ?? '',
      totalDue: (json['totalDue'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      remainingDue: (json['remainingDue'] ?? 0).toDouble(),
      creationDate: List<int>.from(json['creationDate'] ?? []),
      paymentRetriableDate: List<int>.from(json['paymentRetriableDate'] ?? []),
      paid: json['paid'] ?? false,
    );
  }
}
