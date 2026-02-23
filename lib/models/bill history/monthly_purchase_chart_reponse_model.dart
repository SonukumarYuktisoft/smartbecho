class BillAnalyticsModel {
  final String month;
  final String? company;
  final double totalPurchase;
  final double totalPaid;

  BillAnalyticsModel({
    required this.month,
    this.company,
    required this.totalPurchase,
    required this.totalPaid,
  });

  factory BillAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return BillAnalyticsModel(
      month: json['month'] ?? '',
      company: json['company'],
      totalPurchase: (json['totalPurchase'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
    );
  }

  // Get short month name for chart display
  String get monthShort => month.substring(0, 3);
}
