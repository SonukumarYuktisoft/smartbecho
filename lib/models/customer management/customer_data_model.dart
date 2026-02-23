// models/customer_management/customer_model.dart

class CustomerResponse {
  final String status;
  final String message;
  final CustomerPayload payload;
  final int statusCode;

  CustomerResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: CustomerPayload.fromJson(json['payload'] ?? {}),
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

class CustomerPayload {
  final List<Customer> content;
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

  CustomerPayload({
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

  factory CustomerPayload.fromJson(Map<String, dynamic> json) {
    return CustomerPayload(
      content: (json['content'] as List<dynamic>?)
              ?.map((item) => Customer.fromJson(item))
              .toList() ??
          [],
      pageable: Pageable.fromJson(json['pageable'] ?? {}),
      last: json['last'] ?? false,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      sort: Sort.fromJson(json['sort'] ?? {}),
      first: json['first'] ?? false,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? true,
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
      'sort': sort.toJson(),
      'first': first,
      'numberOfElements': numberOfElements,
      'empty': empty,
    };
  }
}

class Customer {
  final int id;
  final String name;
  final String primaryPhone;
  final String primaryAddress;
  final String location;
  final String profilePhotoUrl;
  final List<String> alternatePhones;
  final double totalDues;
  final double totalPurchase;

  Customer({
    required this.id,
    required this.name,
    required this.primaryPhone,
    required this.primaryAddress,
    required this.location,
    required this.profilePhotoUrl,
    required this.alternatePhones,
    required this.totalDues,
    required this.totalPurchase,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      primaryPhone: json['primaryPhone'] ?? '',
      primaryAddress: json['primaryAddress'] ?? '',
      location: json['location'] ?? '',
      profilePhotoUrl: json['profilePhotoUrl'] ?? '',
      alternatePhones: (json['alternatePhones'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      totalDues: (json['totalDues'] ?? 0.0).toDouble(),
      totalPurchase: (json['totalPurchase'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryPhone': primaryPhone,
      'primaryAddress': primaryAddress,
      'location': location,
      'profilePhotoUrl': profilePhotoUrl,
      'alternatePhones': alternatePhones,
      'totalDues': totalDues,
      'totalPurchase': totalPurchase,
    };
  }

  // Helper method to get customer type based on purchase amount
  String get customerType {
    if (totalPurchase == 0) return 'New';
    if (totalPurchase > 50000) return 'VIP';
    if (totalPurchase > 20000) return 'Repeated';
    return 'Regular';
  }

  // Helper method to get formatted total purchase
  String get formattedTotalPurchase {
    return '₹${totalPurchase.toStringAsFixed(0)}';
  }

  // Helper method to get formatted total dues
  String get formattedTotalDues {
    return '₹${totalDues.toStringAsFixed(0)}';
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
      pageSize: json['pageSize'] ?? 0,
      sort: Sort.fromJson(json['sort'] ?? {}),
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
      empty: json['empty'] ?? true,
      sorted: json['sorted'] ?? false,
      unsorted: json['unsorted'] ?? true,
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