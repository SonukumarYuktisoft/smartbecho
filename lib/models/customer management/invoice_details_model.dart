// models/invoice_details_model.dart

class InvoiceDetailsModel {
  final int saleId;
  final String shopId;
  final String shopName;
  final String invoiceNumber;
  final String saleDate;
  final double totalPayableAmount;
  final String customerName;
  final List<InvoiceItem> items;
  final InvoiceDues? dues;
  final InvoiceEmi? emi;

  InvoiceDetailsModel({
    required this.saleId,
    required this.shopId,
    required this.shopName,
    required this.invoiceNumber,
    required this.saleDate,
    required this.totalPayableAmount,
    required this.customerName,
    required this.items,
    this.dues,
    this.emi,
  });

  factory InvoiceDetailsModel.fromJson(Map<String, dynamic> json) {
    return InvoiceDetailsModel(
      saleId: json['saleId'] ?? 0,
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      saleDate: json['saleDate'] ?? '',
      totalPayableAmount: (json['totalPayableAmount'] ?? 0.0).toDouble(),
      customerName: json['customerName'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => InvoiceItem.fromJson(item))
              .toList() ??
          [],
      dues: json['dues'] != null ? InvoiceDues.fromJson(json['dues']) : null,
      emi: json['emi'] != null ? InvoiceEmi.fromJson(json['emi']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'saleId': saleId,
      'shopId': shopId,
      'shopName': shopName,
      'invoiceNumber': invoiceNumber,
      'saleDate': saleDate,
      'totalPayableAmount': totalPayableAmount,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'dues': dues?.toJson(),
      'emi': emi?.toJson(),
    };
  }

  // Calculated getters
  double get totalAmount {
    return items.fold(0.0, (sum, item) => sum + (item.sellingPrice * item.quantity));
  }

  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  String get formattedSaleDate {
    try {
      DateTime dateTime = DateTime.parse(saleDate);
      return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
    } catch (e) {
      return saleDate;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  String get paymentStatus {
    if (dues == null) return 'Unknown';
    if (dues!.paid) return 'Paid';
    if (dues!.remainingDue <= 0) return 'Paid';
    if (dues!.totalPaid > 0) return 'Partial';
    return 'Unpaid';
  }

  double get paymentProgress {
    if (dues == null || dues!.totalDue <= 0) return 0.0;
    return (dues!.totalPaid / dues!.totalDue).clamp(0.0, 1.0);
  }
}

class InvoiceItem {
  final String model;
  final String color;
  final String ram;
  final String rom;
  final int quantity;
  final double sellingPrice;
  final String accessoryName;
  final bool accessoryIncluded;

  InvoiceItem({
    required this.model,
    required this.color,
    required this.ram,
    required this.rom,
    required this.quantity,
    required this.sellingPrice,
    required this.accessoryName,
    required this.accessoryIncluded,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      ram: json['ram']?.toString() ?? '',
      rom: json['rom']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      sellingPrice: (json['sellingPrice'] ?? 0.0).toDouble(),
      accessoryName: json['accessoryName'] ?? '',
      accessoryIncluded: json['accessoryIncluded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'color': color,
      'ram': ram,
      'rom': rom,
      'quantity': quantity,
      'sellingPrice': sellingPrice,
      'accessoryName': accessoryName,
      'accessoryIncluded': accessoryIncluded,
    };
  }

  String get specifications {
    return '$color | $ram RAM | $rom Storage';
  }

  double get totalPrice {
    return sellingPrice * quantity;
  }

  String get formattedPrice {
    return '₹${sellingPrice.toStringAsFixed(0)}';
  }

  String get formattedTotalPrice {
    return '₹${totalPrice.toStringAsFixed(0)}';
  }
}

class InvoiceDues {
  final int id;
  final dynamic customer;
  final String shopId;
  final double totalDue;
  final double totalPaid;
  final double remainingDue;
  final List<PartialPayment> partialPayments;
  final String creationDate; // Changed from List<int> to String
  final String paymentRetriableDate; // Changed from List<int> to String
  final dynamic approvedBy;
  final bool paid;

  InvoiceDues({
    required this.id,
    this.customer,
    required this.shopId,
    required this.totalDue,
    required this.totalPaid,
    required this.remainingDue,
    required this.partialPayments,
    required this.creationDate,
    required this.paymentRetriableDate,
    this.approvedBy,
    required this.paid,
  });

  factory InvoiceDues.fromJson(Map<String, dynamic> json) {
    return InvoiceDues(
      id: json['id'] ?? 0,
      customer: json['customer'],
      shopId: json['shopId'] ?? '',
      totalDue: (json['totalDue'] ?? 0.0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0.0).toDouble(),
      remainingDue: (json['remainingDue'] ?? 0.0).toDouble(),
      partialPayments: (json['partialPayments'] as List<dynamic>?)
              ?.map((payment) => PartialPayment.fromJson(payment))
              .toList() ??
          [],
      creationDate: json['creationDate']?.toString() ?? '', // Handle as String
      paymentRetriableDate: json['paymentRetriableDate']?.toString() ?? '', // Handle as String
      approvedBy: json['approvedBy'],
      paid: json['paid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customer,
      'shopId': shopId,
      'totalDue': totalDue,
      'totalPaid': totalPaid,
      'remainingDue': remainingDue,
      'partialPayments': partialPayments.map((payment) => payment.toJson()).toList(),
      'creationDate': creationDate,
      'paymentRetriableDate': paymentRetriableDate,
      'approvedBy': approvedBy,
      'paid': paid,
    };
  }

  String get formattedTotalDue {
    return '₹${totalDue.toStringAsFixed(0)}';
  }

  String get formattedTotalPaid {
    return '₹${totalPaid.toStringAsFixed(0)}';
  }

  String get formattedRemainingDue {
    return '₹${remainingDue.toStringAsFixed(0)}';
  }

  String get formattedCreationDate {
    try {
      // Try to parse as DateTime string
      DateTime dateTime = DateTime.parse(creationDate);
      return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
    } catch (e) {
      return creationDate;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  List<PartialPayment> get validPayments {
    return partialPayments;
  }

  double get paymentProgress {
    if (totalDue <= 0) return 0.0;
    return (totalPaid / totalDue).clamp(0.0, 1.0);
  }
}

class PartialPayment {
  final int id;
  final double paidAmount;
  final String paidDate; // Changed from List<int> to String
  final dynamic paymentMethod;

  PartialPayment({
    required this.id,
    required this.paidAmount,
    required this.paidDate,
    this.paymentMethod,
  });

  factory PartialPayment.fromJson(Map<String, dynamic> json) {
    return PartialPayment(
      id: json['id'] ?? 0,
      paidAmount: (json['paidAmount'] ?? 0.0).toDouble(),
      paidDate: json['paidDate']?.toString() ?? '', // Handle as String
      paymentMethod: json['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paidAmount': paidAmount,
      'paidDate': paidDate,
      'paymentMethod': paymentMethod,
    };
  }

  String get formattedPaidAmount {
    return '₹${paidAmount.toStringAsFixed(0)}';
  }

  String get formattedPaidDate {
    try {
      // Try to parse as DateTime string
      DateTime dateTime = DateTime.parse(paidDate);
      return "${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year}";
    } catch (e) {
      return paidDate;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class InvoiceEmi {
  final int? id;
  final double? emiAmount;
  final int? totalInstallments;
  final int? paidInstallments;

  InvoiceEmi({
    this.id,
    this.emiAmount,
    this.totalInstallments,
    this.paidInstallments,
  });

  factory InvoiceEmi.fromJson(Map<String, dynamic> json) {
    return InvoiceEmi(
      id: json['id'],
      emiAmount: (json['emiAmount'] ?? 0.0).toDouble(),
      totalInstallments: json['totalInstallments'],
      paidInstallments: json['paidInstallments'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emiAmount': emiAmount,
      'totalInstallments': totalInstallments,
      'paidInstallments': paidInstallments,
    };
  }
}