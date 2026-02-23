import 'package:intl/intl.dart';

class PaymentHistoryResponse {
  final String status;
  final String message;
  final PaymentHistoryPayload payload;
  final int statusCode;

  PaymentHistoryResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory PaymentHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: PaymentHistoryPayload.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class PaymentHistoryPayload {
  final List<PaymentHistory> content;
  final PageableInfo pageable;
  final bool last;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final SortInfo sort;
  final bool first;
  final int numberOfElements;
  final bool empty;

  PaymentHistoryPayload({
    required this.content,
    required this.pageable,
    required this.last,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.sort,
    required this.first,
    required this.numberOfElements,
    required this.empty,
  });

  factory PaymentHistoryPayload.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryPayload(
      content: (json['content'] as List?)
              ?.map((e) => PaymentHistory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pageable: PageableInfo.fromJson(json['pageable'] ?? {}),
      last: json['last'] ?? true,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 10,
      number: json['number'] ?? 0,
      sort: SortInfo.fromJson(json['sort'] ?? {}),
      first: json['first'] ?? true,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? true,
    );
  }
}

class PaymentHistory {
  final int? id;
  final int? userId;
  final int? subscriptionId;
  final String? period;
  final double? amount;
  final String? status;
  final String? txnId;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySubscriptionId;
  final double? baseAmount;
  final double? discountAmount;
  final int? promoCodeId;
  final String? receiptUrl;
  final double? gstRate;
  final double? gstAmount;
  final double? cgstAmount;
  final double? sgstAmount;
  final double? igstAmount;
  final double? amountBeforeGst;
  final String? createdAt;

  PaymentHistory({
    this.id,
    this.userId,
    this.subscriptionId,
    this.period,
    this.amount,
    this.status,
    this.txnId,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySubscriptionId,
    this.baseAmount,
    this.discountAmount,
    this.promoCodeId,
    this.receiptUrl,
    this.gstRate,
    this.gstAmount,
    this.cgstAmount,
    this.sgstAmount,
    this.igstAmount,
    this.amountBeforeGst,
    this.createdAt,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'],
      userId: json['userId'],
      subscriptionId: json['subscriptionId'],
      period: json['period'],
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'],
      txnId: json['txnId'],
      razorpayOrderId: json['razorpayOrderId'],
      razorpayPaymentId: json['razorpayPaymentId'],
      razorpaySubscriptionId: json['razorpaySubscriptionId'],
      baseAmount: (json['baseAmount'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      promoCodeId: json['promoCodeId'],
      receiptUrl: json['receiptUrl'],
      gstRate: (json['gstRate'] as num?)?.toDouble(),
      gstAmount: (json['gstAmount'] as num?)?.toDouble(),
      cgstAmount: (json['cgstAmount'] as num?)?.toDouble(),
      sgstAmount: (json['sgstAmount'] as num?)?.toDouble(),
      igstAmount: (json['igstAmount'] as num?)?.toDouble(),
      amountBeforeGst: (json['amountBeforeGst'] as num?)?.toDouble(),
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subscriptionId': subscriptionId,
      'period': period,
      'amount': amount,
      'status': status,
      'txnId': txnId,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySubscriptionId': razorpaySubscriptionId,
      'baseAmount': baseAmount,
      'discountAmount': discountAmount,
      'promoCodeId': promoCodeId,
      'receiptUrl': receiptUrl,
      'gstRate': gstRate,
      'gstAmount': gstAmount,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'amountBeforeGst': amountBeforeGst,
      'createdAt': createdAt,
    };
  }

  // ==================== HELPERS ====================

  /// Get payment status
  String get paymentStatus {
    return status?.toUpperCase() ?? 'UNKNOWN';
  }

  /// Check if payment is successful
  bool get isSuccess {
    return status?.toUpperCase() == 'SUCCESS';
  }

  /// Check if payment is pending
  bool get isPending {
    return status?.toUpperCase() == 'PENDING';
  }

  /// Check if payment failed
  bool get isFailed {
    return status?.toUpperCase() == 'FAILED';
  }

  /// Get formatted amount
  String get formattedAmount {
    if (amount == null) return '₹0.00';
    return '₹${amount!.toStringAsFixed(2)}';
  }

  /// Get formatted base amount
  String get formattedBaseAmount {
    if (baseAmount == null) return '₹0.00';
    return '₹${baseAmount!.toStringAsFixed(2)}';
  }

  /// Get formatted GST amount
  String get formattedGstAmount {
    if (gstAmount == null) return '₹0.00';
    return '₹${gstAmount!.toStringAsFixed(2)}';
  }

  /// Get formatted discount
  String get formattedDiscount {
    if (discountAmount == null || discountAmount == 0) return 'No discount';
    return '₹${discountAmount!.toStringAsFixed(2)}';
  }

  /// Get GST breakdown
  String get gstBreakdown {
    final cgst = cgstAmount ?? 0.0;
    final sgst = sgstAmount ?? 0.0;
    final igst = igstAmount ?? 0.0;

    if (cgst > 0 && sgst > 0) {
      return 'CGST: ₹${cgst.toStringAsFixed(2)} + SGST: ₹${sgst.toStringAsFixed(2)}';
    } else if (igst > 0) {
      return 'IGST: ₹${igst.toStringAsFixed(2)}';
    }
    return '';
  }

  /// Get formatted period
  String get formattedPeriod {
    if (period == null) return 'Unknown';
    return period == 'MONTHLY' ? 'Monthly' : 'Yearly';
  }

  /// Get formatted date
  String get formattedDate {
    if (createdAt == null) return 'N/A';
    try {
      final date = DateTime.parse(createdAt!);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (e) {
      return createdAt!;
    }
  }

  /// Get short date
  String get shortDate {
    if (createdAt == null) return 'N/A';
    try {
      final date = DateTime.parse(createdAt!);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return createdAt!;
    }
  }

  /// Get payment method
  String get paymentMethod {
    if (razorpayPaymentId != null) return 'Razorpay';
    return 'Unknown';
  }

  /// Get transaction identifier (last 8 chars)
  String get transactionIdShort {
    if (txnId == null) return 'N/A';
    return txnId!.length > 8
        ? '${txnId!.substring(0, 4)}...${txnId!.substring(txnId!.length - 4)}'
        : txnId!;
  }
}

class PageableInfo {
  final int pageNumber;
  final int pageSize;
  final SortInfo sort;
  final int offset;
  final bool paged;
  final bool unpaged;

  PageableInfo({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory PageableInfo.fromJson(Map<String, dynamic> json) {
    return PageableInfo(
      pageNumber: json['pageNumber'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      sort: SortInfo.fromJson(json['sort'] ?? {}),
      offset: json['offset'] ?? 0,
      paged: json['paged'] ?? true,
      unpaged: json['unpaged'] ?? false,
    );
  }
}

class SortInfo {
  final bool sorted;
  final bool empty;
  final bool unsorted;

  SortInfo({
    required this.sorted,
    required this.empty,
    required this.unsorted,
  });

  factory SortInfo.fromJson(Map<String, dynamic> json) {
    return SortInfo(
      sorted: json['sorted'] ?? false,
      empty: json['empty'] ?? true,
      unsorted: json['unsorted'] ?? true,
    );
  }
}