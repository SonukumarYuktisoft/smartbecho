class Commission {
  final int id;
  final String date; 
  final String company;
  final double amount;
  final String receivedMode;
  final String confirmedBy;
  final String description;
  final String? uploadedFileUrl;

  Commission({
    required this.id,
    required this.date,
    required this.company,
    required this.amount,
    required this.receivedMode,
    required this.confirmedBy,
    required this.description,
    this.uploadedFileUrl,
  });

  factory Commission.fromJson(Map<String, dynamic> json) {
    return Commission(
      id: json['id'] ?? 0,
      date: json['date'] ?? '', // Changed to handle string date
      company: json['company'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      receivedMode: json['receivedMode'] ?? '',
      confirmedBy: json['confirmedBy'] ?? '',
      description: json['description'] ?? '',
      uploadedFileUrl: json['uploadedFileUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'company': company,
      'amount': amount,
      'receivedMode': receivedMode,
      'confirmedBy': confirmedBy,
      'description': description,
      'uploadedFileUrl': uploadedFileUrl,
    };
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

class CommissionsResponse {
  final List<Commission> content;
  final bool last;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final int numberOfElements;
  final bool empty;

  CommissionsResponse({
    required this.content,
    required this.last,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.numberOfElements,
    required this.empty,
  });

  factory CommissionsResponse.fromJson(Map<String, dynamic> json) {
    return CommissionsResponse(
      content: (json['content'] as List<dynamic>?)
              ?.map((item) => Commission.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      last: json['last'] ?? true,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      first: json['first'] ?? true,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((item) => item.toJson()).toList(),
      'last': last,
      'totalElements': totalElements,
      'totalPages': totalPages,
      'size': size,
      'number': number,
      'first': first,
      'numberOfElements': numberOfElements,
      'empty': empty,
    };
  }
}