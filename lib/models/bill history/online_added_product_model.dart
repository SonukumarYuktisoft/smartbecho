// models/online_products/product_model.dart

import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

class ProductResponse {
  final String status;
  final String message;
  final ProductPayload payload;
  final int statusCode;

  ProductResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: ProductPayload.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class ProductPayload {
  final List<Product> content;
  final bool last;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final bool first;
  final int numberOfElements;
  final bool empty;

  ProductPayload({
    required this.content,
    required this.last,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.first,
    required this.numberOfElements,
    required this.empty,
  });

  factory ProductPayload.fromJson(Map<String, dynamic> json) {
    return ProductPayload(
      content: (json['content'] as List?)
              ?.map((item) => Product.fromJson(item))
              .toList() ??
          [],
      last: json['last'] ?? true,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      first: json['first'] ?? true,
      numberOfElements: json['numberOfElements'] ?? 0,
      empty: json['empty'] ?? true,
    );
  }
}

class Product {
  final int id;
  final String itemCategory;
  final String shopId;
  final String model;
  final double sellingPrice;
  final double? purchasePrice;
  final String? ram;
  final String? rom;
  final String color;
  final String? imei;
  final String? serialNumber;
  final int qty;
  final String company;
  final String? logo;
  final String createdDate;
  final String? description;
  final String purchasedFrom;
  final String? purchaseContact;
  final String purchaseDate;
  final String purchaseNotes;
  final String? purchaseBillId;

  Product({
    required this.id,
    required this.itemCategory,
    required this.shopId,
    required this.model,
    required this.sellingPrice,
    this.purchasePrice,
    this.ram,
    this.rom,
    required this.color,
    this.imei,
    this.serialNumber,
    required this.qty,
    required this.company,
    this.logo,
    required this.createdDate,
    this.description,
    required this.purchasedFrom,
    this.purchaseContact,
    required this.purchaseDate,
    required this.purchaseNotes,
    this.purchaseBillId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      itemCategory: json['itemCategory'] ?? '',
      shopId: json['shopId'] ?? '',
      model: json['model'] ?? '',
      sellingPrice: _parseDouble(json['sellingPrice']),
      purchasePrice: _parseDoubleNullable(json['purchasePrice']),
      ram: json['ram'],
      rom: json['rom'],
      color: json['color'] ?? '',
      imei: json['imei'],
      serialNumber: json['serialNumber'],
      qty: json['qty'] ?? 0,
      company: json['company'] ?? '',
      logo: json['logo'],
      createdDate: json['createdDate'] ?? '',
      description: json['description'],
      purchasedFrom: json['purchasedFrom'] ?? '',
      purchaseContact: json['purchaseContact'],
      purchaseDate: json['purchaseDate'] ?? '',
      purchaseNotes: json['purchaseNotes'] ?? '',
      purchaseBillId: json['purchaseBillId'],
    );
  }

  // Helper method to safely parse double values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper method to safely parse nullable double values
  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String get formattedSellingPrice => '₹${sellingPrice.toStringAsFixed(0)}';
  
  String get formattedPurchasePrice => 
      purchasePrice != null ? '₹${purchasePrice!.toStringAsFixed(0)}' : 'N/A';
  
  String get ramRomDisplay {
    final hasRam = ram != null && ram!.isNotEmpty;
    final hasRom = rom != null && rom!.isNotEmpty;
    
    if (hasRam && hasRom) {
      return '${AppFormatterHelper.formatRamForUI(ram!)}/${AppFormatterHelper.formatRamForUI(rom!)}';
    } else if (hasRam) {
      return AppFormatterHelper.formatRamForUI(ram!);
    } else if (hasRom) {
      return AppFormatterHelper.formatRamForUI(rom!);
    }
    return '';
  }
  
  String get categoryDisplayName => itemCategory.replaceAll('_', ' ');
  
  String get formattedDate {
    try {
      final date = DateTime.parse(createdDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return createdDate;
    }
  }

  String get displayLogo => logo ?? '';
  
  bool get hasLogo => logo != null && logo!.isNotEmpty;
}

// Filter Response Model
class ProductFilterResponse {
  final String status;
  final String message;
  final ProductFilters payload;
  final int statusCode;

  ProductFilterResponse({
    required this.status,
    required this.message,
    required this.payload,
    required this.statusCode,
  });

  factory ProductFilterResponse.fromJson(Map<String, dynamic> json) {
    return ProductFilterResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      payload: ProductFilters.fromJson(json['payload'] ?? {}),
      statusCode: json['statusCode'] ?? 0,
    );
  }
}

class ProductFilters {
  final List<String> companies;
  final List<String> models;
  final List<String> rams;
  final List<String> roms;
  final List<String> colors;
  final List<String> itemCategories;

  ProductFilters({
    required this.companies,
    required this.models,
    required this.rams,
    required this.roms,
    required this.colors,
    required this.itemCategories,
  });

  factory ProductFilters.fromJson(Map<String, dynamic> json) {
    return ProductFilters(
      companies: _parseStringList(json['companies']),
      models: _parseStringList(json['models']),
      rams: _parseStringList(json['rams']),
      roms: _parseStringList(json['roms']),
      colors: _parseStringList(json['colors']),
      itemCategories: _parseStringList(json['itemCategories']),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList();
    }
    return [];
  }
}