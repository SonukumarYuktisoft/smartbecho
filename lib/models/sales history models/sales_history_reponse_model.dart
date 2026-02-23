// ========================================
// SALE MODEL
// ========================================
class Sale {
  final int saleId;
  final int shopSaleId;
  final int customerId;
  final String companName;
  final int quantity;
  final String companyModel;
  final String invoiceNumber;
  final String customerName;
  final String variant;
  final String color;
  final String paymentMethod;
  final String paymentMode;
  final DateTime saleDate;
  final String? invoicePdfUrl; // ✅ Nullable
  final double amount;

  Sale({
    required this.saleId,
    required this.shopSaleId,
    required this.customerId,
    required this.companName,
    required this.quantity,
    required this.companyModel,
    required this.invoiceNumber,
    required this.customerName,
    required this.variant,
    required this.color,
    required this.paymentMethod,
    required this.paymentMode,
    required this.saleDate,
    this.invoicePdfUrl, // ✅ Nullable
    required this.amount,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      saleId: json['saleId'] ?? 0,
      shopSaleId: json['shopSaleId'] ?? 0,
      customerId: json['customerId'] ?? 0,
      companName: json['companName'] ?? '',
      quantity: json['quantity'] ?? 0,
      companyModel: json['companyModel'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      variant: json['variant'] ?? '',
      color: json['color'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentMode: json['paymentMode'] ?? '',
      saleDate: json['saleDate'] != null
          ? DateTime.parse(json['saleDate'])
          : DateTime.now(),
      invoicePdfUrl: json['invoicePdfUrl'], // ✅ Can be null
      amount: _parseAmount(json['amount']),
    );
  }

  // ✅ Helper method to parse amount safely
  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'saleId': saleId,
      'shopSaleId': shopSaleId,
      'customerId': customerId,
      'companName': companName,
      'quantity': quantity,
      'companyModel': companyModel,
      'invoiceNumber': invoiceNumber,
      'customerName': customerName,
      'variant': variant,
      'color': color,
      'paymentMethod': paymentMethod,
      'paymentMode': paymentMode,
      'saleDate': saleDate.toIso8601String(),
      'invoicePdfUrl': invoicePdfUrl,
      'amount': amount.toString(),
    };
  }

  // Helper getters
  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';
  
  String get formattedDate => '${saleDate.day.toString().padLeft(2, '0')}/'
      '${saleDate.month.toString().padLeft(2, '0')}/'
      '${saleDate.year}';
  
  String get formattedTime => '${saleDate.hour.toString().padLeft(2, '0')}:'
      '${saleDate.minute.toString().padLeft(2, '0')}';
  
  String get formattedDateTime => '$formattedDate at $formattedTime';
  
  String  get invoiceUrl => invoicePdfUrl ??'';
  
  String get invoiceFileName => 'Invoice_$invoiceNumber.pdf';
  
  bool get hasInvoicePdf => invoicePdfUrl != null && invoicePdfUrl!.isNotEmpty;
  
  String get paymentStatusDisplay => paymentMode == 'FULL' ? 'Paid' : 'Partial';
  
  String get productFullName => '$companName $companyModel';
  
  String get variantDisplay => variant.isNotEmpty ? 'Variant: $variant' : '';
  
  String get colorDisplay => color.isNotEmpty ? 'Color: $color' : '';
}

// ========================================
// SALES SUMMARY MODEL
// ========================================
class SalesSummary {
  final int totalQuantity;
  final double totalPayableAmount;

  SalesSummary({
    required this.totalQuantity,
    required this.totalPayableAmount,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    return SalesSummary(
      totalQuantity: json['totalQuantity'] ?? 0,
      totalPayableAmount: _parseAmount(json['totalPayableAmount']),
    );
  }

  static double _parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalQuantity': totalQuantity,
      'totalPayableAmount': totalPayableAmount,
    };
  }

  String get formattedTotalAmount => '₹${totalPayableAmount.toStringAsFixed(2)}';
}

// ========================================
// SALES HISTORY PAYLOAD MODEL
// ========================================
class SalesHistoryPayload {
  final SalesSummary summary;
  final List<Sale> content;
  final int totalElements;
  final int totalPages;
  final int pageNumber;
  final int pageSize;
  final bool last;
  final bool first;
  final bool empty;

  SalesHistoryPayload({
    required this.summary,
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.pageNumber,
    required this.pageSize,
    required this.last,
    required this.first,
    required this.empty,
  });

  factory SalesHistoryPayload.fromJson(Map<String, dynamic> json) {
    final pageData = json['page'] ?? {};
    
    return SalesHistoryPayload(
      summary: json['summary'] != null
          ? SalesSummary.fromJson(json['summary'])
          : SalesSummary(totalQuantity: 0, totalPayableAmount: 0.0),
      content: (pageData['content'] as List?)
              ?.map((item) => Sale.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalElements: pageData['totalElements'] ?? 0,
      totalPages: pageData['totalPages'] ?? 1,
      pageNumber: pageData['number'] ?? 0,
      pageSize: pageData['size'] ?? 10,
      last: pageData['last'] ?? true,
      first: pageData['first'] ?? true,
      empty: pageData['empty'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'page': {
        'content': content.map((e) => e.toJson()).toList(),
        'totalElements': totalElements,
        'totalPages': totalPages,
        'number': pageNumber,
        'size': pageSize,
        'last': last,
        'first': first,
        'empty': empty,
      },
    };
  }

  bool get hasContent => content.isNotEmpty;
  bool get hasMorePages => !last;
  int get nextPage => pageNumber + 1;
}

// ========================================
// SALES HISTORY RESPONSE MODEL
// ========================================
class SalesHistoryResponse {
  final String status;
  final String message;
  final SalesHistoryPayload payload;
  final int statusCode;

  SalesHistoryResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory SalesHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SalesHistoryResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: SalesHistoryPayload.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload.toJson(),
      'statusCode': statusCode,
    };
  }

  bool get isSuccess => status.toLowerCase() == 'success' && statusCode == 200;
}

