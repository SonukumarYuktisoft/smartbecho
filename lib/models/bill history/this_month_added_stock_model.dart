class ThisMonthStockResponse {
  final String status;
  final String message;
  final List<ThisMonthStockItem> payload;
  final int statusCode;

  ThisMonthStockResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory ThisMonthStockResponse.fromJson(Map<String, dynamic> json) {
    return ThisMonthStockResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: (json['payload'] as List<dynamic>?)
              ?.map((item) => ThisMonthStockItem.fromJson(item))
              .toList() ??
          [],
      statusCode: json['statusCode'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'payload': payload.map((item) => item.toJson()).toList(),
      'statusCode': statusCode,
    };
  }
}

class ThisMonthStockItem {
  final int id;
  final String itemCategory;
  final String shopId;
  final String model;
  final double sellingPrice;
  final String ram;
  final String rom;
  final String color;
  final String? imei;
  final int qty;
  final String company;
  final String logo;
  final String createdDate;
  final String? description;

  ThisMonthStockItem({
    required this.id,
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
    this.description,
  });

  factory ThisMonthStockItem.fromJson(Map<String, dynamic> json) {
    return ThisMonthStockItem(
      id: json['id'] ?? 0,
      itemCategory: json['itemCategory'] ?? '',
      shopId: json['shopId'] ?? '',
      model: json['model'] ?? '',
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      ram: json['ram'] ?? '',
      rom: json['rom'] ?? '',
      color: json['color'] ?? '',
      imei: json['imei'],
      qty: json['qty'] ?? 0,
      company: json['company'] ?? '',
      logo: json['logo'] ?? '',
      createdDate: json['createdDate'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'createdDate': createdDate,
      'description': description,
    };
  }

  // Helper getters
  String get ramRomDisplay => '$ram/$rom';
  String get formattedPrice => '₹${sellingPrice.toStringAsFixed(0)}';
  String get formattedDate {
    try {
      final date = DateTime.parse(createdDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return createdDate;
    }
  }
  
  String get categoryDisplayName {
    switch (itemCategory.toLowerCase()) {
      case 'smartphone':
        return 'Smartphone';
      case 'tablet':
        return 'Tablet';
      case 'feature_phone':
        return 'Feature Phone';
      case 'charger':
        return 'Charger';
      case 'earphones':
        return 'Earphones';
      case 'headphones':
        return 'Headphones';
      case 'cover':
        return 'Cover';
      case 'screen_guard':
        return 'Screen Guard';
      case 'power_bank':
        return 'Power Bank';
      case 'memory_card':
        return 'Memory Card';
      case 'smart_watch':
        return 'Smart Watch';
      case 'fitness_band':
        return 'Fitness Band';
      default:
        return itemCategory.replaceAll('_', ' ').toUpperCase();
    }
  }

  String get companyDisplayName {
    return company[0].toUpperCase() + company.substring(1).toLowerCase();
  }
}