class InventoryItem {
  final int id;
  final String itemCategory;
  final String logo;
  final String model;
  final String ram;
  final String rom;
  final String color;
  final double sellingPrice;
  final int quantity;
  final String company;
  final String? shopId;
  final DateTime? createdDate;
  final String? description;
  final int? lowStockQty;
  final List<String>? imeiList;
   final String? source; 
  final String? displayName; 
  final String ?purchaseBillId;

  InventoryItem({
    required this.id,
    required this.itemCategory,
    required this.logo,
    required this.model,
    required this.ram,
    required this.rom,
    required this.color,
    required this.sellingPrice,
    required this.quantity,
    required this.company,
    this.shopId,
    this.createdDate,
    this.description,
    this.lowStockQty,
    this.imeiList,
    this.source, 
    this.displayName, 
    this.purchaseBillId,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      itemCategory: json['itemCategory'] ?? '',
      logo: json['logo'] ?? '',
      model: json['model'] ?? '',
      ram: "${json['ram'] ?? ''}",
      rom: "${json['rom'] ?? ''}",
      color: json['color'] ?? '',
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      quantity: json['qty'] ?? 0,
      company: json['company'] ?? '',
      shopId: json['shopId'],
      createdDate: _parseDate(json['createdDate']),
      description: json['description'],
      lowStockQty: json['lowStockQty'],
      imeiList: json['imeiList'] != null
          ? List<String>.from(json['imeiList'])
          : null,
      source: json['source'], // ✅ added
      displayName: json['displayName'], 
      purchaseBillId: json['purchaseBillId'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemCategory': itemCategory,
      'logo': logo,
      'model': model,
      'ram': ram,
      'rom': rom,
      'color': color,
      'sellingPrice': sellingPrice,
      'qty': quantity,
      'company': company,
      if (shopId != null) 'shopId': shopId,
      if (createdDate != null)
        'createdDate': [
          createdDate!.year,
          createdDate!.month,
          createdDate!.day,
          createdDate!.hour,
          createdDate!.minute,
          createdDate!.second,
          createdDate!.microsecond * 1000,
        ],
      if (description != null) 'description': description,
      if (lowStockQty != null) 'lowStockQty': lowStockQty,
      if (imeiList != null) 'imeiList': imeiList,
      if (source != null) 'source': source,
      if (displayName != null) 'displayName': displayName,
      if (purchaseBillId != null) 'purchaseBillId': purchaseBillId,
    };
  }

  static DateTime? _parseDate(dynamic date) {
    if (date is List && date.length >= 5) {
      try {
        return DateTime(
          int.parse(date[0].toString()),
          int.parse(date[1].toString()),
          int.parse(date[2].toString()),
          int.parse(date[3].toString()),
          int.parse(date[4].toString()),
          date.length > 5 ? int.parse(date[5].toString()) : 0,
          date.length > 6 ? (int.parse(date[6].toString()) ~/ 1000) : 0,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
