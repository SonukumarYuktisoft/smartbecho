
class TopSellingModelsResponse {
  final String status;
  final String message;
  final List<ProductModel> payload;
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
      payload: (json['payload'] as List<dynamic>?)
              ?.map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload.map((item) => item.toJson()).toList(),
      'statusCode': statusCode,
    };
  }

  // Helper method to check if response is successful
  bool get isSuccess => status.toLowerCase() == 'success' && statusCode == 200;

  // Helper method to get total revenue across all models
  double get totalRevenue => payload.fold(0.0, (sum, item) => sum + item.totalAmount);

  // Helper method to get total quantity sold across all models
  int get totalQuantitySold => payload.fold(0, (sum, item) => sum + item.quantity);

  // Helper method to get formatted data for charts
  Map<String, double> get chartData {
    Map<String, double> data = {};
    for (var item in payload) {
      String key = '${item.brand} ${item.model}';
      data[key] = item.quantity.toDouble();
    }
    return data;
  }

  // Helper method to get chart data by quantity
  Map<String, double> get chartDataByQuantity {
    Map<String, double> data = {};
    for (var item in payload) {
      String key = '${item.brand} ${item.model}';
      data[key] = item.quantity.toDouble();
    }
    return data;
  }

  @override
  String toString() {
    return 'TopSellingModelsResponse(status: $status, message: $message, payload: $payload, statusCode: $statusCode)';
  }
}

// Individual product model
class ProductModel {
  final double totalAmount;
  final int quantity;
  final String model;
  final String brand;

  ProductModel({
    required this.totalAmount,
    required this.quantity,
    required this.model,
    required this.brand,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      model: json['model'] ?? '',
      brand: json['brand'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'quantity': quantity,
      'model': model,
      'brand': brand,
    };
  }

  // Helper getters
  String get fullName => '$brand $model';
  double get averagePrice => quantity > 0 ? totalAmount / quantity : 0.0;
  String get formattedAmount => '₹${totalAmount.toStringAsFixed(2)}';
  String get formattedAveragePrice => '₹${averagePrice.toStringAsFixed(2)}';

  @override
  String toString() {
    return 'ProductModel(totalAmount: $totalAmount, quantity: $quantity, model: $model, brand: $brand)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          totalAmount == other.totalAmount &&
          quantity == other.quantity &&
          model == other.model &&
          brand == other.brand;

  @override
  int get hashCode =>
      totalAmount.hashCode ^ quantity.hashCode ^ model.hashCode ^ brand.hashCode;
}

// Extension methods for additional functionality
extension TopSellingModelsExtension on TopSellingModelsResponse {
  // Get top N models by revenue
  List<ProductModel> getTopModelsByRevenue(int count) {
    var sortedList = List<ProductModel>.from(payload);
    sortedList.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return sortedList.take(count).toList();
  }

  // Get top N models by quantity
  List<ProductModel> getTopModelsByQuantity(int count) {
    var sortedList = List<ProductModel>.from(payload);
    sortedList.sort((a, b) => b.quantity.compareTo(a.quantity));
    return sortedList.take(count).toList();
  }

  // Group by brand
  Map<String, List<ProductModel>> get groupedByBrand {
    Map<String, List<ProductModel>> grouped = {};
    for (var item in payload) {
      if (grouped.containsKey(item.brand)) {
        grouped[item.brand]!.add(item);
      } else {
        grouped[item.brand] = [item];
      }
    }
    return grouped;
  }

  // Get brand-wise revenue
  Map<String, double> get brandWiseRevenue {
    Map<String, double> brandRevenue = {};
    for (var item in payload) {
      brandRevenue[item.brand] = (brandRevenue[item.brand] ?? 0) + item.totalAmount;
    }
    return brandRevenue;
  }
}