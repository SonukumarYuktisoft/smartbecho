import 'package:intl/intl.dart';

class EmiSettlement {
  final int id;
  final String companyName;
  final String date;
  final double amount;
  final String confirmedBy;
  final String shopId;

  EmiSettlement({
    required this.id,
    required this.companyName,
    required this.date,
    required this.amount,
    required this.confirmedBy,
    required this.shopId,
  });

  factory EmiSettlement.fromJson(Map<String, dynamic> json) {
    return EmiSettlement(
      id: json['id'] ?? 0,
      companyName: json['companyName'] ?? '',
      date: json['date'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      confirmedBy: json['confirmedBy'] ?? '',
      shopId: json['shopId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'date': date,
      'amount': amount,
      'confirmedBy': confirmedBy,
      'shopId': shopId,
    };
  }

 DateTime get formattedDate {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }

  String get formattedAmount {
    final formatter = NumberFormat('#,##,###.00', 'en_IN');
    return '₹${formatter.format(amount)}';
  }
}

class EmiSettlementsResponse {
  final List<EmiSettlement> content;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int size;
  final int number;
  final bool first;
  final bool empty;

  EmiSettlementsResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.size,
    required this.number,
    required this.first,
    required this.empty,
  });

  factory EmiSettlementsResponse.fromJson(Map<String, dynamic> json) {
    var payload = json['payload'] ?? {};
    
    return EmiSettlementsResponse(
      content: (payload['content'] as List<dynamic>? ?? [])
          .map((item) => EmiSettlement.fromJson(item))
          .toList(),
      totalElements: payload['totalElements'] ?? 0,
      totalPages: payload['totalPages'] ?? 0,
      last: payload['last'] ?? true,
      size: payload['size'] ?? 10,
      number: payload['number'] ?? 0,
      first: payload['first'] ?? true,
      empty: payload['empty'] ?? false,
    );
  }
}