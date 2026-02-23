import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_details_model.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_history_reponse_model.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_insights_stats_model.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_stats_model.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/services/download_service.dart';
import 'dart:developer';

import 'package:smartbecho/services/pdf_downloader_service.dart';

class SalesManagementController extends GetxController {
  // Utility methods
  bool get isSmallScreen => Get.width < 360;
  bool get isMediumScreen => Get.width >= 360 && Get.width < 400;
  double get screenWidth => Get.width;
  double get screenHeight => Get.height;

  // API service instance
  final ApiServices _apiService = ApiServices();
  final DownloadService _downloadService = DownloadService();
  final AppConfig _config = AppConfig.instance;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isStatsLoading = false.obs;
  final RxBool isLoadingFilters = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination Data
  final RxList<Sale> allSales = <Sale>[].obs;
  final RxList<Sale> filteredSales = <Sale>[].obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalElements = 0.obs;
  final RxBool hasNextPage = true.obs;
  final RxBool isLastPage = false.obs;

  /// Sales Insights Data

  // Stats Data
  final Rx<SalesStats?> statsData = Rx<SalesStats?>(null);
  final Rx<SalesInsightsStatsModel?> insightsStatsData =
      Rx<SalesInsightsStatsModel?>(null);

  // Search and Filters
  final RxString searchQuery = ''.obs;
  final RxString selectedTab =
      'dashboard'.obs; // 'dashboard', 'history', 'insights'
  final RxString selectedSort = 'saleDate,desc'.obs;
  final TextEditingController searchController = TextEditingController();

  // Sales detail
  final Rx<SaleDetailResponse?> saleDetail = Rx<SaleDetailResponse?>(null);
  final RxBool isLoadingDetail = false.obs;
  final RxBool hasDetailError = false.obs;
  final RxString detailErrorMessage = ''.obs;

