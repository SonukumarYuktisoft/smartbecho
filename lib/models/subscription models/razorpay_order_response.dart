class RazorpayOrderResponse {
  final int amount;
  final int amountPaid;
  final int amountDue;
  final String currency;
  final String? receipt;
  final String id;
  final String entity;
  final String? offerId;
  final int attempts;
  final String status;
  final int createdAt;
  final dynamic notes;

  RazorpayOrderResponse({
    required this.amount,
    required this.amountPaid,
    required this.amountDue,
    required this.currency,
    this.receipt,
    required this.id,
    required this.entity,
    this.offerId,
    required this.attempts,
    required this.status,
    required this.createdAt,
    this.notes,
  });

  factory RazorpayOrderResponse.fromJson(Map<String, dynamic> json) {
    return RazorpayOrderResponse(
      amount: json['amount'] ?? 0,
      amountPaid: json['amount_paid'] ?? 0,
      amountDue: json['amount_due'] ?? 0,
      currency: json['currency'] ?? 'INR',
      receipt: json['receipt'],
      id: json['id'] ?? '',
      entity: json['entity'] ?? 'order',
      offerId: json['offer_id'],
      attempts: json['attempts'] ?? 0,
      status: json['status'] ?? 'created',
      createdAt: json['created_at'] ?? 0,
      notes: json['notes'], // Can be array [] or object {}
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'amount_paid': amountPaid,
      'amount_due': amountDue,
      'currency': currency,
      'receipt': receipt,
      'id': id,
      'entity': entity,
      'offer_id': offerId,
      'attempts': attempts,
      'status': status,
      'created_at': createdAt,
      'notes': notes,
    };
  }
}