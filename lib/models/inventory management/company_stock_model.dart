class CompanyStockModel {
  final String company;
  final int totalStock;
  final int totalModels;
  final int lowStockModels;

  CompanyStockModel({
    required this.company,
    required this.totalStock,
    required this.totalModels,
    required this.lowStockModels,
  });

  factory CompanyStockModel.fromJson(Map<String, dynamic> json) {
    return CompanyStockModel(
      company: json['company'] ?? '',
      totalStock: json['totalStock'] ?? 0,
      totalModels: json['totalModels'] ?? 0,
      lowStockModels: json['lowStockModels'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company': company,
      'totalStock': totalStock,
      'totalModels': totalModels,
      'lowStockModels': lowStockModels,
    };
  }
}
