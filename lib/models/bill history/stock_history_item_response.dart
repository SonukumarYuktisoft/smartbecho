// stock_item_model.dart
import 'dart:convert';

import 'package:intl/intl.dart';

class StockItemsResponse {
  final int totalItems;
  final int totalQtyAdded;
  final int totalPages;
  final int currentPage;
  final List<StockItem> items;
  final int totalDistinctCompanies;
  final bool last;

  StockItemsResponse({
    required this.totalItems,
    required this.totalQtyAdded,
    required this.totalPages,
    required this.currentPage,
    required this.items,
    required this.totalDistinctCompanies,
    required this.last,
  });

  factory StockItemsResponse.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] ?? {};
    return StockItemsResponse(
      totalItems: payload['totalItems'] ?? 0,
      totalQtyAdded: payload['totalQtyAdded'] ?? 0,
      totalPages: payload['totalPages'] ?? 0,
      currentPage: payload['currentPage'] ?? 0,
      items:
          (payload['items'] as List<dynamic>?)
              ?.map((item) => StockItem.fromJson(item))
              .toList() ??
          [],
      totalDistinctCompanies: payload['totalDistinctCompanies'] ?? 0,
      last: (payload['currentPage'] ?? 0) >= ((payload['totalPages'] ?? 1) - 1),
    );
  }
}

class StockItem {
  final String itemCategory;
  final String shopId;
  final String model;
  final double sellingPrice;
  final int ram;
  final int rom;
  final String color;
  final String? imei;
  final int qty;
  final String company;
  final String logo;
  final DateTime createdDate;
  final String description;
  final double withGstAmount;
  final double withoutGstAmount;
  final String? hsnCode;
  final double gstAmount;
  final String? colorImeiMapping;
  final int billMobileItem;

  StockItem({
    required this.itemCategory,
    required this.shopId,
    required this.model,
    required this.sellingPrice,
    required this.ram,
    required this.rom,
    required this.color,
    this.imei,
    required this.qty,
    required this.company,
    required this.logo,
    required this.createdDate,
    required this.description,
    required this.withGstAmount,
    required this.withoutGstAmount,
    this.hsnCode,
    required this.gstAmount,
    this.colorImeiMapping,
    required this.billMobileItem,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      itemCategory: json['itemCategory'] ?? '',
      shopId: json['shopId'] ?? '',
      model: json['model'] ?? '',
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      ram: int.tryParse(json['ram']?.toString() ?? '0') ?? 0,
      rom: int.tryParse(json['rom']?.toString() ?? '0') ?? 0,
      color: json['color'] ?? '',
      imei: json['imei'],
      qty: json['qty'] ?? 0,
      company: json['company'] ?? '',
      logo: json['logo'] ?? '',
      createdDate: _parseDate(json['createdDate']),
      description: json['description'] ?? '',
      withGstAmount: (json['withGstAmount'] ?? 0).toDouble(),
      withoutGstAmount: (json['withoutGstAmount'] ?? 0).toDouble(),
      hsnCode: json['hsnCode'],
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      colorImeiMapping: json['colorImeiMapping'],
      billMobileItem: json['billMobileItem'] ?? 0,
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCategory': itemCategory,
      'shopId': shopId,
      'model': model,
      'sellingPrice': sellingPrice,
      'ram': ram,
      'rom': rom,
      'color': color,
      'imei': imei,
      'qty': qty,
      'company': company,
      'logo': logo,
      'createdDate': createdDate.toIso8601String().split('T')[0],
      'description': description,
      'withGstAmount': withGstAmount,
      'withoutGstAmount': withoutGstAmount,
      'hsnCode': hsnCode,
      'gstAmount': gstAmount,
      'colorImeiMapping': colorImeiMapping,
      'billMobileItem': billMobileItem,
    };
  }

  // Computed properties
  String get categoryDisplayName {
    return itemCategory.replaceAll('_', ' ').toUpperCase();
  }

  String get ramRomDisplay {
    if (ram > 0 && rom > 0) {
      return '$ram GB / $rom GB';
    }
    return '';
  }

  String get formattedPrice {
    return '₹${sellingPrice.toStringAsFixed(2)}';
  }

  String get formattedWithGst {
    return '₹${withGstAmount.toStringAsFixed(2)}';
  }

  String get formattedWithoutGst {
    return '₹${withoutGstAmount.toStringAsFixed(2)}';
  }

  String get formattedGstAmount {
    return '₹${gstAmount.toStringAsFixed(2)}';
  }

  String get formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${createdDate.day} ${months[createdDate.month - 1]} ${createdDate.year}';
  }

  double get gstPercentage {
    if (withoutGstAmount > 0) {
      return (gstAmount / withoutGstAmount) * 100;
    }
    return 0.0;
  }

  // Parse colorImeiMapping JSON string to Map
  Map<String, List<String>>? get parsedColorImeiMapping {
    if (colorImeiMapping == null || colorImeiMapping!.isEmpty) {
      return null;
    }

    try {
      // Parse the JSON string
      final decoded = json.decode(colorImeiMapping!);

      // Convert to Map<String, List<String>>
      Map<String, List<String>> result = {};
      decoded.forEach((key, value) {
        if (value is List) {
          result[key.toString()] = value.map((e) => e.toString()).toList();
        }
      });

      return result.isEmpty ? null : result;
    } catch (e) {
      print('Error parsing colorImeiMapping: $e');
      return null;
    }
  }

  // Get total IMEI count across all colors
  int get totalImeiCount {
    final mapping = parsedColorImeiMapping;
    if (mapping == null) return 0;

    int count = 0;
    mapping.forEach((color, imeis) {
      count += imeis.length;
    });
    return count;
  }

  // Get IMEI list for current color
  List<String>? get currentColorImeis {
    final mapping = parsedColorImeiMapping;
    if (mapping == null) return null;
    return mapping[color];
  }
}

// Helper function to parse date from various formats
DateTime _parseDate(dynamic dateValue) {
  if (dateValue == null) {
    return DateTime.now();
  }

  if (dateValue is String) {
    try {
      // Handle "YYYY-MM-DD" format
      return DateTime.parse(dateValue);
    } catch (e) {
      return DateTime.now();
    }
  }

  if (dateValue is List<dynamic>) {
    // Handle the old integer array format for backward compatibility
    try {
      if (dateValue.length >= 3) {
        int year = dateValue[0] as int;
        int month = dateValue[1] as int;
        int day = dateValue[2] as int;
        return DateTime(year, month, day);
      }
    } catch (e) {
      return DateTime.now();
    }
  }

  return DateTime.now();
}
