class LowStockAlertModel {
  final String status;
  final String message;
  final LowStockPayload payload;
  final int statusCode;

  LowStockAlertModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory LowStockAlertModel.fromJson(Map<String, dynamic> json) {
    return LowStockAlertModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: LowStockPayload.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class LowStockPayload {
  final List<String> critical;
  final List<String> low;
  final List<String> outOfStock;

  LowStockPayload({
    required this.critical,
    required this.low,
    required this.outOfStock,
  });

  factory LowStockPayload.fromJson(Map<String, dynamic> json) {
    return LowStockPayload(
      critical: List<String>.from(json['critical'] ?? []),
      low: List<String>.from(json['low'] ?? []),
      outOfStock: List<String>.from(json['outOfStock'] ?? []),
    );
  }
}