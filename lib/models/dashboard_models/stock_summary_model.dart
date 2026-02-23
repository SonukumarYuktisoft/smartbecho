class StockSummaryModel {
  final String status;
  final String message;
  final StockSummaryPayload payload;
  final int statusCode;

  StockSummaryModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory StockSummaryModel.fromJson(Map<String, dynamic> json) {
    return StockSummaryModel(
      status: json['status'],
      message: json['message'],
      payload: StockSummaryPayload.fromJson(json['payload']),
      statusCode: json['statusCode'],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'payload': payload.toJson(),
        'statusCode': statusCode,
      };
}

class StockSummaryPayload {
  final Map<String, int> companyWiseStock;
  final int totalStock;
  final List<LowStockDetail> lowStockDetails;

  StockSummaryPayload({
    required this.companyWiseStock,
    required this.totalStock,
    required this.lowStockDetails,
  });

  factory StockSummaryPayload.fromJson(Map<String, dynamic> json) {
    final companyStockMap = Map<String, int>.from(
      json['companyWiseStock']?.map((k, v) => MapEntry(k, v as int)) ?? {},
    );

    final List<LowStockDetail> lowStockList = (json['lowStockDetails'] as List<dynamic>?)
            ?.map((e) => LowStockDetail.fromJson(e))
            .toList() ??
        [];

    return StockSummaryPayload(
      companyWiseStock: companyStockMap,
      totalStock: json['totalStock'],
      lowStockDetails: lowStockList,
    );
  }

  Map<String, dynamic> toJson() => {
        'companyWiseStock': companyWiseStock,
        'totalStock': totalStock,
        'lowStockDetails': lowStockDetails.map((e) => e.toJson()).toList(),
      };
}

class LowStockDetail {
  final int qty;
  final String model;
  final String company;

  LowStockDetail({
    required this.qty,
    required this.model,
    required this.company,
  });

  factory LowStockDetail.fromJson(Map<String, dynamic> json) {
    return LowStockDetail(
      qty: json['qty'],
      model: json['model'],
      company: json['company'],
    );
  }

  Map<String, dynamic> toJson() => {
        'qty': qty,
        'model': model,
        'company': company,
      };
}
