class BrandSalesResponse {
  final String status;
  final String message;
  final List<BrandSaleItem> payload;
  final int statusCode;

  BrandSalesResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory BrandSalesResponse.fromJson(Map<String, dynamic> json) {
    return BrandSalesResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: (json['payload'] as List<dynamic>)
          .map((e) => BrandSaleItem.fromJson(e))
          .toList(),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}
class BrandSaleItem {
  final int totalQuantity;
  final String month;
  final double percentage;
  final String brand;

  BrandSaleItem({
    required this.totalQuantity,
    required this.month,
    required this.percentage,
    required this.brand,
  });

  factory BrandSaleItem.fromJson(Map<String, dynamic> json) {
    return BrandSaleItem(
      totalQuantity: json['totalQuantity'] ?? 0,
      month: json['month'] ?? '',
      percentage: double.tryParse(json['percentage'].toString()) ?? 0.0,
      brand: json['brand'] ?? '',
    );
  }
}