  // Filter Parameters
  final RxString selectedCompany = RxString('');
  final RxString selectedItemCategory = RxString('');
  final RxString selectedPaymentMethod = RxString('');
  final RxString selectedPaymentMode = RxString('');
  final RxString dateFilterType = 'Month/Year'.obs;
  final RxnInt selectedMonth = RxnInt(null);
  final RxnInt selectedYear = RxnInt(null);
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);
  final RxString selectedSortBy = 'saleDate'.obs;
  final RxString selectedSortDir = 'desc'.obs;

  // Date Controllers
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  // Dynamic Filter Options (fetched from API)
  final RxList<String> companyOptions = <String>[].obs;
  final RxList<String> itemCategoryOptions = <String>[].obs;
  final RxList<String> paymentMethodOptions = <String>[].obs;

  // Static Filter Options
  final List<String> paymentModeOptions = ['All Modes', 'FULL', 'EMI', 'DUES'];

  final List<String> sortByOptions = [
    'saleDate',
    'saleAmount',
    'customerName',
    'invoiceNumber',
    'paymentMethod',
    'company',
  ];

  // Constants
  static const int pageSize = 10;

  // Computed property to check if any filters are active
  bool get hasActiveFilters {
    return (selectedCompany.value.isNotEmpty &&
            selectedCompany.value != 'All Companies') ||
        (selectedItemCategory.value.isNotEmpty &&
            selectedItemCategory.value != 'All Categories') ||
        (selectedPaymentMethod.value.isNotEmpty &&
            selectedPaymentMethod.value != 'All Methods') ||
        (selectedPaymentMode.value.isNotEmpty &&
            selectedPaymentMode.value != 'All Modes') ||
        (selectedMonth.value != null) ||
        (selectedYear.value != null) ||
        (dateFilterType.value == 'Date Range' &&
            (startDate.value != null || endDate.value != null));
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize filter options first, then fetch data
    _initializeFilterOptions();
    fetchSalesStats();
    fetchSalesInsights();
    fetchSalesHistory(isRefresh: true);

    // Listen to search changes with debounce
    debounce(
      searchQuery,
      (_) => _handleSearch(),
      time: Duration(
        milliseconds: 800,
      ), // Increased debounce time for API calls
    );
  }

  // Base URLs for sales API
  String get salesHistoryUrl => '${_config.baseUrl}/api/sales/shop-history';
  String get salesStatsUrl => '${_config.baseUrl}/api/sales/stats/today';
  String get salesInsightsStatsUrl => '${_config.baseUrl}/api/sales/stats';
  String get mobilesFiltersUrl => '${_config.baseUrl}/api/mobiles/filters';
  String get paymentAccountTypesUrl =>
      '${_config.baseUrl}/api/v1/dropdown/payment-account-types';

  // Initialize filter options by fetching from APIs
  Future<void> _initializeFilterOptions() async {
    await Future.wait([fetchMobilesFilters(), fetchPaymentMethods()]);
  }

  // Fetch mobiles filters (companies and categories)
  Future<void> fetchMobilesFilters() async {
    try {
      isLoadingFilters.value = true;
      log("Fetching mobiles filters...");

      dio.Response? response = await _apiService.requestGetForApi(
        url: mobilesFiltersUrl,
        authToken: true,
      );

      if (response != null && response.data != null) {
        final filtersData = response.data as Map<String, dynamic>;

        // Extract companies
        if (filtersData.containsKey('companies')) {
          List<String> companies = ['All Companies'];
          List<dynamic> apiCompanies =
              filtersData['companies'] as List<dynamic>;
          companies.addAll(
            apiCompanies.map((company) => company.toString()).toList(),
          );
          companyOptions.value = companies;
          log("Companies loaded: ${companies.length}");
        }

        // Extract item categories
        if (filtersData.containsKey('itemCategories')) {
          List<String> categories = ['All Categories'];
          List<dynamic> apiCategories =
              filtersData['itemCategories'] as List<dynamic>;
          categories.addAll(
            apiCategories.map((category) => category.toString()).toList(),
          );
          itemCategoryOptions.value = categories;
          log("Item categories loaded: ${categories.length}");
        }

        log("Mobiles filters loaded successfully");
      } else {
        throw Exception('No filters data received from server');
      }
    } catch (error) {
      log("❌ Error in fetchMobilesFilters: $error");
      // Fallback to default options if API fails
      _setDefaultFilterOptions();
    } finally {
      isLoadingFilters.value = false;
    }
  }

  // Fetch payment methods
  Future<void> fetchPaymentMethods() async {
    try {
      log("Fetching payment methods...");

      dio.Response? response = await _apiService.requestGetForApi(
        url: paymentAccountTypesUrl,
        authToken: true,
      );

      if (response != null && response.data != null) {
        List<String> methods = ['All Methods'];
        List<dynamic> apiMethods = response.data as List<dynamic>;
        methods.addAll(apiMethods.map((method) => method.toString()).toList());
        paymentMethodOptions.value = methods;
        log("Payment methods loaded: ${methods.length}");
      } else {
        throw Exception('No payment methods data received from server');
      }
    } catch (error) {
      log("❌ Error in fetchPaymentMethods: $error");
      // Fallback to default payment methods
      paymentMethodOptions.value = [
        'All Methods',
        'CASH',
        'BANK',
        'UPI',
        'CARD',
        'CHEQUE',
        'OTHERS',
      ];
    }
  }

  // Set default filter options as fallback
  void _setDefaultFilterOptions() {
    companyOptions.value = [
      'All Companies',
      'Samsung',
      'Apple',
      'Vivo',
      'Oppo',
      'Xiaomi',
      'Realme',
      'OnePlus',
      'Others',
    ];

    itemCategoryOptions.value = [
      'All Categories',
      'SMARTPHONE',
      'TABLET',
      'SMARTWATCH',
      'EARPHONE',
      'CHARGER',
      'POWER_BANK',
      'MOBILE_COVER',
      'TEMPERED_GLASS',
      'OTHERS',
    ];
  }

  // Refresh filter options
  Future<void> refreshFilterOptions() async {
    await _initializeFilterOptions();
  }

  // Filter event handlers
  void onCompanyChanged(String? company) {
    selectedCompany.value = company ?? '';
  }

  void onItemCategoryChanged(String? category) {
    selectedItemCategory.value = category ?? '';
  }

  void onPaymentMethodChanged(String? method) {
    selectedPaymentMethod.value = method ?? '';
  }

  void onPaymentModeChanged(String? mode) {
    selectedPaymentMode.value = mode ?? '';
  }

  void onDateFilterTypeChanged(String? type) {
    dateFilterType.value = type ?? 'Month/Year';
    // Clear opposite filter type data
    if (type == 'Month/Year') {
      startDate.value = null;
      endDate.value = null;
      startDateController.clear();
      endDateController.clear();
    } else {
      selectedMonth.value = null;
      selectedYear.value = null;
    }
  }

  void onMonthChanged(int? month) {
    selectedMonth.value = month;
  }

  void onYearChanged(int? year) {
    selectedYear.value = year;
  }

  void onStartDateChanged(DateTime date) {
    startDate.value = date;
    startDateController.text = '${date.day}/${date.month}/${date.year}';
  }

  void onEndDateChanged(DateTime date) {
    endDate.value = date;
    endDateController.text = '${date.day}/${date.month}/${date.year}';
  }

  void onSortByChanged(String? sortBy) {
    selectedSortBy.value = sortBy ?? 'saleDate';
  }

  void toggleSortDirection() {
    selectedSortDir.value = selectedSortDir.value == 'asc' ? 'desc' : 'asc';
  }

  void applyFilters() {
    log("Applying filters...");
    fetchSalesHistory(isRefresh: true);
  }

  void resetAllFilters() {
    selectedCompany.value = '';
    selectedItemCategory.value = '';
    selectedPaymentMethod.value = '';
    selectedPaymentMode.value = '';
    dateFilterType.value = 'Month/Year';
    selectedMonth.value = null;
    selectedYear.value = null;
    startDate.value = null;
    endDate.value = null;
    startDateController.clear();
    endDateController.clear();
    selectedSortBy.value = 'saleDate';
    selectedSortDir.value = 'desc';

    log("Filters reset");
    fetchSalesHistory(isRefresh: true);
  }

  // Fetch sales insights from API
  Future<void> fetchSalesInsights() async {
    try {
      isStatsLoading.value = true;

      log("Fetching sales insights...");

      final response = await _apiService.requestGetForApi(
        url: salesInsightsStatsUrl,
        authToken: true,
      );

      if (response != null) {
        final statsResponse = SalesInsightsStatsModel.fromJson(response.data);

        if (statsResponse.status == "Success") {
          insightsStatsData.value = statsResponse;
          log("Sales insights loaded successfully");
        } else {
          throw Exception(statsResponse.message);
        }
      } else {
        throw Exception('No stats data received from server');
      }
    } catch (error) {
      log("❌ Error in fetchSalesStats: $error");
    } finally {
      isStatsLoading.value = false;
    }
  }

  // Fetch sales stats from API
  Future<void> fetchSalesStats() async {
    try {
      isStatsLoading.value = true;

      log("Fetching sales stats...");

      dio.Response? response = await _apiService.requestGetForApi(
        url: salesStatsUrl,
        authToken: true,
      );

      if (response != null) {
        final statsResponse = SalesStatsResponse.fromJson(response.data);

        if (statsResponse.status == "Success") {
          statsData.value = statsResponse.payload;
          log("Sales stats loaded successfully");
        } else {
          throw Exception(statsResponse.message);
        }
      } else {
        throw Exception('No stats data received from server');
      }
    } catch (error) {
      log("❌ Error in fetchSalesStats: $error");
    } finally {
      isStatsLoading.value = false;
    }
  }

  // Fetch sales history from API with pagination, search, and filters
  Future<void> fetchSalesHistory({
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        currentPage.value = 0;
        allSales.clear();
        filteredSales.clear();
        hasError.value = false;
        errorMessage.value = '';
      } else if (isLoadMore) {
        if (isLastPage.value || isLoadingMore.value) return;
        isLoadingMore.value = true;
        currentPage.value++;
      }

      // Build query parameters according to API specification
      Map<String, dynamic> queryParams = {
        'page': currentPage.value,
        'size': pageSize,
        'sortBy': selectedSortBy.value,
        'sortDir': selectedSortDir.value,
      };

      // Add search keyword parameter if present
      if (searchQuery.value.isNotEmpty) {
        queryParams['keyword'] = searchQuery.value.trim();
      }

      // Add filter parameters
      if (selectedCompany.value.isNotEmpty &&
          selectedCompany.value != 'All Companies') {
        queryParams['company'] = selectedCompany.value;
      }

      if (selectedItemCategory.value.isNotEmpty &&
          selectedItemCategory.value != 'All Categories') {
        queryParams['itemCategory'] = selectedItemCategory.value;
      }

      if (selectedPaymentMethod.value.isNotEmpty &&
          selectedPaymentMethod.value != 'All Methods') {
        // Map UI payment method to API format
        String apiPaymentMethod = _mapPaymentMethodToApi(
          selectedPaymentMethod.value,
        );
        queryParams['paymentMethod'] = apiPaymentMethod;
      }

      if (selectedPaymentMode.value.isNotEmpty &&
          selectedPaymentMode.value != 'All Modes') {
        queryParams['paymentMode'] = selectedPaymentMode.value;
      }

      // Add date parameters based on filter type
      if (dateFilterType.value == 'Month/Year') {
        if (selectedYear.value != null) {
          queryParams['year'] = selectedYear.value;
        }
        if (selectedMonth.value != null) {
          queryParams['month'] = selectedMonth.value;
        }
      } else if (dateFilterType.value == 'Date Range') {
        if (startDate.value != null) {
          queryParams['startDate'] =
              '${startDate.value!.year}-${startDate.value!.month.toString().padLeft(2, '0')}-${startDate.value!.day.toString().padLeft(2, '0')}';
        }
        if (endDate.value != null) {
          queryParams['endDate'] =
              '${endDate.value!.year}-${endDate.value!.month.toString().padLeft(2, '0')}-${endDate.value!.day.toString().padLeft(2, '0')}';
        }
      }

      log("Fetching sales history with params: $queryParams");

      dio.Response? response = await _apiService.requestGetForApi(
        url: salesHistoryUrl,
        authToken: true,
        dictParameter: queryParams,
      );

      if (response != null) {
        final salesResponse = SalesHistoryResponse.fromJson(response.data);

        if (salesResponse.status == "Success") {
          // Update pagination info
          totalPages.value = salesResponse.payload.totalPages;
          totalElements.value = salesResponse.payload.totalElements;
          isLastPage.value = salesResponse.payload.last;
          hasNextPage.value = !salesResponse.payload.last;

          if (isRefresh) {
            // Fresh load
            allSales.value = List<Sale>.from(salesResponse.payload.content);
          } else if (isLoadMore) {
            // Append next page
            allSales.addAll(salesResponse.payload.content);
          }

          // ✅ ALWAYS SORT after modify
          allSales.sort((a, b) => b.saleDate.compareTo(a.saleDate));

          // ✅ filteredSales should follow sorted list
          filteredSales.value = List<Sale>.from(allSales);

          log("Sales history loaded successfully");
          log("Page: ${currentPage.value}, Total Pages: ${totalPages.value}");
          log("Total sales loaded: ${allSales.length}");
          log("Applied filters: ${queryParams.toString()}");
        } else {
          throw Exception(salesResponse.message);
        }
      } else {
        throw Exception('No data received from server');
      }
    } catch (error) {
      hasError.value = true;
      errorMessage.value = 'Error: $error';
      log("❌ Error in fetchSalesHistory: $error");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Map UI payment method to API format
  String _mapPaymentMethodToApi(String uiMethod) {
    switch (uiMethod.toUpperCase()) {
      case 'CARD':
        return 'BANK_CARD';
      case 'BANK':
        return 'BANK_TRANSFER';
      default:
        return uiMethod.toUpperCase();
    }
  }

  //fetch sales details
  Future<void> fetchSaleDetail(int saleId) async {
    try {
      isLoadingDetail.value = true;
      hasDetailError.value = false;
      detailErrorMessage.value = '';

      log("Fetching sale detail for ID: $saleId");

      dio.Response? response = await _apiService.requestGetForApi(
        url: "${_config.saleDetail}/$saleId",
        authToken: true,
      );

      if (response != null) {
        log("Sale detail response: ${response.data}");
        saleDetail.value = SaleDetailResponse.fromJson(response.data);
        log("Sale detail loaded successfully");
      } else {
        throw Exception('No sale detail data received from server');
      }
    } catch (error) {
      hasDetailError.value = true;
      detailErrorMessage.value = 'Error: $error';
      log("❌ Error in fetchSaleDetail: $error");
    } finally {
      isLoadingDetail.value = false;
    }
  }

  // Load more data for pagination
  Future<void> loadMoreSales() async {
    if (!hasNextPage.value || isLoadingMore.value) return;
    await fetchSalesHistory(isLoadMore: true);
  }

  // Handle search with API call (triggered by debounce)
  void _handleSearch() {
    log("Search triggered with query: '${searchQuery.value}'");
    currentPage.value = 0;
    fetchSalesHistory(isRefresh: true);
  }

  // This method is no longer needed since search is handled by API
  // Keeping it for backward compatibility but it won't do client-side filtering
  void filterSales() {
    // Since search is now handled by API, this method is primarily for
    // any additional client-side filtering if needed in the future
    filteredSales.value = allSales.toList();
  }

  // Event handlers
  void onSearchChanged() {
    String newQuery = searchController.text.trim();
    if (searchQuery.value != newQuery) {
      searchQuery.value = newQuery;
      log("Search query changed to: '$newQuery'");
    }
  }

  void onTabChanged(String tab) {
    selectedTab.value = tab;
  }

  void onSortChanged(String sort) {
    selectedSort.value = sort;
    log("Sort changed to: $sort");
    fetchSalesHistory(isRefresh: true);
  }

  // Actions
  Future<void> refreshData() async {
    await Future.wait([
      fetchSalesStats(),
      fetchSalesInsights(),
      fetchSalesHistory(isRefresh: true),
      refreshFilterOptions(),
    ]);
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    log("Search cleared");
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedSort.value = 'saleDate,desc';
    searchController.clear();
    resetAllFilters();
    log("Filters reset");
  }

  // Helper methods
  Color getCompanyColor(String companyName) {
    switch (companyName.toLowerCase()) {
      case 'samsung':
        return Color(0xFF1428A0);
      case 'apple':
        return Color(0xFF007AFF);
      case 'vivo':
        return Color(0xFF4285F4);
      case 'oppo':
        return Color(0xFF07C160);
      case 'xiaomi':
        return Color(0xFFFF6900);
      case 'realme':
        return Color(0xFFFFD60A);
      case 'oneplus':
        return Color(0xFFEB1700);
      default:
        return Color(0xFF1E293B);
    }
  }

  Color getPaymentMethodColor(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'upi':
        return Color(0xFF10B981);
      case 'cash':
        return Color(0xFF3B82F6);
      case 'card':
      case 'bank_card':
        return Color(0xFF8B5CF6);
      case 'emi':
        return Color(0xFFF59E0B);
      case 'cheque':
        return Color(0xFF06B6D4);
      case 'bank':
      case 'bank_transfer':
        return Color(0xFFEF4444);
      case 'others':
        return Color(0xFF64748B);
      default:
        return Color(0xFF6B7280);
    }
  }

  IconData getPaymentMethodIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'upi':
        return Icons.qr_code;
      case 'cash':
        return Icons.money;
      case 'card':
      case 'bank_card':
        return Icons.credit_card;
      case 'emi':
        return Icons.schedule;
      case 'cheque':
        return Icons.receipt;
      case 'bank':
      case 'bank_transfer':
        return Icons.account_balance;
      case 'others':
        return Icons.more_horiz;
      default:
        return Icons.payment;
    }
  }

  // Navigation methods
  void navigateToSaleDetails(Sale sale) {
    Get.toNamed(AppRoutes.salesDetails, arguments: sale.saleId);
  }

  void downloadInvoice(Sale sale) {
    log(sale.invoicePdfUrl ?? '');

    // Extract filename from URL or create a custom one
    String fileName = 'invoice_${sale.invoiceNumber}.pdf';

    // Download the PDF
    PDFDownloadService.downloadPDF(
      url: sale.invoicePdfUrl ?? '',
      fileName: fileName,
      customPath: 'Invoices',
      openAfterDownload: true,
      onDownloadComplete: () {
        // Optional: Additional actions after download
        print('Invoice ${sale.invoiceNumber} downloaded successfully');
      },
    );
  }

  // Download invoice from detail page using saleId
  void downloadInvoiceFromDetail(SaleDetailResponse sale) {
    log(sale.pdfUrl);

    // Extract filename from URL or create a custom one
    String fileName =
        '${AppConfig.shopName.value.isNotEmpty ? AppConfig.shopName.value : "Smart Becho"}invoice_${sale.invoiceNumber}.pdf';
    // Download the PDF
    PDFDownloadService.downloadPDF(
      url: sale.pdfUrl,
      fileName: fileName,
      customPath: 'Invoices',
      openAfterDownload: true,

      onDownloadComplete: () {
        // Optional: Additional actions after download
        print('Invoice ${sale.invoiceNumber} downloaded successfully');
      },
    );
  }

  void downloadAndPrintInvoiceFromDetail(SaleDetailResponse sale) {
    log(sale.pdfUrl);

    // Extract filename from URL or create a custom one
    String fileName = 'invoice_${sale.invoiceNumber}.pdf';

    // Download the PDF
    PDFDownloadService.downloadAndPrint(url: sale.pdfUrl, fileName: fileName);
  }

  // Share invoice link to WhatsApp
  void shareInvoiceLinkToWhatsApp(SaleDetailResponse sale) {
    String pdfUrl = sale.pdfUrl;

    PDFDownloadService.shareInvoiceLinkToWhatsApp(
      pdfUrl: pdfUrl,
      invoiceNumber: sale.invoiceNumber,
      customerName: sale.customer.displayName,
      shopName: sale.shopName,
      amount: sale.formattedTotalAmount,
      date: sale.formattedDate,
      phoneNumber: sale.customer.primaryPhone,
    );
  }

  // Share invoice link (general)
  void shareInvoiceLink(SaleDetailResponse sale) {
    String pdfUrl = sale.pdfUrl;

    PDFDownloadService.shareInvoiceLink(
      pdfUrl: pdfUrl,
      invoiceNumber: sale.invoiceNumber,
      customerName: sale.customer.displayName,
      shopName: sale.shopName,
      amount: sale.formattedTotalAmount,
      date: sale.formattedDate,
      phoneNumber: sale.customer.primaryPhone,
    );
  }

  // Getters for stats
  double get totalSales => statsData.value?.totalSaleAmount ?? 0.0;
  double get totalEmi => statsData.value?.totalEmiAmount ?? 0.0;
  double get upiAmount => statsData.value?.upiAmount ?? 0.0;
  double get cashAmount => statsData.value?.cashAmount ?? 0.0;
  double get cardAmount => statsData.value?.cardAmount ?? 0.0;
  int get totalPhonesSold => statsData.value?.totalPhonesSold ?? 0;

  String get formattedTotalSales => totalSales.toStringAsFixed(2);
  String get formattedTotalEmi => totalEmi.toStringAsFixed(2);
  String get formattedUpiAmount => upiAmount.toStringAsFixed(2);
  String get formattedCashAmount => cashAmount.toStringAsFixed(2);
  String get formattedCardAmount => cardAmount.toStringAsFixed(2);

  double get totalSaleAmount =>
      insightsStatsData.value?.payload.totalSaleAmount ?? 0.0;
  double get averageSaleAmountGrowth =>
      insightsStatsData.value?.payload.averageSaleAmountGrowth ?? 0.0;
  double get averageSaleAmount =>
      insightsStatsData.value?.payload.averageSaleAmount ?? 0.0;
  double get totalUnitsSoldGrowth =>
      insightsStatsData.value?.payload.totalUnitsSoldGrowth ?? 0.0;
  int get totalUnitsSold =>
      insightsStatsData.value?.payload.totalUnitsSold ?? 0;
  double get totalSaleAmountGrowth =>
      insightsStatsData.value?.payload.totalSaleAmountGrowth ?? 0.0;
  double get totalEmiSalesAmount =>
      insightsStatsData.value?.payload.totalEmiSalesAmount ?? 0.0;
  double get totalEmiSalesAmountGrowth =>
      insightsStatsData.value?.payload.totalEmiSalesAmountGrowth ?? 0.0;

  String get formattedTotalSaleAmount => totalSaleAmount.toStringAsFixed(2);
  String get formattedAverageSaleAmountGrowth =>
      averageSaleAmountGrowth.toStringAsFixed(2);
  String get formattedAverageSaleAmount => averageSaleAmount.toStringAsFixed(2);
  String get formattedTotalUnitsSoldGrowth =>
      totalUnitsSoldGrowth.toStringAsFixed(2);
  String get formattedTotalUnitsSold => totalUnitsSold.toStringAsFixed(0);
  String get formattedTotalSaleAmountGrowth =>
      totalSaleAmountGrowth.toStringAsFixed(2);
  String get formattedTotalEmiSalesAmount =>
      totalEmiSalesAmount.toStringAsFixed(2);
  String get formattedTotalEmiSalesAmountGrowth =>
      totalEmiSalesAmountGrowth.toStringAsFixed(2);

  @override
  void onClose() {
    searchController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }
}
