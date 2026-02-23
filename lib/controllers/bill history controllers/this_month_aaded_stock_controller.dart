import 'dart:developer';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smartbecho/models/bill%20history/this_month_added_stock_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';

class ThisMonthStockController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Stock items data
  final RxList<ThisMonthStockItem> stockItems = <ThisMonthStockItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Stats
  final RxInt totalItems = 0.obs;
  final RxInt totalQuantity = 0.obs;
  final RxDouble totalValue = 0.0.obs;
  final RxInt uniqueModels = 0.obs;
  final RxInt uniqueCompanies = 0.obs;

  // Filter options
  final RxString selectedCompany = 'All'.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString sortBy = 'createdDate'.obs;
  final RxString sortDir = 'desc'.obs;

  // Dropdown options
  final RxList<String> companyOptions = <String>['All'].obs;
  final RxList<String> categoryOptions = <String>['All'].obs;
  final List<String> sortOptions = [
    'createdDate',
    'model',
    'sellingPrice',
    'company',
    'qty',
  ];

  // Filtered items
  RxList<ThisMonthStockItem> get filteredItems {
    var items = List<ThisMonthStockItem>.from(stockItems);

    // Apply company filter
    if (selectedCompany.value != 'All') {
      items = items.where((item) => 
        item.company.toLowerCase() == selectedCompany.value.toLowerCase()
      ).toList();
    }

    // Apply category filter
    if (selectedCategory.value != 'All') {
      items = items.where((item) => 
        item.itemCategory.toLowerCase() == selectedCategory.value.toLowerCase()
      ).toList();
    }

    // Apply sorting
    items.sort((a, b) {
      int comparison = 0;
      switch (sortBy.value) {
        case 'createdDate':
          comparison = a.createdDate.compareTo(b.createdDate);
          break;
        case 'model':
          comparison = a.model.compareTo(b.model);
          break;
        case 'sellingPrice':
          comparison = a.sellingPrice.compareTo(b.sellingPrice);
          break;
        case 'company':
          comparison = a.company.compareTo(b.company);
          break;
        case 'qty':
          comparison = a.qty.compareTo(b.qty);
          break;
      }
      return sortDir.value == 'asc' ? comparison : -comparison;
    });

    return items.obs;
  }

  @override
  void onInit() {
    super.onInit();
    loadThisMonthStock();
  }

  Future<void> loadThisMonthStock() async {
    isLoading.value = true;
    error.value = '';

    try {
      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/products/stats/this-month',
        authToken: true,
      );

      if (response == null || response.statusCode != 200) {
        error.value = 'Failed to load this month stock data';
        log('Failed to load stock data');
        return;
      }

      final stockResponse = ThisMonthStockResponse.fromJson(response.data);
      stockItems.value = stockResponse.payload;
      
      _calculateStats();
      _extractFilterOptions();

    } catch (e) {
      error.value = 'Error: $e';
      log('Error loading stock data: $e');
      log('Error loading this month stock: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    final items = filteredItems;
    
    totalItems.value = items.length;
    totalQuantity.value = items.fold(0, (sum, item) => sum + item.qty);
    totalValue.value = items.fold(0.0, (sum, item) => sum + (item.sellingPrice * item.qty));
    
    uniqueModels.value = items.map((item) => item.model.toLowerCase()).toSet().length;
    uniqueCompanies.value = items.map((item) => item.company.toLowerCase()).toSet().length;
  }

  void _extractFilterOptions() {
    // Extract unique companies
    final companies = stockItems
        .map((item) => item.companyDisplayName)
        .toSet()
        .toList();
    companies.sort();
    companyOptions.value = ['All', ...companies];

    // Extract unique categories
    final categories = stockItems
        .map((item) => item.categoryDisplayName)
        .toSet()
        .toList();
    categories.sort();
    categoryOptions.value = ['All', ...categories];
  }

  // Filter methods
  void onCompanyChanged(String? company) {
    selectedCompany.value = company ?? 'All';
    _calculateStats();
  }

  void onCategoryChanged(String? category) {
    selectedCategory.value = category ?? 'All';
    _calculateStats();
  }

  void onSortChanged(String field) {
    if (sortBy.value == field) {
      sortDir.value = sortDir.value == 'asc' ? 'desc' : 'asc';
    } else {
      sortBy.value = field;
      sortDir.value = 'desc';
    }
  }

  void resetFilters() {
    selectedCompany.value = 'All';
    selectedCategory.value = 'All';
    sortBy.value = 'createdDate';
    sortDir.value = 'desc';
    _calculateStats();
  }

  Future<void> refreshData() async {
    await loadThisMonthStock();
  }

  // UI Helper methods (inherited from BillHistoryController)
  Color getCompanyColor(String company) {
    switch (company.toLowerCase()) {
      case 'apple':
        return Color(0xFF1E293B);
      case 'samsung':
        return Color(0xFF3B82F6);
      case 'xiaomi':
      case 'redmi':
        return Color(0xFFF59E0B);
      case 'oneplus':
        return Color(0xFFEF4444);
      case 'mix':
      case 'mixu':
        return Color(0xFF8B5CF6);
      case 'vivo':
        return Color(0xFF4338CA);
      case 'oppo':
        return Color(0xFF059669);
      default:
        return Color(0xFF6B7280);
    }
  }

  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'smartphone':
        return Color(0xFF3B82F6);
      case 'tablet':
        return Color(0xFF10B981);
      case 'charger':
        return Color(0xFF10B981);
      case 'earphones':
      case 'headphones':
        return Color(0xFF8B5CF6);
      case 'cover':
        return Color(0xFFF59E0B);
      case 'power_bank':
        return Color(0xFFEF4444);
      default:
        return Color(0xFF6B7280);
    }
  }

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'smartphone':
        return Icons.smartphone;
      case 'tablet':
        return Icons.tablet;
      case 'charger':
        return Icons.battery_charging_full;
      case 'earphones':
      case 'headphones':
        return Icons.headphones;
      case 'cover':
        return Icons.phone_android;
      case 'power_bank':
        return Icons.battery_std;
      default:
        return Icons.devices_other;
    }
  }

  IconData getCompanyIcon(String company) {
    switch (company.toLowerCase()) {
      case 'apple':
        return Icons.phone_iphone;
      case 'samsung':
        return Icons.smartphone;
      case 'xiaomi':
      case 'redmi':
        return Icons.phone_android;
      case 'oneplus':
        return Icons.phone_android;
      default:
        return Icons.devices;
    }
  }



  String getSortDisplayName(String sortField) {
    switch (sortField) {
      case 'createdDate':
        return 'Date Added';
      case 'model':
        return 'Model';
      case 'sellingPrice':
        return 'Price';
      case 'company':
        return 'Company';
      case 'qty':
        return 'Quantity';
      default:
        return sortField;
    }
  }


  String get formateTotalItem => totalItems.value.toString(); 
}