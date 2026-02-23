class PayBillsResponse {
  final List<PayBill> content;
  final Pageable pageable;
  final bool last;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final Sort sort;
  final bool first;
  final int numberOfElements;
  final bool empty;

  PayBillsResponse({
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

  factory PayBillsResponse.fromJson(Map<String, dynamic> json) {
    return PayBillsResponse(
      content: (json['content'] as List)
          .map((item) => PayBill.fromJson(item))
          .toList(),
      pageable: Pageable.fromJson(json['pageable']),
      last: json['last'] ?? false,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      sort: Sort.fromJson(json['sort']),
      first: json['first'] ?? false,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? false,
    );
  }
}

class PayBill {
  final int id;
  final String date; // Changed from List<int> to String
  final String company;
  final String paidToPerson;
  final String purpose;
  final String paidBy;
  final double amount;
  final String paymentMode;
  final String description;
  final String uploadedFileUrl;

  PayBill({
    required this.id,
    required this.date,
    required this.company,
    required this.paidToPerson,
    required this.purpose,
    required this.paidBy,
    required this.amount,
    required this.paymentMode,
    required this.description,
    required this.uploadedFileUrl,
  });

  factory PayBill.fromJson(Map<String, dynamic> json) {
    return PayBill(
      id: json['id'] ?? 0,
      date: json['date'] ?? '', // Changed to handle string date
      company: json['company'] ?? '',
      paidToPerson: json['paidToPerson'] ?? '',
      purpose: json['purpose'] ?? '',
      paidBy: json['paidBy'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMode: json['paymentMode'] ?? '',
      description: json['description'] ?? '',
      uploadedFileUrl: json['uploadedFileUrl'] ?? '',
    );
  }

  // Updated to parse string date format
  DateTime get formattedDate {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedAmount {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }
}

class Pageable {
  final int pageNumber;
  final int pageSize;
  final Sort sort;
  final int offset;
  final bool paged;
  final bool unpaged;

  Pageable({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) {
    return Pageable(
      pageNumber: json['pageNumber'] ?? 0,
      pageSize: json['pageSize'] ?? 10,
      sort: Sort.fromJson(json['sort'] ?? {}),
      offset: json['offset'] ?? 0,
      paged: json['paged'] ?? false,
      unpaged: json['unpaged'] ?? false,
    );
  }
}

class Sort {
  final bool empty;
  final bool sorted;
  final bool unsorted;

  Sort({
    required this.empty,
    required this.sorted,
    required this.unsorted,
  });

  factory Sort.fromJson(Map<String, dynamic> json) {
    return Sort(
      empty: json['empty'] ?? false,
      sorted: json['sorted'] ?? false,
      unsorted: json['unsorted'] ?? false,
    );
  }
}