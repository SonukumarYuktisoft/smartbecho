class TransactionListModel {
  final String status;
  final String message;
  final Payload payload;
  final int statusCode;

  TransactionListModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory TransactionListModel.fromJson(Map<String, dynamic> json) {
    return TransactionListModel(
      status: json['status'] ?? "",
      message: json['message'] ?? "",
      payload: Payload.fromJson(json['payload']),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class Payload {
  final List<Transaction> content;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int size;
  final int number;
  final int numberOfElements;
  final bool first;
  final bool empty;

  Payload({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.size,
    required this.number,
    required this.numberOfElements,
    required this.first,
    required this.empty,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      content: List<Transaction>.from(
          json['content'].map((x) => Transaction.fromJson(x))),
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      last: json['last'] ?? false,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      numberOfElements: json['numberOfElements'] ?? 0,
      first: json['first'] ?? false,
      empty: json['empty'] ?? false,
    );
  }
}

class Transaction {
  final int id;
  final String entityName;
  final int entityId;
  final String? description;
  final String transactionType;
  final String paymentAccountType;
  final double amount;
  final double? gstAmount;
  final String date;
  final String shopId;
  final String createdAt;
  final String updatedAt;

  Transaction({
    required this.id,
    required this.entityName,
    required this.entityId,
    this.description,
    required this.transactionType,
    required this.paymentAccountType,
    required this.amount,
    this.gstAmount,
    required this.date,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      entityName: json['entityName'] ?? "",
      entityId: json['entityId'] ?? 0,
      description: json['description'],
      transactionType: json['transactionType'] ?? "",
      paymentAccountType: json['paymentAccountType'] ?? "",
      amount: (json['amount'] ?? 0).toDouble(),
      gstAmount: json['gstAmount'] != null ? (json['gstAmount']).toDouble() : null,
      date: json['date'] ?? "",
      shopId: json['shopId'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
    );
  }
}
