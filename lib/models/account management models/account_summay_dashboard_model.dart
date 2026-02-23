class AccountSummaryDashboardModel {
  final String status;
  final String message;
  final Payload payload;
  final int statusCode;

  AccountSummaryDashboardModel({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory AccountSummaryDashboardModel.fromJson(Map<String, dynamic> json) {
    return AccountSummaryDashboardModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: Payload.fromJson(json['payload']),

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

class Payload {
  final String shopId;
  final DateTime date;
  final double openingBalance;
  final double totalCredit;
  final double totalDebit;
  final double closingBalance;
  final Sale sale;
  final double emiReceivedToday;
  final double duesRecovered;
  final double directGivenDues;
  final double payBills;
  final double withdrawals;
  final double commissionReceived;
  final Gst gst;
  final Map<String, double> creditByAccount;
  final Map<String, double> debitByAccount;

  Payload({
    required this.shopId,
    required this.date,
    required this.openingBalance,
    required this.totalCredit,
    required this.totalDebit,
    required this.closingBalance,
    required this.sale,
    required this.emiReceivedToday,
    required this.duesRecovered,
    required this.directGivenDues,
    required this.payBills,
    required this.withdrawals,
    required this.commissionReceived,
    required this.gst,
    required this.creditByAccount,
    required this.debitByAccount,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    return Payload(
      shopId: json['shopId']?.toString() ?? '',
      date:
          json['date'] != null
              ? DateTime.tryParse(json['date']) ?? DateTime.now()
              : DateTime.now(),
      openingBalance: (json['openingBalance'] ?? 0).toDouble(),
      totalCredit: (json['totalCredit'] ?? 0).toDouble(),
      totalDebit: (json['totalDebit'] ?? 0).toDouble(),
      closingBalance: (json['closingBalance'] ?? 0).toDouble(),
      sale: json['sale'] != null ? Sale.fromJson(json['sale']) : Sale.empty(),
      emiReceivedToday: (json['emiReceivedToday'] ?? 0).toDouble(),
      duesRecovered: (json['duesRecovered'] ?? 0).toDouble(),
      directGivenDues: (json['directGivenDues'] ?? 0).toDouble(),
      payBills: (json['payBills'] ?? 0).toDouble(),
      withdrawals: (json['withdrawals'] ?? 0).toDouble(),
      commissionReceived: (json['commissionReceived'] ?? 0).toDouble(),
      gst: json['gst'] != null ? Gst.fromJson(json['gst']) : Gst.empty(),
      creditByAccount:
          json['creditByAccount'] != null
              ? Map<String, double>.from(
                (json['creditByAccount'] as Map).map(
                  (key, value) =>
                      MapEntry(key.toString(), (value ?? 0).toDouble()),
                ),
              )
              : {},
      debitByAccount:
          json['debitByAccount'] != null
              ? Map<String, double>.from(
                (json['debitByAccount'] as Map).map(
                  (key, value) =>
                      MapEntry(key.toString(), (value ?? 0).toDouble()),
                ),
              )
              : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'date': date.toIso8601String(),
      'openingBalance': openingBalance,
      'totalCredit': totalCredit,
      'totalDebit': totalDebit,
      'closingBalance': closingBalance,
      'sale': sale.toJson(),
      'emiReceivedToday': emiReceivedToday,
      'duesRecovered': duesRecovered,
      'directGivenDues': directGivenDues,
      'payBills': payBills,
      'withdrawals': withdrawals,
      'commissionReceived': commissionReceived,
      'gst': gst.toJson(),
      'creditByAccount': creditByAccount,
      'debitByAccount': debitByAccount,
    };
  }
}

class Sale {
  final double totalSale;
  final double duesSaleDownpayment;
  final double emiSaleDownpayment;
  final double cashSale;
  final double saleRemainingGivenDues;
  final double salePendingEMI;

  Sale({
    required this.totalSale,
    required this.duesSaleDownpayment,
    required this.emiSaleDownpayment,
    required this.cashSale,
    required this.saleRemainingGivenDues,
    required this.salePendingEMI,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      totalSale: (json['totalSale'] ?? 0).toDouble(),
      duesSaleDownpayment: (json['duesSaleDownpayment'] ?? 0).toDouble(),
      emiSaleDownpayment: (json['emiSaleDownpayment'] ?? 0).toDouble(),
      cashSale: (json['cashSale'] ?? 0).toDouble(),
      saleRemainingGivenDues: (json['saleRemainingGivenDues'] ?? 0).toDouble(),
      salePendingEMI: (json['salePendingEMI'] ?? 0).toDouble(),
    );
  }

  factory Sale.empty() {
    return Sale(
      totalSale: 0,
      duesSaleDownpayment: 0,
      emiSaleDownpayment: 0,
      cashSale: 0,
      saleRemainingGivenDues: 0,
      salePendingEMI: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSale': totalSale,
      'duesSaleDownpayment': duesSaleDownpayment,
      'emiSaleDownpayment': emiSaleDownpayment,
      'cashSale': cashSale,
      'saleRemainingGivenDues': saleRemainingGivenDues,
      'salePendingEMI': salePendingEMI,
    };
  }
}

class Gst {
  final double gstOnSales;
  final double gstOnPurchases;
  final double netGst;

  Gst({
    required this.gstOnSales,
    required this.gstOnPurchases,
    required this.netGst,
  });

  factory Gst.fromJson(Map<String, dynamic> json) {
    return Gst(
      gstOnSales: (json['gstOnSales'] ?? 0).toDouble(),
      gstOnPurchases: (json['gstOnPurchases'] ?? 0).toDouble(),
      netGst: (json['netGst'] ?? 0).toDouble(),
    );
  }

  factory Gst.empty() {
    return Gst(gstOnSales: 0, gstOnPurchases: 0, netGst: 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'gstOnSales': gstOnSales,
      'gstOnPurchases': gstOnPurchases,
      'netGst': netGst,
    };
  }
}
