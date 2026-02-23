// models/sales_detail_models.dart

import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

class SaleDetailResponse {
  final int saleId;
  final String shopId;
  final String shopName;
  final String invoiceNumber;
  final String saleDate;
  final double totalPayableAmount;
  final double? unitPrice;
  final double withoutGst;
  final double withGst;
  final double gst;
  final String customerName;
  final List<SaleItem> items;
  final double extraCharges;
  final double accessoriesCost;
  final double repairCharges;
  final double totalAmount;
  final double totalDiscount;
  final double downPayment;
  final SaleDues? dues;
  final SaleEmi? emi;
  final Shop shop;
  final Customer customer;
   final double? totalCostAmount;
  final double? totalProfit;
  final double? overallProfitMargin;
  final bool paid;
  final String pdfUrl; // Add this line

  SaleDetailResponse({
    required this.saleId,
    required this.shopId,
    required this.shopName,
    required this.invoiceNumber,
    required this.saleDate,
    required this.totalPayableAmount,
    this.unitPrice,
    required this.withoutGst,
    required this.withGst,
    required this.gst,
    required this.customerName,
    required this.items,
    required this.extraCharges,
    required this.accessoriesCost,
    required this.repairCharges,
    required this.totalAmount,
    required this.totalDiscount,
    required this.downPayment,
    this.dues,
    this.emi,
    required this.shop,
    required this.customer,
    this.totalCostAmount,
    this.totalProfit,
    this.overallProfitMargin,
    required this.paid,
    required this.pdfUrl,
  });

