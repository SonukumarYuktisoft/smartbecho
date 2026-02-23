import 'package:intl/intl.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

class BillItem {
  final String itemCategory;
  final String shopId;
  final String model;
  final double sellingPrice;
  final int ram;
  final int rom;
  final String color;
  final int qty;
  final String company;
  final String logo;
  final DateTime createdDate;
  final String? description;
  final int billMobileItem;

  BillItem({
    required this.itemCategory,
    required this.shopId,
    required this.model,
    required this.sellingPrice,
    required this.ram,
    required this.rom,
    required this.color,
    required this.qty,
    required this.company,
    required this.logo,
    required this.createdDate,
    this.description,
    required this.billMobileItem,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      itemCategory: json['itemCategory'] ?? '',
      shopId: json['shopId'] ?? '',
      model: json['model'] ?? '',
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      ram: int.tryParse(json['ram']?.toString() ?? '0') ?? 0,
      rom: int.tryParse(json['rom']?.toString() ?? '0') ?? 0,
      color: json['color'] ?? '',
      qty: json['qty'] ?? 0,
      company: json['company'] ?? '',
      logo: json['logo'] ?? '',
      createdDate:
          json['createdDate'] != null
              ? DateTime.parse(json['createdDate'])
              : DateTime.now(),
      description: json['description'],
      billMobileItem: json['billMobileItem'] ?? 0,
    );
  }

  String get ramRomDisplay =>
      '${AppFormatterHelper.formatRamForUI(ram.toString())}GB/${rom}GB';
  String get formattedPrice => '₹${sellingPrice.toStringAsFixed(0)}';

  String get formattedCreatedDate =>
      DateFormat('dd MMM yyyy').format(createdDate);
}

class Bill {
  final int billId;
  final String shopId;
  final DateTime date;
  final String companyName;
  final double amount;
  final double withoutGst;
  final double gst;
  final double dues;
  final List<BillItem> items;
  final bool isPaid;
  final String? invoice;

  Bill({
    required this.billId,
    required this.shopId,
    required this.date,
    required this.companyName,
    required this.amount,
    required this.withoutGst,
    required this.gst,
    required this.dues,
    required this.items,
    required this.isPaid,
    this.invoice,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      billId: json['billId'] ?? 0,
      shopId: json['shopId'] ?? '',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      companyName: json['companyName'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      withoutGst: (json['withoutGst'] ?? 0).toDouble(),
      gst: (json['gst'] ?? 0).toDouble(),
      dues: (json['dues'] ?? 0).toDouble(),
      items:
          (json['items'] as List<dynamic>? ?? [])
              .map((item) => BillItem.fromJson(item))
              .toList(),
      isPaid: json['isPaid'] ?? false,
      invoice: json['invoice'],
    );
  }

  String get formattedDate => DateFormat('dd MMM yyyy').format(date);

  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';
  String get formattedDues => '₹${dues.toStringAsFixed(0)}';
  String get formattedGst => '${gst.toStringAsFixed(0)}%';
  String get formattedWithoutGst => '₹${withoutGst.toStringAsFixed(0)}';

  String get status => isPaid ? 'Paid' : 'Pending';
  bool get paid => isPaid;

  int get totalItems => items.fold(0, (sum, item) => sum + item.qty);
}

class BillsResponse {
  final double totalAmount;
  final int totalQty;
  final int totalPages;
  final List<Bill> bills;
  final int currentPage;
  final int totalElements;

  BillsResponse({
    required this.totalAmount,
    required this.totalQty,
    required this.totalPages,
    required this.bills,
    required this.currentPage,
    required this.totalElements,
  });

  factory BillsResponse.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] ?? {};

    return BillsResponse(
      totalAmount: (payload['totalAmount'] ?? 0).toDouble(),
      totalQty: payload['totalQty'] ?? 0,
      totalPages: payload['totalPages'] ?? 0,
      bills:
          (payload['bills'] as List<dynamic>? ?? [])
              .map((bill) => Bill.fromJson(bill))
              .toList(),
      currentPage: payload['currentPage'] ?? 0,
      totalElements: payload['totalElements'] ?? 0,
    );
  }

  List<Bill> get content => bills;
  bool get last => currentPage >= (totalPages - 1);
  bool get first => currentPage == 0;
}
