class ProductReturn {
  final int id;
  final String shopId;
  final int returnSequence;
  final int productId;
  final String distributor;
  final double returnPrice;
  final DateTime returnDate;
  final int quantity;
  final String itemCategory;
  final String model;
  final String ram;
  final String rom;
  final String color;
  final String company;
  final String? imei;
  final String source;
  final String reason;
  final String? notes;
  final String? returnDocumentUrl;
  final DateTime createdAt;

  ProductReturn({
    required this.id,
    required this.shopId,
    required this.returnSequence,
    required this.productId,
    required this.distributor,
    required this.returnPrice,
    required this.returnDate,
    required this.quantity,
    required this.itemCategory,
    required this.model,
    required this.ram,
    required this.rom,
    required this.color,
    required this.company,
    this.imei,
    required this.source,
    required this.reason,
    this.notes,
    this.returnDocumentUrl,
    required this.createdAt,
  });

  factory ProductReturn.fromJson(Map<String, dynamic> json) {
    return ProductReturn(
      id: json['id'],
      shopId: json['shopId'] ?? '',
      returnSequence: json['returnSequence'] ?? 0,
      productId: json['productId'] ?? 0,
      distributor: json['distributor'] ?? '',
      returnPrice: (json['returnPrice'] ?? 0).toDouble(),
      returnDate: _parseDate(json['returnDate']),
      quantity: json['quantity'] ?? 0,
      itemCategory: json['itemCategory'] ?? '',
      model: json['model'] ?? '',
      ram: json['ram'] ?? '',
      rom: json['rom'] ?? '',
      color: json['color'] ?? '',
      company: json['company'] ?? '',
      imei: json['imei'],
      source: json['source'] ?? '',
      reason: json['reason'] ?? '',
      notes: json['notes'],
      returnDocumentUrl: json['returnDocumentUrl'],
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'returnSequence': returnSequence,
      'productId': productId,
      'distributor': distributor,
      'returnPrice': returnPrice,
      'returnDate': returnDate.toIso8601String().split('T')[0],
      'quantity': quantity,
      'itemCategory': itemCategory,
      'model': model,
      'ram': ram,
      'rom': rom,
      'color': color,
      'company': company,
      'imei': imei,
      'source': source,
      'reason': reason,
      'notes': notes,
      'returnDocumentUrl': returnDocumentUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ProductReturnResponse {
  final List<ProductReturn> returnItems;
  final int totalPages;
  final int pageSize;
  final bool hasPrevious;
  final bool hasNext;
  final int currentPage;
  final int totalElements;

  ProductReturnResponse({
    required this.returnItems,
    required this.totalPages,
    required this.pageSize,
    required this.hasPrevious,
    required this.hasNext,
    required this.currentPage,
    required this.totalElements,
  });

  factory ProductReturnResponse.fromJson(Map<String, dynamic> json) {
    return ProductReturnResponse(
      returnItems: (json['returnItems'] as List<dynamic>?)
              ?.map((item) => ProductReturn.fromJson(item))
              .toList() ??
          [],
      totalPages: json['totalPages'] ?? 0,
      pageSize: json['pageSize'] ?? 0,
      hasPrevious: json['hasPrevious'] ?? false,
      hasNext: json['hasNext'] ?? false,
      currentPage: json['currentPage'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
    );
  }
}

