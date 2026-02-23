import 'package:intl/intl.dart';

class StockItem {
  final int id;
  final String shopId;
  final String model;
  final String ram;
  final String rom;
  final String color;
  final double sellingPrice;
  final int qty;
  final String company;
  final String logo;
  final DateTime? createdDate; // <-- changed from List<int> to DateTime?
  final int? lowStockQty;

  StockItem({
    required this.id,
    required this.shopId,
    required this.model,
    required this.ram,
    required this.rom,
    required this.color,
    required this.sellingPrice,
    required this.qty,
    required this.company,
    required this.logo,
    required this.createdDate,
    this.lowStockQty,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;

    if (json['createdDate'] != null) {
      if (json['createdDate'] is String) {
        // Parse ISO8601 string like "2025-08-16T11:06:40.294393"
        parsedDate = DateTime.tryParse(json['createdDate']);
      } else if (json['createdDate'] is List) {
        // Parse [year, month, day, hour, minute, second]
        List list = json['createdDate'];
        if (list.length >= 3) {
          parsedDate = DateTime(
            list[0],
            list[1],
            list[2],
            list.length > 3 ? list[3] : 0,
            list.length > 4 ? list[4] : 0,
            list.length > 5 ? list[5] : 0,
          );
        }
      }
    }

    return StockItem(
      id: json['id'] ?? 0,
      shopId: json['shopId'] ?? '',
      model: json['model'] ?? '',
      ram: json['ram']?.toString() ?? '',
      rom: json['rom']?.toString() ?? '',
      color: json['color'] ?? '',
      sellingPrice: (json['sellingPrice'] ?? 0.0).toDouble(),
      qty: json['qty'] ?? 0,
      company: json['company'] ?? '',
      logo: json['logo'] ?? '',
      createdDate: parsedDate,
      lowStockQty: json['lowStockQty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'model': model,
      'ram': ram,
      'rom': rom,
      'color': color,
      'sellingPrice': sellingPrice,
      'qty': qty,
      'company': company,
      'logo': logo,
      'createdDate': createdDate?.toIso8601String(),
      'lowStockQty': lowStockQty,
    };
  }

  // Helper getters
  String get ramRomDisplay => '${ram}GB/${rom}GB';

  bool get isLowStock => qty <= 10;
  bool get isOutOfStock => qty == 0;

  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  String get formattedPrice => '₹${sellingPrice.toStringAsFixed(0)}';

  String get formattedDate =>
      createdDate != null ? DateFormat('dd MMM yyyy').format(createdDate!) : 'N/A';
}




class ItemModel {
  final String id;
  final String itemName;
  final String model;
  final String brand;
  final String ram;
  final String rom;
  final double price;
  final int quantity;
  final String shopId;
  final String? itemCategory;
  final String? description;
  final DateTime? createdDate;

  ItemModel({
    required this.id,
    required this.itemName,
    required this.model,
    required this.brand,
    required this.ram,
    required this.rom,
    required this.price,
    required this.quantity,
    required this.shopId,
    this.itemCategory,
    this.description,
    this.createdDate,
  });

  /// ✅ Parse from API (supports both String and List<int> for createdDate)
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] ?? '',
      itemName: json['itemName'] ?? '',
      model: json['model'] ?? '',
      brand: json['brand'] ?? '',
      ram: json['ram'] ?? '',
      rom: json['rom'] ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0.0,
      quantity: json['quantity'] ?? 0,
      shopId: json['shopId'] ?? '',
      itemCategory: json['itemCategory'],
      description: json['description'],
      createdDate: _parseDate(json['createdDate']),
    );
  }

  /// ✅ Convert to JSON (always ISO8601 for consistency)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'model': model,
      'brand': brand,
      'ram': ram,
      'rom': rom,
      'price': price,
      'quantity': quantity,
      'shopId': shopId,
      'itemCategory': itemCategory,
      'description': description,
      'createdDate': createdDate?.toIso8601String(),
    };
  }

  /// ✅ Helper: Handles both String and List<int> date formats
  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is String && date.isNotEmpty) {
      try {
        return DateTime.parse(date);
      } catch (_) {}
    }
    if (date is List && date.length >= 3) {
      try {
        return DateTime(
          date[0] as int,
          date[1] as int,
          date[2] as int,
          date.length > 3 ? date[3] as int : 0,
          date.length > 4 ? date[4] as int : 0,
          date.length > 5 ? date[5] as int : 0,
        );
      } catch (_) {}
    }
    return null;
  }

  // -----------------------------
  // Extra Helpers for UI
  // -----------------------------

  String get ramRomDisplay => "$ram/$rom";

  bool get isLowStock => quantity > 0 && quantity <= 5;
  bool get isOutOfStock => quantity <= 0;

  String get stockStatus {
    if (isOutOfStock) return "Out of Stock";
    if (isLowStock) return "Low Stock";
    return "In Stock";
  }

  String get formattedPrice => "₹${price.toStringAsFixed(2)}";

  String get formattedDate =>
      createdDate != null ? DateFormat('dd MMM yyyy').format(createdDate!) : "N/A";
}
