import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:smartbecho/controllers/bill%20history%20controllers/this_month_aaded_stock_controller.dart';
import 'package:smartbecho/models/bill%20history/bill_history_model.dart';
import 'package:smartbecho/models/bill%20history/stock_history_item_response.dart';
import 'package:smartbecho/models/bill%20history/stock_stats_reponse_model.dart';
import 'package:smartbecho/models/inventory%20management/filter_response_model.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:smartbecho/views/bill%20history/components/bill_analytics.dart';
class SortOption {
  final String label; 
  final String value;
  const SortOption({
    required this.label,
    required this.value,
  });
}
class BillHistoryController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;
  final ThisMonthStockController thisMonthStockController = Get.put(
    ThisMonthStockController(),
  );

  // Bills data
  final RxList<Bill> bills = <Bill>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isLoadingStats = false.obs;
  final RxString error = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxBool hasMore = true.obs;
  final RxInt totalElements = 0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxInt totalQty = 0.obs;

  // Stock items data
  final RxList<StockItem> stockItems = <StockItem>[].obs;
  final RxBool isLoadingStock = false.obs;
  final RxBool isLoadingMoreStock = false.obs;
  final RxString stockError = ''.obs;
  final RxInt stockCurrentPage = 0.obs;
  final RxBool stockHasMore = true.obs;
  final RxInt totalStockItems = 0.obs;
  final RxInt totalQtyAdded = 0.obs;
  final RxInt totalDistinctCompanies = 0.obs;

  // Stats data
  final Rx<StockStats?> stockStats = Rx<StockStats?>(null);

  // Filter options for bills
  final RxString selectedCompany = 'All'.obs;
  final RxString timePeriodType =
      'Month/Year'.obs; // 'Month/Year' or 'Custom Date'
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString sortBy = 'billId'.obs;
  final RxString sortDir = 'asc'.obs;

  // Filter options for stocks
  final RxString selectedStockCompany = 'All'.obs;
  final RxString selectedCategory = 'All'.obs;
  final RxString stockTimePeriodType = 'Month/Year'.obs;
  final RxInt stockSelectedMonth = DateTime.now().month.obs;
  final RxInt stockSelectedYear = DateTime.now().year.obs;
  final Rx<DateTime?> stockStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> stockEndDate = Rx<DateTime?>(null);
  final RxString stockSortBy = 'createdDate'.obs;
  final RxString stockSortDir = 'desc'.obs;
  final RxString searchKeyword = ''.obs;

  // Dropdown options
  final RxList<String> companyOptions = <String>['All'].obs;
  final RxList<String> stockCompanyOptions = <String>['All'].obs;
  final RxList<String> categoryOptions = <String>['All'].obs;
  final List<String> timePeriodOptions = ['Month/Year', 'Custom Date'];
  // final List<String> sortOptions = ['billId', 'date', 'amount', 'companyName'];
