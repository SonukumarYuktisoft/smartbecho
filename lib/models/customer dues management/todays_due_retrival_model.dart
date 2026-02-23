// Model for individual due entry
class DueDetails {
  final int id;
  final double totalDue;
  final double totalPaid;
  final double remainingDue;
  final DateTime? creationDate;          // ✅ changed to DateTime
  final DateTime? paymentRetriableDate;  // ✅ changed to DateTime
  final bool paid;

  DueDetails({
    required this.id,
    required this.totalDue,
    required this.totalPaid,
    required this.remainingDue,
    this.creationDate,
    this.paymentRetriableDate,
    required this.paid,
  });

  factory DueDetails.fromJson(Map<String, dynamic> json) {
    return DueDetails(
      id: json['id'] ?? 0,
      totalDue: (json['totalDue'] ?? 0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      remainingDue: (json['remainingDue'] ?? 0).toDouble(),
      creationDate: json['creationDate'] != null
          ? DateTime.tryParse(json['creationDate'])
          : null,
      paymentRetriableDate: json['paymentRetriableDate'] != null
          ? DateTime.tryParse(json['paymentRetriableDate'])
          : null,
      paid: json['paid'] ?? false,
    );
  }

  // Helper method to get formatted creation date
  String get formattedCreationDate {
    if (creationDate == null) return 'N/A';
    return "${creationDate!.day.toString().padLeft(2, '0')}/"
           "${creationDate!.month.toString().padLeft(2, '0')}/"
           "${creationDate!.year}";
  }

  // Helper method to get formatted payment retriable date
  String get formattedPaymentRetriableDate {
    if (paymentRetriableDate == null) return 'N/A';
    return "${paymentRetriableDate!.day.toString().padLeft(2, '0')}/"
           "${paymentRetriableDate!.month.toString().padLeft(2, '0')}/"
           "${paymentRetriableDate!.year}";
  }

  // Helper method to get days since due
  int get daysSinceDue {
    if (paymentRetriableDate == null) return 0;
    return DateTime.now().difference(paymentRetriableDate!).inDays;
  }
}

// Model for customer with dues
class RetrievalDueCustomer {
  final int id;
  final String name;
  final String? email;
  final String primaryPhone;
  final String location;
  final String primaryAddress;
  final List<DueDetails> duesList;

  RetrievalDueCustomer({
    required this.id,
    required this.name,
    this.email,
    required this.primaryPhone,
    required this.location,
    required this.primaryAddress,
    required this.duesList,
  });

  factory RetrievalDueCustomer.fromJson(Map<String, dynamic> json) {
    return RetrievalDueCustomer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      primaryPhone: json['primaryPhone'] ?? '',
      location: json['location'] ?? '',
      primaryAddress: json['primaryAddress'] ?? '',
      duesList: (json['duesList'] as List<dynamic>?)
              ?.map((item) => DueDetails.fromJson(item))
              .toList() ??
          [],
    );
  }

  // Aggregated dues
  DueDetails get dues {
    if (duesList.isEmpty) {
      return DueDetails(
        id: 0,
        totalDue: 0.0,
        totalPaid: 0.0,
        remainingDue: 0.0,
        creationDate: null,
        paymentRetriableDate: null,
        paid: true,
      );
    }

    double totalDue = duesList.fold(0.0, (sum, d) => sum + d.totalDue);
    double totalPaid = duesList.fold(0.0, (sum, d) => sum + d.totalPaid);
    double remainingDue = duesList.fold(0.0, (sum, d) => sum + d.remainingDue);

    // Find earliest retriable date
    DateTime? earliestDate;
    for (var due in duesList) {
      if (due.paymentRetriableDate != null) {
        if (earliestDate == null || due.paymentRetriableDate!.isBefore(earliestDate)) {
          earliestDate = due.paymentRetriableDate;
        }
      }
    }

    return DueDetails(
      id: duesList.first.id,
      totalDue: totalDue,
      totalPaid: totalPaid,
      remainingDue: remainingDue,
      creationDate: duesList.first.creationDate,
      paymentRetriableDate: earliestDate,
      paid: remainingDue <= 0,
    );
  }

  // Status helpers
  String get status {
    if (dues.remainingDue <= 0) return 'Paid';
    if (dues.daysSinceDue > 0) return 'Overdue';
    return 'Due Today';
  }

  String get statusColor {
    if (dues.remainingDue <= 0) return '#51CF66'; // Green
    if (dues.daysSinceDue > 0) return '#FF6B6B'; // Red
    return '#FF9500'; // Orange
  }
}

// Model for API response
class RetrievalDueResponse {
  final String status;
  final String message;
  final RetrievalDuePayload payload;
  final int statusCode;

  RetrievalDueResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory RetrievalDueResponse.fromJson(Map<String, dynamic> json) {
    return RetrievalDueResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: RetrievalDuePayload.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

// Model for payload
class RetrievalDuePayload {
  final List<RetrievalDueCustomer> customers;
  final int totalCount;

  RetrievalDuePayload({
    required this.customers,
    required this.totalCount,
  });

  factory RetrievalDuePayload.fromJson(Map<String, dynamic> json) {
    return RetrievalDuePayload(
      customers: (json['customers'] as List<dynamic>?)
              ?.map((item) => RetrievalDueCustomer.fromJson(item))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
    );
  }
}
