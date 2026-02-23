// repeated_customer_model.dart

class RepeatedCustomerResponse {
  final String status;
  final String message;
  final RepeatedCustomerPayload payload;
  final int statusCode;

  RepeatedCustomerResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory RepeatedCustomerResponse.fromJson(Map<String, dynamic> json) {
    return RepeatedCustomerResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: RepeatedCustomerPayload.fromJson(json['payload'] ?? {}),
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

class RepeatedCustomerPayload {
  final int totalCustomers;
  final int repeatedCustomers;
  final int newCustomersThisMonth;
  final List<RepeatedCustomer> repeatedCustomerList;

  RepeatedCustomerPayload({
    required this.totalCustomers,
    required this.repeatedCustomers,
    required this.newCustomersThisMonth,
    required this.repeatedCustomerList,
  });

  factory RepeatedCustomerPayload.fromJson(Map<String, dynamic> json) {
    return RepeatedCustomerPayload(
      totalCustomers: json['totalCustomers'] ?? 0,
      repeatedCustomers: json['repeatedCustomers'] ?? 0,
      newCustomersThisMonth: json['newCustomersThisMonth'] ?? 0,
      repeatedCustomerList: (json['repeatedCustomerList'] as List<dynamic>?)
              ?.map((item) => RepeatedCustomer.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCustomers': totalCustomers,
      'repeatedCustomers': repeatedCustomers,
      'newCustomersThisMonth': newCustomersThisMonth,
      'repeatedCustomerList': repeatedCustomerList.map((item) => item.toJson()).toList(),
    };
  }
}

class RepeatedCustomer {
  final int id;
  final String name;
  final String primaryPhone;
  final String? email;
  final String location;

  RepeatedCustomer({
    required this.id,
    required this.name,
    required this.primaryPhone,
    this.email,
    required this.location,
  });

  factory RepeatedCustomer.fromJson(Map<String, dynamic> json) {
    return RepeatedCustomer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      primaryPhone: json['primaryPhone'] ?? '',
      email: json['email'],
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryPhone': primaryPhone,
      'email': email,
      'location': location,
    };
  }
}