// controllers/inventory_controller.dart
import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart' as dio;

import 'package:get/get.dart';
import 'package:smartbecho/models/inventory%20management/business_summary_model.dart';
import 'package:smartbecho/models/inventory%20management/company_stock_model.dart';
import 'package:smartbecho/models/inventory%20management/low_stock_alert_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';

class InventorySalesStockController extends GetxController {
  // API service instance
  final ApiServices _apiService = ApiServices();
  // App config instance
  final AppConfig _config = AppConfig.instance;
  
  // Observable variables
  var isLoading = false.obs;
  var isLoadingCategories = false.obs;
  var lowStockAlerts = Rx<LowStockAlertModel?>(null);
  var companyStocks = <CompanyStockModel>[].obs;
  final Rx<BusinessSummaryModel?> businessSummaryCardsData = Rx<BusinessSummaryModel?>(null);

  var currentCategory = 'CHARGER'.obs;
  RxList<String> itemCategory = RxList<String>();

  // Business summary loading states
  final RxBool isbusinessSummaryCardsLoading = false.obs;
  final RxBool hasbusinessSummaryCardsError = false.obs;
  final RxString businessSummaryCardsErrorMessage = ''.obs;

  // Flags to prevent multiple simultaneous calls
  bool _isInitializing = false;
  bool _isFetchingInventoryData = false;
  bool _isFetchingBusinessSummary = false;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  // Single initialization method to prevent multiple calls
  Future<void> _initializeData() async {
    if (_isInitializing) return;
    
    try {
      _isInitializing = true;
      
      // Set initial loading states
      isLoading.value = true;
      isbusinessSummaryCardsLoading.value = true;
      
      // Fetch categories first, then other data
      await fetchItemCategories();
      
      // Fetch all data in parallel
      await Future.wait([
        fetchInventoryData(),
        fetchBusinesssummaryegories(),
      ]);
      
    } catch (e) {
      log("❌ Error during initialization: $e");
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> fetchBusinesssummaryegories() async {
    if (_isFetchingBusinessSummary) return;
    
    try {
      _isFetchingBusinessSummary = true;
      isbusinessSummaryCardsLoading.value = true;
      hasbusinessSummaryCardsError.value = false;
      businessSummaryCardsErrorMessage.value = '';

      log("🔄 Fetching business summary from API");

      dio.Response? response = await _apiService.requestGetForApi(
        url: "${_config.baseUrl}/inventory/business-summary",
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final summaryResponse = BusinessSummaryModel.fromJson(response.data);
        businessSummaryCardsData.value = summaryResponse;
        log("✅ Summary Cards loaded successfully");
      } else {
        hasbusinessSummaryCardsError.value = true;
        businessSummaryCardsErrorMessage.value =
            'Failed to fetch summary data. Status: ${response?.statusCode}';
        log("❌ Failed to fetch business summary. Status: ${response?.statusCode}");
      }
    } catch (error) {
      hasbusinessSummaryCardsError.value = true;
      businessSummaryCardsErrorMessage.value = 'Error: $error';
      log("❌ Error in fetchBusinesssummaryegories: $error");
    } finally {
      isbusinessSummaryCardsLoading.value = false;
      _isFetchingBusinessSummary = false;
    }
  }

  // Fixed getter methods for easy access to summary data
  int get totalCompaniesAvailable =>
      businessSummaryCardsData.value?.payload.totalCompanies ?? 0;
  int get totalStockAvailable =>
      businessSummaryCardsData.value?.payload.totalStockAvailable ?? 0;
  int get totalModelsAvailable =>
      businessSummaryCardsData.value?.payload.totalModelsAvailable ?? 0;
  int get monthlyPhoneSold =>
      businessSummaryCardsData.value?.payload.totalUnitsSold ?? 0;
  String get topSellingBrandAndModel =>
      businessSummaryCardsData.value?.payload.topSellingBrandAndModel ?? '';
  double get totalRevenue =>
      businessSummaryCardsData.value?.payload.totalRevenue ?? 0.0;

  Future<void> fetchItemCategories() async {
    if (isLoadingCategories.value) return; // Prevent multiple calls
    
    try {
      isLoadingCategories.value = true;
      log("🔄 Fetching item categories from API");

      dio.Response? response = await _apiService.requestGetForApi(
        url: "${_config.baseUrl}/inventory/item-types",
        authToken: true,
      );

      if (response != null) {
        if (response.statusCode == 200) {
          final data = response.data is String 
              ? json.decode(response.data) 
              : response.data;

          if (data is List) {
            itemCategory.clear();
            itemCategory.addAll(data.cast<String>());
            
            if (itemCategory.isNotEmpty) {
              if (!itemCategory.contains(currentCategory.value)) {
                currentCategory.value = itemCategory.first;
              }
            }

            log("✅ Item categories loaded successfully");
            log("Categories: ${itemCategory.join(', ')}");
            log("Current category set to: ${currentCategory.value}");
          } else {
            throw Exception('Expected List<String> but got ${data.runtimeType}');
          }
        } else {
          log("❌ Failed to fetch categories. Status: ${response.statusCode}");
          _setFallbackCategories();
        }
      } else {
        log("❌ No response received for item categories");
        _setFallbackCategories();
      }
    } catch (error) {
      log("❌ Error in fetchItemCategories: $error");
      _setFallbackCategories();
      Get.snackbar(
        'Warning', 
        'Failed to fetch categories. Using default categories.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  void _setFallbackCategories() {
    itemCategory.clear();
    itemCategory.addAll([
      'SMARTPHONE',
      'CHARGER', 
      'EARPHONES',
      'HEADPHONES',
      'BLUETOOTH_SPEAKER',
      'COVER',
      'SCREEN_GUARD',
      'USB_CABLE',
      'POWER_BANK'
    ]);
    currentCategory.value = 'SMARTPHONE';
    log("📦 Using fallback categories");
  }

  Future<void> fetchInventoryData() async {
    if (_isFetchingInventoryData) return; // Prevent multiple calls
    
    try {
      _isFetchingInventoryData = true;
      if (!isLoading.value) isLoading.value = true;
      
      // Fetch inventory data in parallel
      await Future.wait([
        fetchLowStockAlerts(),
        fetchCompanyStocksByCategory(currentCategory.value),
      ]);

    } catch (e) {
      log("❌ Error in fetchInventoryData: $e");
      Get.snackbar('Error', 'Failed to fetch inventory data');
    } finally {
      isLoading.value = false;
      _isFetchingInventoryData = false;
    }
  }

  Future<void> fetchLowStockAlerts() async {
    try {
      log("🔄 Fetching low stock alerts");
      
      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.getLowStockAlerts,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data is String
            ? json.decode(response.data)
            : response.data;

        lowStockAlerts.value = LowStockAlertModel.fromJson(data);
        
        log("✅ Low Stock Alerts loaded successfully");
        log("Critical items: ${lowStockAlerts.value?.payload.critical.length ?? 0}");
        log("Low stock items: ${lowStockAlerts.value?.payload.low.length ?? 0}");
        log("Out of stock items: ${lowStockAlerts.value?.payload.outOfStock.length ?? 0}");
      } else {
        log("❌ Failed to fetch low stock alerts. Status: ${response?.statusCode}");
      }
    } catch (error) {
      log("❌ Error in fetchLowStockAlerts: $error");
    }
  }

  Future<void> fetchCompanyStocksByCategory(String itemCategory) async {
    try {
      currentCategory.value = itemCategory;

      log("🔄 Fetching company stocks for category: $itemCategory");

      dio.Response? response = await _apiService.requestGetForApi(
        url: "${_config.getCompanyStocks}?itemCategory=$itemCategory",
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data = response.data is String
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

        companyStocks.value = stockList
            .map((json) => CompanyStockModel.fromJson(json))
            .toList();

        log("✅ Company Stocks loaded successfully for $itemCategory");
        log("Total companies: ${companyStocks.length}");
        log("Companies: ${companyStocks.map((e) => e.company).join(', ')}");

      } else {
        log("❌ Failed to fetch company stocks. Status: ${response!.statusCode}");
        Get.snackbar(
          'Error',
          'Failed to fetch company stocks for $itemCategory',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (error) {
      log("❌ Error in fetchCompanyStocksByCategory: $error");
      Get.snackbar(
        'Error',
        'Failed to fetch company stocks: ${error.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Legacy method for backward compatibility
  Future<void> fetchCompanyStocks() async {
    await fetchCompanyStocksByCategory(currentCategory.value);
  }

  // Method to change category and refresh data
  Future<void> changeCategoryAndRefresh(String newCategory) async {
    if (newCategory != currentCategory.value && !_isFetchingInventoryData) {
      await fetchCompanyStocksByCategory(newCategory);
    }
  }

  // Method to refresh categories from API
  Future<void> refreshCategories() async {
    if (!isLoadingCategories.value) {
      await fetchItemCategories();
    }
  }

  // Helper methods
  int get totalCriticalAlerts =>
      lowStockAlerts.value?.payload.critical.length ?? 0;
  int get totalLowStockAlerts => lowStockAlerts.value?.payload.low.length ?? 0;
  int get totalOutOfStockAlerts =>
      lowStockAlerts.value?.payload.outOfStock.length ?? 0;
  int get totalAlerts =>
      totalCriticalAlerts + totalLowStockAlerts + totalOutOfStockAlerts;

  // Get companies with low stock for current category
  List<CompanyStockModel> get lowStockCompanies =>
      companyStocks.where((company) => company.lowStockModels > 0).toList();

  // Get companies with good stock for current category
  List<CompanyStockModel> get goodStockCompanies =>
      companyStocks
          .where((company) => company.lowStockModels == 0 && company.totalStock > 50)
          .toList();

  // Get companies with high stock for current category
  List<CompanyStockModel> get highStockCompanies =>
      companyStocks.where((company) => company.totalStock > 100).toList();

  // Public method for pull-to-refresh
  Future<void> refreshData() async {
    log("🔄 Refreshing all data");
    
    // Reset flags to allow refresh
    _isInitializing = false;
    _isFetchingInventoryData = false;
    _isFetchingBusinessSummary = false;
    
    // Fetch fresh data
    await _initializeData();
  }

  // Method to refresh data for current category only
  Future<void> refreshCurrentCategory() async {
    if (!_isFetchingInventoryData) {
      await fetchCompanyStocksByCategory(currentCategory.value);
    }
  }
}