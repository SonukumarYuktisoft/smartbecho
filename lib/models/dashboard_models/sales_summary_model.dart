// File: models/dashboard_models.dart

import 'package:flutter/material.dart';

class DashboardStats {
  final String totalSalesToday;
  final String totalStockAvailable;
  final String totalPendingEMI;

  DashboardStats({
    required this.totalSalesToday,
    required this.totalStockAvailable,
    required this.totalPendingEMI,
  });
}

class StatItem {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> colors;

  StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
  });
}

class QuickActionButton {
  final String title;
  final IconData icon;
  final List<Color> colors;
  final String route;

  QuickActionButton({
    required this.title,
    required this.icon,
    required this.colors,
    this.route = '',
  });
}

class PaymentDetail {
  final String amount;
  final int transactions;

  PaymentDetail(this.amount, this.transactions);
}

class SalesSummary {
  final String totalSales;
  final int smartphonesSold;
  final int totalTransactions;
  final Map<String, PaymentDetail> paymentBreakdown;

  SalesSummary({
    required this.totalSales,
    required this.smartphonesSold,
    required this.totalTransactions,
    required this.paymentBreakdown,
  });
}

class StockSummary {
  final String totalStock;
  final Map<String, int> companyStock;
  final List<String> lowStockAlerts;

  StockSummary({
    required this.totalStock,
    required this.companyStock,
    required this.lowStockAlerts,
  });
}

class EMISummary {
  final String totalEMIDue;
  final int phonesSoldOnEMI;
  final String pendingPayments;
  final Map<String, String> emiPhones;

  EMISummary({
    required this.totalEMIDue,
    required this.phonesSoldOnEMI,
    required this.pendingPayments,
    required this.emiPhones,
  });
}


class SalesApiResponse {
  final String status;
  final String message;
  final SalesPayload? payload;
  final int statusCode;

  SalesApiResponse({
    required this.status,
    required this.message,
    this.payload,
    required this.statusCode,
  });

  factory SalesApiResponse.fromJson(Map<String, dynamic> json) {
    return SalesApiResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: json['payload'] != null 
          ? SalesPayload.fromJson(json['payload']) 
          : null,
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload?.toJson(),
      'statusCode': statusCode,
    };
  }
}

class SalesPayload {
  final int totalItemsSoldToday;
  final int totalTransactionsToday;
  final PaymentMethodBreakdown paymentMethodBreakdown;
  final double totalSaleAmountToday;

  SalesPayload({
    required this.totalItemsSoldToday,
    required this.totalTransactionsToday,
    required this.paymentMethodBreakdown,
    required this.totalSaleAmountToday,
  });

  factory SalesPayload.fromJson(Map<String, dynamic> json) {
    return SalesPayload(
      totalItemsSoldToday: json['totalItemsSoldToday'] ?? 0,
      totalTransactionsToday: json['totalTransactionsToday'] ?? 0,
      paymentMethodBreakdown: PaymentMethodBreakdown.fromJson(
          json['paymentMethodBreakdown'] ?? {}),
      totalSaleAmountToday: (json['totalSaleAmountToday'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItemsSoldToday': totalItemsSoldToday,
      'totalTransactionsToday': totalTransactionsToday,
      'paymentMethodBreakdown': paymentMethodBreakdown.toJson(),
      'totalSaleAmountToday': totalSaleAmountToday,
    };
  }
}

class PaymentMethodBreakdown {
  final String upi;
  final String cash;
  final String emi;
  final String card;

  PaymentMethodBreakdown({
    required this.upi,
    required this.cash,
    required this.emi,
    required this.card,
  });

  factory PaymentMethodBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentMethodBreakdown(
      upi: json['UPI']?.toString() ?? '0',
      cash: json['Cash']?.toString() ?? '0',
      emi: json['EMI']?.toString() ?? '0',
      card: json['Card']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UPI': upi,
      'Cash': cash,
      'EMI': emi,
      'Card': card,
    };
  }

  // Helper method to get all payment methods as a map
  Map<String, String> toMap() {
    return {
      'UPI': upi,
      'Cash': cash,
      'EMI': emi,
      'Card': card,
    };
  }
}