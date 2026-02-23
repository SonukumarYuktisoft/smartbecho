// Updated Customer Dues Response Model with Pagination
class CustomerDuesResponse {
  final String status;
  final String message;
  final PaginatedDuesPayload payload;
  final int statusCode;

  CustomerDuesResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory CustomerDuesResponse.fromJson(Map<String, dynamic> json) {
    return CustomerDuesResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: PaginatedDuesPayload.fromJson(json['payload'] ?? {}),
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
}

// Paginated Dues Payload
class PaginatedDuesPayload {
  final List<CustomerDue> content;
  final PageableInfo pageable;
  final bool last;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final int numberOfElements;
  final bool empty;
  final SortInfo sort;

  PaginatedDuesPayload({
    required this.content,
    required this.pageable,
    required this.last,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.numberOfElements,
    required this.empty,
    required this.sort,
  });

  factory PaginatedDuesPayload.fromJson(Map<String, dynamic> json) {
    return PaginatedDuesPayload(
      content: (json['content'] as List<dynamic>?)
          ?.map((item) => CustomerDue.fromJson(item))
          .toList() ?? [],
      pageable: PageableInfo.fromJson(json['pageable'] ?? {}),
      last: json['last'] ?? false,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      first: json['first'] ?? false,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? false,
      sort: SortInfo.fromJson(json['sort'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((item) => item.toJson()).toList(),
      'pageable': pageable.toJson(),
      'last': last,
      'totalElements': totalElements,
      'totalPages': totalPages,
      'size': size,
      'number': number,
      'first': first,
      'numberOfElements': numberOfElements,
      'empty': empty,
      'sort': sort.toJson(),
    };
  }
}

// Sort Info
class SortInfo {
  final bool empty;
  final bool sorted;
  final bool unsorted;

  SortInfo({
    required this.empty,
    required this.sorted,
    required this.unsorted,
  });

  factory SortInfo.fromJson(Map<String, dynamic> json) {
    return SortInfo(
      empty: json['empty'] ?? false,
      sorted: json['sorted'] ?? false,
      unsorted: json['unsorted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empty': empty,
      'sorted': sorted,
      'unsorted': unsorted,
    };
  }
}

// Pageable Info
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
      paged: json['paged'] ?? false,
      unpaged: json['unpaged'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'sort': sort.toJson(),
      'offset': offset,
      'paged': paged,
      'unpaged': unpaged,
    };
  }
}

// Partial Payment Model
class PartialPayment {
  final int id;
  final double paidAmount;
  final String paidDate;

  PartialPayment({
    required this.id,
    required this.paidAmount,
    required this.paidDate,
  });

  factory PartialPayment.fromJson(Map<String, dynamic> json) {
    return PartialPayment(
      id: json['id'] ?? 0,
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      paidDate: json['paidDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paidAmount': paidAmount,
      'paidDate': paidDate,
    };
  }
}

// Updated Customer Due Model according to new API response
class CustomerDue {
  final int id;
  final String shopId;
  final String? name;
  final String? profileUrl;
  final double totalDue;
  final double totalPaid;
  final double remainingDue;
  final String creationDate;
  final String? description;
  final int customerId;
  final int saleId;
  final List<PartialPayment> partialPayments;
  final DateTime? retrievalDate; // ✅ changed from List<int> to DateTime?

  CustomerDue({
    required this.id,
    required this.shopId,
    required this.name,
    this.profileUrl,
    required this.totalDue,
    required this.totalPaid,
    required this.remainingDue,
    required this.creationDate,
    this.description,
    required this.customerId,
    required this.saleId,
    required this.partialPayments,
    this.retrievalDate,
  });