final List<SortOption> sortOptions = const [
  SortOption(label: 'Bill Id', value: 'billId'),
  SortOption(label: 'Date', value: 'date'),
  SortOption(label: 'Amount', value: 'amount'),
  SortOption(label: 'Company Name', value: 'companyName'),
];



  final List<String> stockSortOptions = [
    'createdDate',
    'model',
    'sellingPrice',
    'company',
    'qty',
  ];

  final TextEditingController searchheadController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Your existing properties...

  // Add this method
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    // onSearchChanged();
  }

  // Date controllers for custom date picker
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController stockStartDateController =
      TextEditingController();
  final TextEditingController stockEndDateController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // ============================================
  // 1. CONTROLLER UPDATES (bill_history_controller.dart)
  // ============================================

  // Add debounce worker at the top of the class
  Worker? _searchDebouncer;

  @override
  void onInit() {
    super.onInit();

    // Set up search debouncer
    _searchDebouncer = debounce(
      searchKeyword,
      (String query) => loadStockItems(refresh: true),
      time: const Duration(milliseconds: 800),
    );

    loadInitialData();
    loadStockHistoryData();
    loadStats();
    thisMonthStockController.loadThisMonthStock();
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    stockStartDateController.dispose();
    stockEndDateController.dispose();
    searchController.dispose();
    _searchDebouncer?.dispose();
    super.onClose();
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      loadCompanyOptions(),
      loadCategoryOptions(),
      loadStats(),
      loadBills(refresh: true),
    ]);
  }

  Future<void> refreshAll() async {
    log('🔄 Refreshing all data...');

    try {
      await Future.wait([
        loadBills(refresh: true),
        loadStockItems(refresh: true),
        loadStats(),
        loadCompanyOptions(),
        loadStockCompanyOptions(),
        loadCategoryOptions(),
      ]);

      log('✅ All data refreshed successfully');
    } catch (e) {
      log('❌ Error refreshing all data: $e');
    }
  }

  Future<void> loadStockHistoryData() async {
    await Future.wait([
      loadStockItems(refresh: false),

      loadStockCompanyOptions(),
    ]);
  }

  // Stock-related methods
  Future<void> loadCategoryOptions() async {
    try {
      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/inventory/item-types',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final List<dynamic> categories = response.data ?? [];
        categoryOptions.value = ['All', ...categories.cast<String>()];
      }
    } catch (e) {
      log('Error loading category options: $e');
    }
  }

  Future<void> loadStockCompanyOptions() async {
    try {
      final response = await _apiService.requestGetForApi(
        url: _config.getInventoryFilters,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data =
            response.data is String
                ? json.decode(response.data)
                : response.data;
        final filterResponse = FilterResponse.fromJson(data);

        stockCompanyOptions.value = ['All', ...filterResponse.companies];
      }
    } catch (e) {
      log('Error loading stock company options: $e');
    }
  }

  Future<void> loadStockItems({bool refresh = false}) async {
    if (refresh) {
      stockCurrentPage.value = 0;
      stockHasMore.value = true;
      stockItems.clear();
    }

    if (isLoadingStock.value) return;
    isLoadingStock.value = true;
    stockError.value = '';

    try {
      final queryParams = <String, String>{
        'page': stockCurrentPage.value.toString(),
        'size': '10',
        'sortBy': stockSortBy.value,
        'sortDir': stockSortDir.value,
      };

      // Add search keyword
      if (searchKeyword.value.isNotEmpty) {
        queryParams['keyword'] = searchKeyword.value;
      }

      // Add company filter
      if (selectedStockCompany.value != 'All') {
        queryParams['company'] = selectedStockCompany.value;
      }

      // Add category filter
      if (selectedCategory.value != 'All') {
        queryParams['itemCategory'] = selectedCategory.value;
      }

      // Add time period filters
      if (selectedStockCompany.value.isEmpty) {
        if (stockTimePeriodType.value == 'Month/Year') {
          queryParams['month'] = stockSelectedMonth.value.toString();
          queryParams['year'] = stockSelectedYear.value.toString();
        } else if (stockTimePeriodType.value == 'Custom Date' &&
            stockStartDate.value != null &&
            stockEndDate.value != null) {
          queryParams['startDate'] = _formatDate(stockStartDate.value!);
          queryParams['endDate'] = _formatDate(stockEndDate.value!);
        }
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/stock-items/all',
        dictParameter: queryParams,
        authToken: true,
      );

      if (response == null || response.statusCode != 200) {
        stockError.value = 'Failed to load stock items';
      } else {
        final parsed = StockItemsResponse.fromJson(response.data);

        if (refresh) {
          stockItems.clear();
        }

        stockItems.addAll(parsed.items);
        totalStockItems.value = parsed.totalItems;
        totalQtyAdded.value = parsed.totalQtyAdded;
        totalDistinctCompanies.value = parsed.totalDistinctCompanies;
        stockHasMore.value = !parsed.last;
      }
    } catch (e) {
      stockError.value = 'Error: $e';
      log('Error loading stock items: $e');
    } finally {
      isLoadingStock.value = false;
    }
  }

  Future<void> loadMoreStockItems() async {
    if (isLoadingMoreStock.value || !stockHasMore.value || isLoadingStock.value)
      return;

    isLoadingMoreStock.value = true;
    stockCurrentPage.value++;

    try {
      final queryParams = <String, String>{
        'page': stockCurrentPage.value.toString(),
        'size': '10',
        'sortBy': stockSortBy.value,
        'sortDir': stockSortDir.value,
      };

      // Add search keyword
      if (searchKeyword.value.isNotEmpty) {
        queryParams['keyword'] = searchKeyword.value;
      }

      // Add company filter
      if (selectedStockCompany.value != 'All') {
        queryParams['company'] = selectedStockCompany.value;
      }

      // Add category filter
      if (selectedCategory.value != 'All') {
        queryParams['itemCategory'] = selectedCategory.value;
      }

      // Add time period filters
      if (stockTimePeriodType.value == 'Month/Year') {
        queryParams['month'] = stockSelectedMonth.value.toString();
        queryParams['year'] = stockSelectedYear.value.toString();
      } else if (stockTimePeriodType.value == 'Custom Date' &&
          stockStartDate.value != null &&
          stockEndDate.value != null) {
        queryParams['startDate'] = _formatDate(stockStartDate.value!);
        queryParams['endDate'] = _formatDate(stockEndDate.value!);
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/stock-items/all',
        dictParameter: queryParams,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final parsed = StockItemsResponse.fromJson(response.data);
        stockItems.addAll(parsed.items);
        stockHasMore.value = !parsed.last;
      } else {
        stockCurrentPage.value--;
        log('Failed to load more stock items');
      }
    } catch (e) {
      stockCurrentPage.value--;
      log('Error loading more stock items: $e');
    } finally {
      isLoadingMoreStock.value = false;
    }
  }

  // Stock filter methods
  void onStockCompanyChanged(String? company) {
    searchKeyword.value = '';

    searchController.clear();

    selectedStockCompany.value = company ?? 'All';
    loadStockItems(refresh: true);
  }

  void onCategoryChanged(String? category) {
    searchKeyword.value = '';

    searchController.clear();

    selectedCategory.value = category ?? 'All';
    loadStockItems(refresh: true);
  }

  void onStockTimePeriodTypeChanged(String? type) {
    searchKeyword.value = '';

    searchController.clear();

    stockTimePeriodType.value = type ?? 'Month/Year';
    loadStockItems(refresh: true);
  }

  void onStockMonthChanged(int? month) {
    searchKeyword.value = '';

    searchController.clear();

    stockSelectedMonth.value = month ?? DateTime.now().month;
    if (stockTimePeriodType.value == 'Month/Year') {
      loadStockItems(refresh: true);
    }
  }

  void onStockYearChanged(int? year) {
    searchKeyword.value = '';

    searchController.clear();

    stockSelectedYear.value = year ?? DateTime.now().year;
    if (stockTimePeriodType.value == 'Month/Year') {
      loadStockItems(refresh: true);
    }
  }

  void onStockStartDateChanged(DateTime? date) {
    searchKeyword.value = '';

    searchController.clear();

    stockStartDate.value = date;
    stockStartDateController.text =
        date != null ? _formatDisplayDate(date) : '';
    if (stockTimePeriodType.value == 'Custom Date' &&
        stockEndDate.value != null) {
      loadStockItems(refresh: true);
    }
  }

  void onStockEndDateChanged(DateTime? date) {
    searchController.clear();
    searchKeyword.value = '';

    stockEndDate.value = date;
    stockEndDateController.text = date != null ? _formatDisplayDate(date) : '';
    if (stockTimePeriodType.value == 'Custom Date' &&
        stockStartDate.value != null) {
      loadStockItems(refresh: true);
    }
  }

  void onStockSortChanged(String field) {
    searchController.clear();

    if (stockSortBy.value == field) {
      stockSortDir.value = stockSortDir.value == 'asc' ? 'desc' : 'asc';
    } else {
      stockSortBy.value = field;
      stockSortDir.value = 'desc';
    }
    loadStockItems(refresh: true);
  }

  void onSearchChanged(String keyword) {
    // Just update the search keyword - let debounce handle the API call
    searchKeyword.value = keyword.trim();
  }

  void clearStockSearch() {
    searchController.clear();
    searchKeyword.value = '';
  }

  Future<void> refreshStockItems() async {
    await loadStockItems(refresh: true);
  }

  // Original bill methods remain unchanged...
  Future<void> loadCompanyOptions() async {
    try {
      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/purchase-bills/company/dropdown',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final List<dynamic> companies = response.data ?? [];
        companyOptions.value = ['All', ...companies.cast<String>()];
      }
    } catch (e) {
      log('Error loading company options: $e');
    }
  }

  Future<void> loadStats() async {
    isLoadingStats.value = true;
    try {
      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/stock-items/stats',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        stockStats.value = StockStats.fromJson(response.data);
      }
    } catch (e) {
      log('Error loading stats: $e');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> loadBills({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 0;
      hasMore.value = true;
      bills.clear();
    }

    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';

    try {
      final queryParams = <String, String>{
        'page': currentPage.value.toString(),
        'size': '10',
        'sortBy': sortBy.value,
        'sortDir': sortDir.value,
      };

      // Add company filter
      if (selectedCompany.value != 'All') {
        queryParams['companyName'] = selectedCompany.value;
      }

      // Add time period filters
      if (timePeriodType.value == 'Month/Year') {
        queryParams['month'] = selectedMonth.value.toString();
        queryParams['year'] = selectedYear.value.toString();
      } else if (timePeriodType.value == 'Custom Date' &&
          startDate.value != null &&
          endDate.value != null) {
        queryParams['startDate'] = _formatDate(startDate.value!);
        queryParams['endDate'] = _formatDate(endDate.value!);
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/purchase-bills',
        dictParameter: queryParams,
        authToken: true,
      );

      if (response == null || response.statusCode != 200) {
        error.value = 'Failed to load bills';
        log('Failed to load bills');
      } else {
        final parsed = BillsResponse.fromJson(response.data);

        if (refresh) {
          bills.clear();
        }

        // ✅ 1️⃣ Temporary list lo
        final List<Bill> sortedBills = List.from(parsed.bills);

        // ✅ Correct - comparing actual DateTime objects
        sortedBills.sort((a, b) {
          return b.date.compareTo(a.date);
        });

        // ✅ 3️⃣ Controller list mein add karo
        bills.addAll(sortedBills);

        totalElements.value = parsed.totalElements;
        totalAmount.value = parsed.totalAmount;
        totalQty.value = parsed.totalQty;
        hasMore.value = !parsed.last;
      }
    } catch (e) {
      error.value = 'Error: $e';
      log('Error loading bills: $e');
      // _showErrorSnackbar('Error loading bills: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreBills() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    isLoadingMore.value = true;
    currentPage.value++;

    try {
      final queryParams = <String, String>{
        'page': currentPage.value.toString(),
        'size': '10',
        'sortBy': sortBy.value,
        'sortDir': sortDir.value,
      };

      // Add company filter
      if (selectedCompany.value != 'All') {
        queryParams['companyName'] = selectedCompany.value;
      }

      // Add time period filters
      if (timePeriodType.value == 'Month/Year') {
        queryParams['month'] = selectedMonth.value.toString();
        queryParams['year'] = selectedYear.value.toString();
      } else if (timePeriodType.value == 'Custom Date' &&
          startDate.value != null &&
          endDate.value != null) {
        queryParams['startDate'] = _formatDate(startDate.value!);
        queryParams['endDate'] = _formatDate(endDate.value!);
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/purchase-bills',
        dictParameter: queryParams,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final parsed = BillsResponse.fromJson(response.data);

        bills.addAll(parsed.bills);
        hasMore.value = !parsed.last;
      } else {
        currentPage.value--;
        log('Failed to load more bills');
      }
    } catch (e) {
      currentPage.value--;
      // _showErrorSnackbar('Error loading more bills: $e');
      log('Error loading more bills: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void showAnalyticsModal() {
    Get.bottomSheet(
      BillAnalyticsScreen(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    // Get.toNamed(AppRoutes.billAnalytics);
  }

  void navigateToThisMonthStock() {
    Get.toNamed(AppRoutes.thisMonthAddedStock);
  }

  // Filter methods for bills
  void onCompanyChanged(String? company) {
    selectedCompany.value = company ?? 'All';
    loadBills(refresh: true);
  }

  void onTimePeriodTypeChanged(String? type) {
    timePeriodType.value = type ?? 'Month/Year';
    loadBills(refresh: true);
  }

  void onMonthChanged(int? month) {
    selectedMonth.value = month ?? DateTime.now().month;
    if (timePeriodType.value == 'Month/Year') {
      loadBills(refresh: true);
    }
  }

  void onYearChanged(int? year) {
    selectedYear.value = year ?? DateTime.now().year;
    if (timePeriodType.value == 'Month/Year') {
      loadBills(refresh: true);
    }
  }

  void onStartDateChanged(DateTime? date) {
    startDate.value = date;
    startDateController.text = date != null ? _formatDisplayDate(date) : '';
    if (timePeriodType.value == 'Custom Date' && endDate.value != null) {
      loadBills(refresh: true);
    }
  }

  void onEndDateChanged(DateTime? date) {
    endDate.value = date;
    endDateController.text = date != null ? _formatDisplayDate(date) : '';
    if (timePeriodType.value == 'Custom Date' && startDate.value != null) {
      loadBills(refresh: true);
    }
  }

  void onSortChanged(String field) {
    if (sortBy.value == field) {
      sortDir.value = sortDir.value == 'asc' ? 'desc' : 'asc';
    } else {
      sortBy.value = field;
      sortDir.value = 'desc';
    }
    loadBills(refresh: true);
  }

  RxBool hasActiveFilters = false.obs;

  void updateActiveFilters() {
    hasActiveFilters.value =
        selectedCompany.value != 'All' ||
        timePeriodType.value != 'Month/Year' ||
        startDate.value != null ||
        endDate.value != null;
  }

  void resetFilters() {
    selectedCompany.value = 'All';
    timePeriodType.value = 'Month/Year';
    selectedMonth.value = DateTime.now().month;
    selectedYear.value = DateTime.now().year;
    startDate.value = null;
    endDate.value = null;

    sortBy.value = 'billId';
    sortDir.value = 'desc';
    loadBills(refresh: true);
  }

  // Utility methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDisplayDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> refreshBills() async {
    await Future.wait([loadStats(), loadBills(refresh: true)]);
  }

  void navigateToBillDetails(Bill bill) {
    Get.toNamed('/bill-details', arguments: bill);
  }

  // UI Helper methods
  Color getStatusColor(Bill bill) {
    return bill.isPaid ? Color(0xFF10B981) : Color(0xFFF59E0B);
  }

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

  IconData getStatusIcon(Bill bill) {
    return bill.isPaid ? Icons.check_circle : Icons.pending;
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

  IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'smartphone':
      case 'feature_phone':
        return Icons.smartphone;
      case 'tablet':
        return Icons.tablet;
      case 'charger':
      case 'car_charger':
      case 'wireless_charger':
        return Icons.battery_charging_full;
      case 'earphones':
      case 'headphones':
        return Icons.headphones;
      case 'bluetooth_speaker':
        return Icons.speaker;
      case 'cover':
        return Icons.phone_android;
      case 'screen_guard':
        return Icons.shield;
      case 'power_bank':
        return Icons.battery_std;
      case 'memory_card':
        return Icons.sd_card;
      case 'smart_watch':
        return Icons.watch;
      case 'fitness_band':
        return Icons.fitness_center;
      default:
        return Icons.devices_other;
    }
  }

  String getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void resetStockFilters() {
    selectedStockCompany.value = 'All';
    selectedCategory.value = 'All';
    stockTimePeriodType.value = 'Month/Year';
    stockSelectedMonth.value = DateTime.now().month;
    stockSelectedYear.value = DateTime.now().year;
    stockStartDate.value = null;
    stockEndDate.value = null;
    stockStartDateController.clear();
    stockEndDateController.clear();
    stockSortBy.value = 'createdDate';
    stockSortDir.value = 'desc';
    searchController.clear();
    searchKeyword.value = '';
    loadStockItems(refresh: true);
    Get.back();
  }

  void resetStockClear() {
    selectedStockCompany.value = 'All';
    selectedCategory.value = 'All';
    stockTimePeriodType.value = 'Month/Year';
    stockSelectedMonth.value = DateTime.now().month;
    stockSelectedYear.value = DateTime.now().year;
    stockStartDate.value = null;
    stockEndDate.value = null;
    stockStartDateController.clear();
    stockEndDateController.clear();
    stockSortBy.value = 'createdDate';
    stockSortDir.value = 'desc';
    searchController.clear();
    searchKeyword.value = '';
    loadStockItems(refresh: true);
  }

  void addNewStocks() async {
    final bool isGtsAvailable =
        await SharedPreferencesHelper.getGstNumber() != null;
    Get.toNamed(
      AppRoutes.addNewStock,
      arguments: {"hasGstNumber": isGtsAvailable},
    );
  }

  List<String> get companyOptionsList =>
      companyOptions.where((c) => c != 'All').toList();

  String get formateOnlineStockTotal =>
      thisMonthStockController.totalQuantity.value.toString();
}