  factory SaleDetailResponse.fromJson(Map<String, dynamic> json) {
    return SaleDetailResponse(
      saleId: json['saleId'] ?? 0,
      shopId: json['shopId'] ?? '',
      shopName: json['shopName'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      saleDate: json['saleDate'] ?? '',
      totalPayableAmount: (json['totalPayableAmount'] ?? 0.0).toDouble(),
      unitPrice: json['unitPrice']?.toDouble(),
      withoutGst: (json['withoutGst'] ?? 0.0).toDouble(),
      withGst: (json['withGst'] ?? 0.0).toDouble(),
      gst: (json['gst'] ?? 0.0).toDouble(),
      customerName: json['customerName'] ?? '',
      items:
          (json['items'] as List?)
              ?.map((item) => SaleItem.fromJson(item))
              .toList() ??
          [],
      extraCharges: (json['extraCharges'] ?? 0.0).toDouble(),
      accessoriesCost: (json['accessoriesCost'] ?? 0.0).toDouble(),
      repairCharges: (json['repairCharges'] ?? 0.0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      totalDiscount: (json['totalDiscount'] ?? 0.0).toDouble(),
      downPayment: (json['downPayment'] ?? 0.0).toDouble(),
      dues: json['dues'] != null ? SaleDues.fromJson(json['dues']) : null,
      emi: json['emi'] != null ? SaleEmi.fromJson(json['emi']) : null,
      shop: Shop.fromJson(json['shop']),
      customer: Customer.fromJson(json['customer']),
      totalCostAmount: json['totalCostAmount'],
      totalProfit: json['totalProfit'],
      overallProfitMargin: json['overallProfitMargin'],
      paid: json['paid'] ?? false,
      pdfUrl: json['url'] ?? '',
    );
  }

  String get formattedAmount => '₹${totalPayableAmount.toStringAsFixed(2)}';
  String get formattedTotalAmount => '₹${totalAmount.toStringAsFixed(2)}';
  String get formattedWithoutGst => '₹${withoutGst.toStringAsFixed(2)}';
  String get formattedWithGst => '₹${withGst.toStringAsFixed(2)}';
  String get formattedDownPayment => '₹${downPayment.toStringAsFixed(2)}';
  String get formattedExtraCharges => '₹${extraCharges.toStringAsFixed(2)}';
  String get formattedAccessoriesCost =>
      '₹${accessoriesCost.toStringAsFixed(2)}';
  String get formattedRepairCharges => '₹${repairCharges.toStringAsFixed(2)}';
  String get formattedTotalDiscount => '₹${totalDiscount.toStringAsFixed(2)}';

  String get formattedDate {
    try {
      final DateTime parsedDate = DateTime.parse(saleDate);
      return '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
    } catch (e) {
      return saleDate;
    }
  }

  String get formattedTime {
    try {
      final DateTime parsedDate = DateTime.parse(saleDate);
      return '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  String get paymentStatus => paid ? 'Paid' : 'Pending';
}

class SaleItem {
  final String model;
  final String color;
  final String ram;
  final String rom;
  final int quantity;
  final double? sellingPrice;
  final String accessoryName;
  final bool accessoryIncluded;
  final String? imei;
  final String? company;
 final double? purchasePriceWithGst;
  final double? purchasePriceWithoutGst;
  final double? itemProfit;
  final double? profitMargin;
  SaleItem({
    required this.model,
    required this.color,
    required this.ram,
    required this.rom,
    required this.quantity,
    this.sellingPrice,
    required this.accessoryName,
    required this.accessoryIncluded,
     this.imei,
    this.company,
    this.purchasePriceWithGst,
    this.purchasePriceWithoutGst,
    this.itemProfit,
    this.profitMargin,
   
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      ram: json['ram'] ?? '',
      rom: json['rom'] ?? '',
      quantity: json['quantity'] ?? 1,
      sellingPrice: json['sellingPrice']?.toDouble(),
      accessoryName: json['accessoryName'] ?? '',
      accessoryIncluded: json['accessoryIncluded'] ?? false,
      imei: json['imei'],
      company: json['company'],
       purchasePriceWithGst: json['purchasePriceWithGst']?.toDouble(),
      purchasePriceWithoutGst: json['purchasePriceWithoutGst']?.toDouble(),
      itemProfit: json['itemProfit']?.toDouble(),
      profitMargin: json['profitMargin']?.toDouble(),
    );
  }

  String get formattedPrice =>
      sellingPrice != null ? '₹${sellingPrice!.toStringAsFixed(2)}' : 'N/A';
  String get specifications => 'RAM: ${AppFormatterHelper.formatRamForUI(ram)} ROM: ${AppFormatterHelper.formatRamForUI(rom)}';
}

class SaleDues {
  final int id;
  final String shopId;
  final double totalDue;
  final double totalPaid;
  final double remainingDue;
  final List<PartialPayment> partialPayments;
  final String creationDate;
  final String paymentRetriableDate;
  final bool paid;

  SaleDues({
    required this.id,
    required this.shopId,
    required this.totalDue,
    required this.totalPaid,
    required this.remainingDue,
    required this.partialPayments,
    required this.creationDate,
    required this.paymentRetriableDate,
    required this.paid,
  });

  factory SaleDues.fromJson(Map<String, dynamic> json) {
    return SaleDues(
      id: json['id'] ?? 0,
      shopId: json['shopId'] ?? '',
      totalDue: (json['totalDue'] ?? 0.0).toDouble(),
      totalPaid: (json['totalPaid'] ?? 0.0).toDouble(),
      remainingDue: (json['remainingDue'] ?? 0.0).toDouble(),
      partialPayments:
          (json['partialPayments'] as List? ?? [])
              .map((payment) => PartialPayment.fromJson(payment))
              .toList(),
      creationDate: json['creationDate'] ?? '',
      paymentRetriableDate: json['paymentRetriableDate'] ?? '',
      paid: json['paid'] ?? false,
    );
  }

  String get formattedTotalDue => '₹${totalDue.toStringAsFixed(2)}';
  String get formattedTotalPaid => '₹${totalPaid.toStringAsFixed(2)}';
  String get formattedRemainingDue => '₹${remainingDue.toStringAsFixed(2)}';

  double get paymentProgress => totalDue > 0 ? (totalPaid / totalDue) : 0.0;
}

class PartialPayment {
  final int id;
  final double paidAmount;
  final String paidDate; // ← Changed from List<int> to String

  PartialPayment({
    required this.id,
    required this.paidAmount,
    required this.paidDate,
  });

  factory PartialPayment.fromJson(Map<String, dynamic> json) {
    return PartialPayment(
      id: json['id'] ?? 0,
      paidAmount: (json['paidAmount'] ?? 0.0).toDouble(),
      paidDate: json['paidDate'] ?? '', // ← Handle as String
    );
  }

  String get formattedAmount => '₹${paidAmount.toStringAsFixed(2)}';

  String get formattedDate {
    try {
      // Parse the ISO date string (e.g., "2025-12-07")
      final DateTime parsedDate = DateTime.parse(paidDate);
      return '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
    } catch (e) {
      return paidDate.isNotEmpty ? paidDate : 'N/A';
    }
  }
}

class SaleEmi {
  final int id;
  final Customer customer;
  final double totalEmiAmount;
  final double monthlyEmi;
  final int totalMonths;
  final int paidMonths;
  final String startDate;

  SaleEmi({
    required this.id,
    required this.customer,
    required this.totalEmiAmount,
    required this.monthlyEmi,
    required this.totalMonths,
    required this.paidMonths,
    required this.startDate,
  });

  factory SaleEmi.fromJson(Map<String, dynamic> json) {
    return SaleEmi(
      id: json['id'] ?? 0,
      customer: Customer.fromJson(json['customer'] ?? {}),
      totalEmiAmount: (json['totalEmiAmount'] ?? 0.0).toDouble(),
      monthlyEmi: (json['monthlyEmi'] ?? 0.0).toDouble(),
      totalMonths: json['totalMonths'] ?? 0,
      paidMonths: json['paidMonths'] ?? 0,
      startDate: json['startDate'] ?? '',
    );
  }

  String get formattedMonthlyEmi => '${monthlyEmi.toStringAsFixed(0)}';
  String get formattedTotalEmiAmount => '₹${totalEmiAmount.toStringAsFixed(2)}';
  String get formattedStartDate {
    try {
      final DateTime parsedDate = DateTime.parse(startDate);
      return '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
    } catch (e) {
      return startDate;
    }
  }

  int get remainingMonths => totalMonths - paidMonths;
  double get remainingAmount => monthlyEmi * remainingMonths;
  double get paidAmount => monthlyEmi * paidMonths;
  double get completionPercentage =>
      totalMonths > 0 ? (paidMonths / totalMonths) * 100 : 0.0;

  String get formattedRemainingAmount =>
      '₹${remainingAmount.toStringAsFixed(2)}';
  String get formattedPaidAmount => '₹${paidAmount.toStringAsFixed(2)}';
}

class Shop {
  final int id;
  final String shopId;
  final String shopStoreName;
  final String email;
  final String phone;
  final ShopAddress? shopAddress;
  final String? profilePhotoUrl;
  final int status;
  final String gstnumber;
  final String adhaarNumber;
  final String creationDate;

  Shop({
    required this.id,
    required this.shopId,
    required this.shopStoreName,
    required this.email,
    required this.phone,
    this.shopAddress,
    this.profilePhotoUrl,
    required this.status,
    required this.gstnumber,
    required this.adhaarNumber,
    required this.creationDate,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] ?? 0,
      shopId: json['shopId'] ?? '',
      shopStoreName: json['shopStoreName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      shopAddress:
          json['shopAddress'] != null
              ? ShopAddress.fromJson(json['shopAddress'])
              : null,

      profilePhotoUrl: json['profilePhotoUrl'],
      status: json['status'] ?? json['Status'] ?? 1,
      gstnumber: json['gstnumber'] ?? '',
      adhaarNumber: json['adhaarNumber'] ?? '',
      creationDate: json['creationDate'] ?? '',
    );
  }
}

class ShopAddress {
  final int id;
  final String? label;
  final String? name;
  final String? phone;
  final String? addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String? city;
  final String? state;
  final String? pincode;
  final String? country;
  final bool? defaultAddress;

  ShopAddress({
    required this.id,
    this.label,
    this.name,
    this.phone,
    this.addressLine1,
    this.addressLine2,
    this.landmark,
    this.city,
    this.state,
    this.pincode,
    this.country,
    this.defaultAddress,
  });

  factory ShopAddress.fromJson(Map<String, dynamic> json) {
    return ShopAddress(
      id: json['id'] ?? 0,
      label: json['label'],
      name: json['name'],
      phone: json['phone'],
      addressLine1: json['addressLine1'],
      addressLine2: json['addressLine2'],
      landmark: json['landmark'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'],
      defaultAddress: json['default'],
    );
  }
}

class Customer {
  final int id;
  final String name;
  final String? email;
  final String primaryPhone;
  final String primaryAddress;
  final String shopId;
  final String? profilePhotoUrl;
  final String location;
  final List<String> alternatePhones;
  final String createdAt;

  Customer({
    required this.id,
    required this.name,
    this.email,
    required this.primaryPhone,
    required this.primaryAddress,
    required this.shopId,
    this.profilePhotoUrl,
    required this.location,
    required this.alternatePhones,
    required this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      primaryPhone: json['primaryPhone'] ?? '',
      primaryAddress: json['primaryAddress'] ?? '',
      shopId: json['shopId'] ?? '',
      profilePhotoUrl: json['profilePhotoUrl'],
      location: json['location'] ?? '',
      alternatePhones: List<String>.from(json['alternatePhones'] ?? []),
      createdAt: json['createdAt'] ?? '',
    );
  }

  String get displayName => name.isNotEmpty ? name : 'Unknown Customer';
  String get displayPhone =>
      primaryPhone.isNotEmpty ? primaryPhone : 'No phone';
  String get displayAddress =>
      primaryAddress.isNotEmpty ? primaryAddress : 'No address';
}