  factory CustomerDue.fromJson(Map<String, dynamic> json) {
    return CustomerDue(
      id: json['id'] ?? 0,
      shopId: json['shopId'] ?? '',
      name: json['name'],
      profileUrl: json['profileUrl'],
      totalDue: (json['totalDue'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      remainingDue: (json['remainingDue'] ?? 0).toDouble(),
      creationDate: json['creationDate'] ?? '',
      description: json['description'],
      customerId: json['customerId'] ?? 0,
      saleId: json['saleId'] ?? 0,
      partialPayments: (json['partialPayments'] as List<dynamic>?)
              ?.map((item) => PartialPayment.fromJson(item))
              .toList() ??
          [],
      retrievalDate: json['retrivalDate'] != null
          ? DateTime.tryParse(json['retrivalDate'])
          : null, // ✅ safe parse
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'name': name,
      'profileUrl': profileUrl,
      'totalDue': totalDue,
      'totalPaid': totalPaid,
      'remainingDue': remainingDue,
      'creationDate': creationDate,
      'description': description,
      'customerId': customerId,
      'saleId': saleId,
      'partialPayments': partialPayments.map((e) => e.toJson()).toList(),
      'retrivalDate': retrievalDate?.toIso8601String(), // ✅ store as ISO string
    };
  }

  // Helper methods
  double get paymentProgress => totalDue > 0 ? (totalPaid / totalDue) * 100 : 0;
  
  // Payment status based on remainingDue
  bool get isFullyPaid => remainingDue <= 0;
  bool get isOverpaid => remainingDue < 0;
  bool get isPartiallyPaid => totalPaid > 0 && remainingDue > 0;
  bool get isUnpaid => totalPaid <= 0;
  
  String get statusText {
    if (isOverpaid) return 'Overpaid';
    if (isFullyPaid) return 'Paid';
    if (isPartiallyPaid) return 'Partially';
    if (isUnpaid) return 'Unpaid';
    return 'Unknown';
  }

  // Payment status color helper
  String get statusColor {
    if (isOverpaid) return '#FF9800'; // Orange
    if (isFullyPaid) return '#4CAF50'; // Green
    if (isPartiallyPaid) return '#2196F3'; // Blue
    if (isUnpaid) return '#F44336'; // Red
    return '#9E9E9E'; // Grey
  }

  // Get formatted dates
  String get formattedCreationDate {
    try {
      final date = DateTime.parse(creationDate);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return creationDate;
    }
  }

  String? get formattedRetrievalDate {
    if (retrievalDate == null) return null;
    return "${retrievalDate!.day.toString().padLeft(2, '0')}/${retrievalDate!.month.toString().padLeft(2, '0')}/${retrievalDate!.year}";
  }


  // Get payment summary
  String get paymentSummary {
    return "₹${totalPaid.toStringAsFixed(2)} / ₹${totalDue.toStringAsFixed(2)}";
  }

  // Get remaining amount formatted
  String get remainingAmountFormatted {
    if (remainingDue < 0) {
      return "Excess: ₹${(-remainingDue).toStringAsFixed(2)}";
    } else if (remainingDue == 0) {
      return "Fully Paid";
    } else {
      return "Remaining: ₹${remainingDue.toStringAsFixed(2)}";
    }
  }

  // Check if payment is due (you can customize this logic)
  bool get isOverdue {
    if (retrievalDate == null || isFullyPaid) return false;
    return DateTime.now().isAfter(retrievalDate!);
  }

  // Get days until due or overdue days
 int get daysUntilDue {
    if (retrievalDate == null || isFullyPaid) return 0;
    return retrievalDate!.difference(DateTime.now()).inDays;
  }

  String get dueDateStatus {
    if (isFullyPaid) return 'Paid';
    
    final days = daysUntilDue;
    if (days < 0) {
      return 'Overdue by ${(-days)} days';
    } else if (days == 0) {
      return 'Due today';
    } else if (days <= 7) {
      return 'Due in $days days';
    } else {
      return 'Due on $formattedRetrievalDate';
    }
  }

  // Calculate payment completion percentage
  double get completionPercentage {
    return totalDue > 0 ? (totalPaid / totalDue).clamp(0.0, 1.0) : 0.0;
  }

  // Check if has partial payments
  bool get hasPartialPayments => partialPayments.isNotEmpty;

  // Get latest payment date
  String? get latestPaymentDate {
    if (partialPayments.isEmpty) return null;
    
    try {
      final sortedPayments = List<PartialPayment>.from(partialPayments);
      sortedPayments.sort((a, b) => DateTime.parse(b.paidDate).compareTo(DateTime.parse(a.paidDate)));
      return sortedPayments.first.paidDate;
    } catch (e) {
      return partialPayments.last.paidDate;
    }
  }

  // Get total partial payments amount
  double get totalPartialPayments {
    return partialPayments.fold(0.0, (sum, payment) => sum + payment.paidAmount);
  }

  // Copy with method for updates
  CustomerDue copyWith({
    int? id,
    String? shopId,
    String? name,
    String? profileUrl,
    double? totalDue,
    double? totalPaid,
    double? remainingDue,
    String? creationDate,
    String? description,
    int? customerId,
    int? saleId,
    List<PartialPayment>? partialPayments,
    DateTime? retrievalDate,
  }) {
    return CustomerDue(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      name: name ?? this.name,
      profileUrl: profileUrl ?? this.profileUrl,
      totalDue: totalDue ?? this.totalDue,
      totalPaid: totalPaid ?? this.totalPaid,
      remainingDue: remainingDue ?? this.remainingDue,
      creationDate: creationDate ?? this.creationDate,
      description: description ?? this.description,
      customerId: customerId ?? this.customerId,
      saleId: saleId ?? this.saleId,
      partialPayments: partialPayments ?? this.partialPayments,
      retrievalDate: retrievalDate ?? this.retrievalDate,
    );
  }

  @override
  String toString() {
    return 'CustomerDue(id: $id, name: $name, totalDue: $totalDue, totalPaid: $totalPaid, remainingDue: $remainingDue, status: $statusText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerDue && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}