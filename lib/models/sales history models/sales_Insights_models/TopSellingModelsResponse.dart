class TopSellingModelsResponse {
  final String status;
  final String message;
  final List<TopModelItem> payload;
  final int statusCode;

  TopSellingModelsResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory TopSellingModelsResponse.fromJson(Map<String, dynamic> json) {
    return TopSellingModelsResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: (json['payload'] as List<dynamic>)
          .map((e) => TopModelItem.fromJson(e))
          .toList(),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}
class TopModelItem {
  final double? totalAmount;
  final int quantity;
  final String model;
  final String brand;

  TopModelItem({
    required this.totalAmount,
    required this.quantity,
    required this.model,
    required this.brand,
  });

  factory TopModelItem.fromJson(Map<String, dynamic> json) {
    return TopModelItem(
      totalAmount: json['totalAmount'] == null
          ? null
          : double.tryParse(json['totalAmount'].toString()),
      quantity: json['quantity'] ?? 0,
      model: json['model'] ?? '',
      brand: json['brand'] ?? '',
    );
  }
}
