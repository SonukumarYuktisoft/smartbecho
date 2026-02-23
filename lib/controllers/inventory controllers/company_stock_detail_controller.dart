// controllers/company_stock_details_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/inventory%20controllers/inventory_management_controller.dart';
import 'package:smartbecho/models/inventory%20management/inventory_item_model.dart';
import 'package:smartbecho/models/inventory%20management/stock_item_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/utils/app_colors.dart';

class CompanyStockDetailsController extends GetxController {
  // API service instance
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Observable variables
  var isLoading = false.obs;
  var stockItems = <StockItem>[].obs;
  var filteredItems = <StockItem>[].obs;

  // Lazy loading variables
  var displayedItems = <StockItem>[].obs;
  var hasMoreItems = false.obs;
  var currentPage = 0.obs;
  static const int itemsPerPage = 20;

  // Filter and search variables
  var selectedFilter = 'All'.obs;
  var searchQuery = ''.obs;
  var selectedSort = 'Model Name'.obs;
  final TextEditingController searchController = TextEditingController();

  // Company information
  var companyName = ''.obs;

  // Debounce timer for search
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  // Filter and sort options
  final List<String> filterOptions = [
    'All',
    'In Stock',
    'Low Stock',
    'Out of Stock',
  ];

  final List<String> sortOptions = [
    'Model Name',
    'Stock (High to Low)',
    'Stock (Low to High)',
    'Price (High to Low)',
    'Price (Low to High)',
    'Recently Added',
  ];

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in filter, search, and sort
    ever(selectedFilter, (_) => _updateFilteredItems());
    ever(searchQuery, (_) => _updateFilteredItems());
    ever(selectedSort, (_) => _updateFilteredItems());
    ever(stockItems, (_) => _updateFilteredItems());
    ever(filteredItems, (_) => _updateDisplayedItems());
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    super.onClose();
  }

  // Initialize with company data
  void initializeWithCompany(String company, List<StockItem> items) {
    companyName.value = company;
    stockItems.value = items;
    _updateFilteredItems();
  }

  // Fetch stock items from API
  Future<void> fetchStockItems(String company) async {
    try {
      isLoading.value = true;
      companyName.value = company;

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/inventory/filter?company=$company',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data =
            response.data is String
                ? json.decode(response.data)
                : response.data;

        List<dynamic> stockList;
        if (data is Map<String, dynamic> && data.containsKey('payload')) {
          stockList = data['payload'] as List<dynamic>;
        } else if (data is List<dynamic>) {
          stockList = data;
        } else {
          throw Exception('Unexpected response format');
        }

        stockItems.value =
            stockList.map((json) => StockItem.fromJson(json)).toList();

        log("Stock items loaded successfully for $company");
        log("Total items: ${stockItems.length}");
      }
    } catch (error) {
      log("❌ Error in fetchStockItems: $error");
      Get.snackbar('Error', 'Failed to fetch stock items');
    } finally {
      isLoading.value = false;
    }
  }

  // Update search query with debouncing
  void updateSearchQueryWithDebounce(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      searchQuery.value = query;
    });
  }

  // Update search query immediately
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Update filter
  void updateFilter(String filter) {
    selectedFilter.value = filter;
  }

  // Update sort
  void updateSort(String sort) {
    selectedSort.value = sort;
  }

  // Private method to update filtered items
  void _updateFilteredItems() {
    List<StockItem> items = List.from(stockItems);

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      items =
          items
              .where(
                (item) =>
                    item.model.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ||
                    item.color.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Apply category filter
    if (selectedFilter.value != 'All') {
      items =
          items.where((item) {
            switch (selectedFilter.value) {
              case 'In Stock':
                return !item.isOutOfStock && !item.isLowStock;
              case 'Low Stock':
                return item.isLowStock && !item.isOutOfStock;
              case 'Out of Stock':
                return item.isOutOfStock;
              default:
                return true;
            }
          }).toList();
    }

    // Apply sorting
    items.sort((a, b) {
      switch (selectedSort.value) {
        case 'Model Name':
          return a.model.compareTo(b.model);
        case 'Stock (High to Low)':
          return b.qty.compareTo(a.qty);
        case 'Stock (Low to High)':
          return a.qty.compareTo(b.qty);
        case 'Price (High to Low)':
          return b.sellingPrice.compareTo(a.sellingPrice);
        case 'Price (Low to High)':
          return a.sellingPrice.compareTo(b.sellingPrice);
        case 'Recently Added':
          return b.formattedDate.compareTo(a.formattedDate);
        default:
          return 0;
      }
    });

    filteredItems.value = items;
  }

  // Update displayed items for lazy loading
  void _updateDisplayedItems() {
    currentPage.value = 0;

    if (filteredItems.isEmpty) {
      displayedItems.value = [];
      hasMoreItems.value = false;
      return;
    }

    final int endIndex = itemsPerPage.clamp(0, filteredItems.length);
    displayedItems.value = filteredItems.take(endIndex).toList();
    hasMoreItems.value = filteredItems.length > itemsPerPage;
  }

  // Load more items for pagination
  void loadMoreItems() {
    if (!hasMoreItems.value || isLoading.value) return;

    final int nextPage = currentPage.value + 1;
    final int startIndex = nextPage * itemsPerPage;
    final int endIndex = (startIndex + itemsPerPage).clamp(
      0,
      filteredItems.length,
    );

    if (startIndex < filteredItems.length) {
      final newItems = filteredItems.sublist(startIndex, endIndex);
      displayedItems.addAll(newItems);
      currentPage.value = nextPage;

      // Check if there are more items
      hasMoreItems.value = endIndex < filteredItems.length;
    } else {
      hasMoreItems.value = false;
    }
  }

  // Getters for UI
  int get totalStock => stockItems.fold(0, (sum, item) => sum + item.qty);

  int get lowStockCount =>
      stockItems.where((item) => item.isLowStock && !item.isOutOfStock).length;

  int get outOfStockCount =>
      stockItems.where((item) => item.isOutOfStock).length;

  Color get totalStockColor {
    if (totalStock == 0) return const Color(0xFFEF4444);
    if (totalStock < 50) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  // Helper methods for UI
  Color getCompanyColor(String company) {
    final colors = {
      'apple': const Color(0xFF007AFF),
      'samsung': const Color(0xFF1428A0),
      'google': const Color(0xFF4285F4),
      'xiaomi': const Color(0xFFFF6900),
      'oneplus': const Color(0xFFEB0028),
      'realme': const Color(0xFFFFC900),
      'oppo': const Color(0xFF1BA784),
      'vivo': const Color(0xFF4A90E2),
      'nokia': const Color(0xFF124191),
      'honor': const Color(0xFF2C5BFF),
      'infinix': const Color(0xFF00D4FF),
    };
    return colors[company.toLowerCase()] ?? const Color(0xFF8B5CF6);
  }

  Color getColorForVariant(String color) {
    final colors = {
      'black': const Color(0xFF1F2937),
      'white': const Color(0xFF9CA3AF),
      'blue': const Color(0xFF3B82F6),
      'red': const Color(0xFFEF4444),
      'green': const Color(0xFF10B981),
      'grey': const Color(0xFF6B7280),
      'gray': const Color(0xFF6B7280),
      'gold': const Color(0xFFF59E0B),
      'silver': const Color(0xFF9CA3AF),
      'purple': const Color(0xFF8B5CF6),
      'pink': const Color(0xFFEC4899),
      'orange': const Color(0xFFF97316),
      'cyan': const Color(0xFF06B6D4),
      'navy': const Color(0xFF1E40AF),
      'skylight': const Color(0xFF0EA5E9),
      'cyber': const Color(0xFF1F2937),
    };

    for (String key in colors.keys) {
      if (color.toLowerCase().contains(key)) {
        return colors[key]!;
      }
    }
    return const Color(0xFF6B7280);
  }

  Color getStockStatusColor(StockItem item) {
    if (item.isOutOfStock) return const Color(0xFFEF4444);
    if (item.isLowStock) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  IconData getStockStatusIcon(StockItem item) {
    if (item.isOutOfStock) return Icons.error;
    if (item.isLowStock) return Icons.warning;
    return Icons.check_circle;
  }

  Widget getFilterIcon(String filter) {
    switch (filter) {
      case 'All':
        return const Icon(Icons.apps, size: 16, color: Color(0xFF6B7280));
      case 'In Stock':
        return const Icon(
          Icons.check_circle,
          size: 16,
          color: Color(0xFF10B981),
        );
      case 'Low Stock':
        return const Icon(Icons.warning, size: 16, color: Color(0xFFF59E0B));
      case 'Out of Stock':
        return const Icon(Icons.error, size: 16, color: Color(0xFFEF4444));
      default:
        return const Icon(
          Icons.filter_list,
          size: 16,
          color: Color(0xFF6B7280),
        );
    }
  }

  // Action methods
  void updateStock(StockItem item) {
    // Implement update stock functionality
    log("Update stock for ${item.model}");
    // You can show a dialog or navigate to update screen
    Get.dialog(
      AlertDialog(
        title: Text('Update Stock'),
        content: Text('Update stock for ${item.model}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              // Add your update stock logic here
              Get.back();
              Get.snackbar('Success', 'Stock updated successfully');
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void sellItem(StockItem item) {
    Get.find<InventoryController>().sellItem(
      InventoryItem.fromJson(item.toJson()),
    );
  }

  void viewDetails(StockItem item) {
    // Implement view details functionality
    log("View details for ${item.model}");

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 350,
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradientLight,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.phone_android,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.model,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            item.company,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          item.stockStatus,
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(item.stockStatus),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item.stockStatus,
                        style: TextStyle(
                          color: _getStatusColor(item.stockStatus),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Color',
                      item.color,
                      Icons.color_lens_outlined,
                      Colors.orange,
                    ),
                    Divider(height: 24),
                    _buildDetailRow(
                      'RAM/ROM',
                      item.ramRomDisplay,
                      Icons.memory_outlined,
                      Colors.blue,
                    ),
                    Divider(height: 24),
                    _buildDetailRow(
                      'Stock',
                      '${item.qty} units',
                      Icons.inventory_2_outlined,
                      Colors.green,
                    ),
                    Divider(height: 24),
                    _buildDetailRow(
                      'Price',
                      item.formattedPrice,
                      Icons.attach_money_outlined,
                      Colors.purple,
                    ),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryLight,
                        elevation: 0,
                        side: BorderSide(color: AppColors.primaryLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text('Close'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        updateStock(item);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: Text('Update Stock'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for detail rows
  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Out of Stock':
        return Colors.red;
      case 'Low Stock':
        return Colors.orange;
      case 'In Stock':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  void refreshData() {
    if (companyName.value.isNotEmpty) {
      fetchStockItems(companyName.value);
    }
  }

  // Method to reset filters
  void resetFilters() {
    selectedFilter.value = 'All';
    selectedSort.value = 'Model Name';
    searchController.clear();
    searchQuery.value = '';
  }

  // Method to apply multiple filters at once
  void applyFilters({String? filter, String? sort, String? search}) {
    if (filter != null) selectedFilter.value = filter;
    if (sort != null) selectedSort.value = sort;
    if (search != null) {
      searchController.text = search;
      searchQuery.value = search;
    }
  }
}
