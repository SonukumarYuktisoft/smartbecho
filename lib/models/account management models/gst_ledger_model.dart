import 'package:smartbecho/utils/helper/date_formatter_helper.dart';

class GstLedgerEntry {
  final int id;
  final String shopId;
  final String date;
  final String transactionType;
  final double taxableAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final String gstRateLabel;
  final String relatedEntityName;
  final String hsnCode;

  GstLedgerEntry({
    required this.id,
    required this.shopId,
    required this.date,
    required this.transactionType,
    required this.taxableAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.gstRateLabel,
    required this.relatedEntityName,
    required this.hsnCode,
  });

  factory GstLedgerEntry.fromJson(Map<String, dynamic> json) {
    return GstLedgerEntry(
      id: json['id'] ?? 0,
      shopId: json['shopId'] ?? '',
      date: json['date'] ?? '',
      transactionType: json['transactionType'] ?? '',
      taxableAmount: (json['taxableAmount'] ?? 0).toDouble(),
      cgstAmount: (json['cgstAmount'] ?? 0).toDouble(),
      sgstAmount: (json['sgstAmount'] ?? 0).toDouble(),
      igstAmount: (json['igstAmount'] ?? 0).toDouble(),
      gstRateLabel: json['gstRateLabel'] ?? '',
      relatedEntityName: json['relatedEntityName'] ?? '',
      hsnCode: json['hsn_code'] ?? 'NA',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'date': date,
      'transactionType': transactionType,
      'taxableAmount': taxableAmount,
      'cgstAmount': cgstAmount,
      'sgstAmount': sgstAmount,
      'igstAmount': igstAmount,
      'gstRateLabel': gstRateLabel,
      'relatedEntityName': relatedEntityName,
      'hsn_code': hsnCode,
    };
  }

  String get formattedTaxableAmount => '₹${taxableAmount.toStringAsFixed(2)}';
  String get formattedCgstAmount => '₹${cgstAmount.toStringAsFixed(2)}';
  String get formattedSgstAmount => '₹${sgstAmount.toStringAsFixed(2)}';
  String get formattedIgstAmount => '₹${igstAmount.toStringAsFixed(2)}';
  String get formattedTotalGst =>
      '₹${(cgstAmount + sgstAmount + igstAmount).toStringAsFixed(2)}';
  String get formattedTotalAmount =>
      '₹${(taxableAmount + cgstAmount + sgstAmount + igstAmount).toStringAsFixed(2)}';

  String get formattedDate {
    final dateTime = DateTime.parse(date);
    return DateFormatterHelper.format(dateTime);
  }
}

class GstLedgerResponse {
  final List<GstLedgerEntry> content;
  final Pageable pageable;
  final bool last;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final int numberOfElements;
  final bool empty;

  GstLedgerResponse({
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
  });

  factory GstLedgerResponse.fromJson(Map<String, dynamic> json) {
    var payload = json['payload'] ?? json;
    return GstLedgerResponse(
      content:
          (payload['content'] as List<dynamic>?)
              ?.map((item) => GstLedgerEntry.fromJson(item))
              .toList() ??
          [],
      pageable: Pageable.fromJson(payload['pageable'] ?? {}),
      last: payload['last'] ?? true,
      totalElements: payload['totalElements'] ?? 0,
      totalPages: payload['totalPages'] ?? 0,
      size: payload['size'] ?? 0,
      number: payload['number'] ?? 0,
      first: payload['first'] ?? true,
      numberOfElements: payload['numberOfElements'] ?? 0,
      empty: payload['empty'] ?? true,
    );
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
      paged: json['paged'] ?? true,
      unpaged: json['unpaged'] ?? false,
    );
  }
}

class Sort {
  final bool empty;
  final bool sorted;
  final bool unsorted;

  Sort({required this.empty, required this.sorted, required this.unsorted});

  factory Sort.fromJson(Map<String, dynamic> json) {
    return Sort(
      empty: json['empty'] ?? true,
      sorted: json['sorted'] ?? false,
      unsorted: json['unsorted'] ?? true,
    );
  }
}

class GstLedgerDropdowns {
  final List<String> hsnCodes;
  final List<String> entityNames;
  final List<String> transactionTypes;

  GstLedgerDropdowns({
    required this.hsnCodes,
    required this.entityNames,
    required this.transactionTypes,
  });

  factory GstLedgerDropdowns.fromJson(Map<String, dynamic> json) {
    var payload = json['payload'] ?? json;
    return GstLedgerDropdowns(
      hsnCodes: List<String>.from(payload['hsnCodes'] ?? []),
      entityNames: List<String>.from(payload['entityNames'] ?? []),
      transactionTypes: List<String>.from(payload['transactionTypes'] ?? []),
    );
  }
}

class MonthlyGstSummary {
  final int month;
  final double credit;
  final double debit;

  MonthlyGstSummary({
    required this.month,
    required this.credit,
    required this.debit,
  });

  factory MonthlyGstSummary.fromJson(Map<String, dynamic> json) {
    return MonthlyGstSummary(
      month: json['month'] as int,
      credit: (json['credit'] as num).toDouble(),
      debit: (json['debit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'month': month, 'credit': credit, 'debit': debit};
  }

  double get total => credit + debit;
}
