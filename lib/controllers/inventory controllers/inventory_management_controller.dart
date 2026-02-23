import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/controllers/auth%20controllers/auth_controller.dart';
import 'package:smartbecho/models/inventory%20management/filter_response_model.dart';
import 'package:smartbecho/models/inventory%20management/inventory_item_model.dart';
import 'package:smartbecho/models/inventory%20management/inventory_summary_model.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/secure_storage_service.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:smartbecho/views/inventory/components/return_item_form.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/utils/Dialogs/app_deletedialog.dart';
import 'package:smartbecho/utils/Dialogs/app_successdialog.dart';

class InventoryController extends GetxController {
  // PlutoGrid Manager
  PlutoGridStateManager? stateManager;
  // API service instance
  final ApiServices _apiService = ApiServices();
  // App config instance
  final AppConfig _config = AppConfig.instance;

  // Observable variables for API data
  final RxList<InventoryItem> inventoryItems = <InventoryItem>[].obs;
  final RxList<InventoryItem> allFetchedItems = <InventoryItem>[].obs;

  // Search and filtering (API-based)
  final TextEditingController searchTextController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedCompany = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxString selectedModel = ''.obs;
  final RxString selectedStockAvailability = ''.obs;
  final RxString selectedRAM = ''.obs;
  final RxString selectedROM = ''.obs;
  final RxString selectedColor = ''.obs;
  final RxBool isFiltersExpanded = false.obs;

  // Sorting
  final RxString sortBy = 'id'.obs;
  final RxString sortDirection = 'asc'.obs;

  // Lazy loading variables
  final RxInt itemsPerPage = 20.obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalItems = 0.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  late ScrollController scrollController;
  final RxBool showScrollToTop = false.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isInventoryDataLoading = false.obs;
  final RxString inventoryDataerrorMessage = ''.obs;
  final RxBool hasInventoryDataError = false.obs;

  // Filter loading states
  final RxBool isFiltersLoading = false.obs;
  final RxBool hasFiltersError = false.obs;
  final RxString filtersErrorMessage = ''.obs;

  // Cascading filter loading states
  final RxBool isModelsLoading = false.obs;
  final RxBool isSpecsLoading = false.obs; // For RAM, ROM, Color loading

  // Search debounce timer
  Worker? _searchDebouncer;

  // Base filter options from initial API call (all available options)
  final RxList<String> allCompanies = <String>[].obs;
  final RxList<String> allCategories = <String>[].obs;
  final RxList<String> allModels = <String>[].obs;
  final RxList<String> allRAMs = <String>[].obs;
  final RxList<String> allROMs = <String>[].obs;
  final RxList<String> allColors = <String>[].obs;

  // Dynamic filter options based on selection (filtered from all data)
  final RxList<String> availableCompanies = <String>[].obs;
  final RxList<String> availableCategories = <String>[].obs;
  final RxList<String> availableModels = <String>[].obs;
  final RxList<String> availableRAMs = <String>[].obs;
  final RxList<String> availableROMs = <String>[].obs;
  final RxList<String> availableColors = <String>[].obs;

  // Store all inventory data for local filtering
  final RxList<InventoryItem> allInventoryData = <InventoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    getGstNum();
    // Initialize scroll controller for lazy loading
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    scrollController.addListener(_onScrollPositionChanged);

    // Set up search debouncer for API calls
    _searchDebouncer = debounce(
      searchQuery,
      (String query) => _onSearchChanged(query),
      time: const Duration(milliseconds: 800),
    );

    // Set up listeners for filters - these will trigger cascading logic
    ever(selectedCompany, (_) => _onCompanyChanged());
    ever(selectedCategory, (_) => _onCategoryChanged());
    ever(selectedModel, (_) => _onModelChanged());
    ever(selectedStockAvailability, (_) => _onFilterChanged());
    ever(selectedRAM, (_) => _onFilterChanged());
    ever(selectedROM, (_) => _onFilterChanged());
    ever(selectedColor, (_) => _onFilterChanged());

    // Initial data fetch
    loadInitialData();
  }

  void _onScrollPositionChanged() {
    // Show button when scrolled down more than 200 pixels
    if (scrollController.hasClients) {
      showScrollToTop.value = scrollController.offset > 200;
    }
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<String> get gstNumber => getGstNum();
  Future<String> getGstNum() async {
    String gstNumber =
        await SharedPreferencesHelper.getGstNumber() ??
        "No GST Number Available";

    return gstNumber;
  }

  @override
  void onClose() {
    scrollController.dispose();
    _searchDebouncer?.dispose();
    super.onClose();
  }

  /// Load initial data - filters and inventory
  Future<void> loadInitialData() async {
    await fetchFiltersData();
    await fetchInventoryData(isInitial: true);
    await getSummaryCards();
  }

  /// Fetch filter options from API (all available options)
  Future<void> fetchFiltersData() async {
    try {
      isFiltersLoading.value = true;
      hasFiltersError.value = false;
      filtersErrorMessage.value = '';

      final jsessionId = await SecureStorageHelper.getJSessionId();

      if (jsessionId == null || jsessionId.isEmpty) {
        hasFiltersError.value = true;
        filtersErrorMessage.value = 'No session found. Please login again.';
        return;
      }

      dio.Response? response = await _apiService.requestGetWithJSessionId(
        url: _config.getInventoryFilters,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data =
            response.data is String
                ? json.decode(response.data)
                : response.data;
        final filterResponse = FilterResponse.fromJson(data);

        // Store all filter options
        allCompanies.assignAll(filterResponse.companies);
        allCategories.assignAll(filterResponse.itemCategories);
        allModels.assignAll(filterResponse.models);
        allRAMs.assignAll(filterResponse.rams);
        allROMs.assignAll(filterResponse.roms);
        allColors.assignAll(filterResponse.colors);

        // Initialize available options properly
        _initializeCascadingFilters();

        log("✅ Filters loaded successfully");
        log("Companies: ${allCompanies.length}");
        log("Categories: ${allCategories.length}");
        log("Models: ${allModels.length}");
        log("RAMs: ${allRAMs.length}");
        log("ROMs: ${allROMs.length}");
        log("Colors: ${allColors.length}");
      } else if (response?.statusCode == 401 || response?.statusCode == 403) {
        hasFiltersError.value = true;
        filtersErrorMessage.value = 'Session expired. Please login again.';
        await _handleSessionExpired();
      } else {
        hasFiltersError.value = true;
        filtersErrorMessage.value =
            'Failed to fetch filters. Status: ${response?.statusCode}';
      }
    } catch (error) {
      hasFiltersError.value = true;
      filtersErrorMessage.value = 'Error: $error';
      log("❌ Error in fetchFiltersData: $error");
    } finally {
      isFiltersLoading.value = false;
    }
  }

  void _initializeCascadingFilters() {
    // Show all companies and categories initially
    availableCompanies.assignAll(allCompanies);
    availableCategories.assignAll(allCategories);

    // Hide dependent filters until parent is selected
    availableModels.clear();
    availableRAMs.clear();
    availableROMs.clear();
    availableColors.clear();

    log("🔗 Initialized cascading filters");
    log("Available companies: ${availableCompanies.length}");
    log("Available categories: ${availableCategories.length}");
  }

  /// Fetch all inventory data for local cascading filter logic
  Future<void> fetchAllInventoryData() async {
    try {
      final jsessionId = await SecureStorageHelper.getJSessionId();

      if (jsessionId == null || jsessionId.isEmpty) {
        return;
      }

      // Fetch all data with a large page size for filtering
      String apiUrl = '${_config.baseUrl}/inventory/shop?page=0&size=20';
      log("🔄 Fetching all inventory data for filtering: $apiUrl");

      dio.Response? response = await _apiService.requestGetWithJSessionId(
        url: apiUrl,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data =
            response.data is String
                ? json.decode(response.data)
                : response.data;
        final payload = data['payload'];
        final pageData = payload['page'];
        final List<dynamic> jsonList = pageData['content'];

        List<InventoryItem> allItems =
            jsonList.map((item) => InventoryItem.fromJson(item)).toList();
        allInventoryData.assignAll(allItems);

        log("✅ Loaded ${allInventoryData.length} items for filtering");
      }
    } catch (error) {
      log("❌ Error fetching all inventory data: $error");
    }
  }

  /// Update cascading filters based on current selection
  void _updateCascadingFilters() async {
    log("🔗 Updating cascading filters...");
    log("Selected Company: '${selectedCompany.value}'");
    log("Selected Category: '${selectedCategory.value}'");
    log("Selected Model: '${selectedModel.value}'");

    // Update models based on company/category selection
    await _updateAvailableModels();

    // Update specs based on model selection
    await _updateAvailableSpecs();
  }

  Future<void> _updateAvailableModels() async {
    if (selectedCompany.value.isEmpty && selectedCategory.value.isEmpty) {
      availableModels.clear();
      log("🔄 No company/category selected, clearing models");
      return;
    }

    try {
      // Build query parameters for filtered models
      Map<String, String> params = {};
      if (selectedCompany.value.isNotEmpty) {
        params['company'] = selectedCompany.value;
      }
      if (selectedCategory.value.isNotEmpty) {
        params['itemType'] = selectedCategory.value;
      }

      String queryString = params.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');

      // Use your existing filter API with parameters
      String apiUrl = '${_config.getInventoryFilters}?$queryString';
      log("🔄 Fetching filtered models: $apiUrl");

      final jsessionId = await SecureStorageHelper.getJSessionId();
      if (jsessionId == null || jsessionId.isEmpty) return;

      dio.Response? response = await _apiService.requestGetWithJSessionId(
        url: apiUrl,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data =
            response.data is String
                ? json.decode(response.data)
                : response.data;
        final filterResponse = FilterResponse.fromJson(data);

        // Update available models from filtered response
        availableModels.assignAll(filterResponse.models);
        log("✅ Updated models: ${availableModels.length} available");
      } else {
        log("❌ Failed to fetch filtered models: ${response?.statusCode}");
        // Fallback: use all models (not ideal but prevents empty dropdown)
        availableModels.assignAll(allModels);
      }
    } catch (error) {
      log("❌ Error fetching filtered models: $error");
      // Fallback: use all models
      availableModels.assignAll(allModels);
    }
  }

  /// Update available specs using API call with current filters
  Future<void> _updateAvailableSpecs() async {
    if (selectedModel.value.isEmpty) {
      availableRAMs.clear();
      availableROMs.clear();
      availableColors.clear();
      log("🔄 No model selected, clearing specs");
      return;
    }

    try {
      // Build query parameters for filtered specs
      Map<String, String> params = {'model': selectedModel.value};

      if (selectedCompany.value.isNotEmpty) {
        params['company'] = selectedCompany.value;
      }
      if (selectedCategory.value.isNotEmpty) {
        params['itemType'] = selectedCategory.value;
      }

      String queryString = params.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');

      // Use your existing filter API with parameters
      String apiUrl = '${_config.getInventoryFilters}?$queryString';
      log("🔄 Fetching filtered specs: $apiUrl");

      final jsessionId = await SecureStorageHelper.getJSessionId();
      if (jsessionId == null || jsessionId.isEmpty) return;

      dio.Response? response = await _apiService.requestGetWithJSessionId(
        url: apiUrl,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data =
            response.data is String
                ? json.decode(response.data)
                : response.data;
        final filterResponse = FilterResponse.fromJson(data);

        // Update available specs from filtered response
        List<String> rams = filterResponse.rams;
        List<String> roms = filterResponse.roms;
        List<String> colors = filterResponse.colors;

        // Sort RAMs and ROMs properly
        rams.sort((a, b) {
          try {
            int aVal = int.parse(a.replaceAll(RegExp(r'[^0-9]'), ''));
            int bVal = int.parse(b.replaceAll(RegExp(r'[^0-9]'), ''));
            return aVal.compareTo(bVal);
          } catch (e) {
            return a.compareTo(b);
          }
        });

        roms.sort((a, b) {
          try {
            int aVal = int.parse(a.replaceAll(RegExp(r'[^0-9]'), ''));
            int bVal = int.parse(b.replaceAll(RegExp(r'[^0-9]'), ''));
            return aVal.compareTo(bVal);
          } catch (e) {
            return a.compareTo(b);
          }
        });

        colors.sort();

        availableRAMs.assignAll(rams);
        availableROMs.assignAll(roms);
        availableColors.assignAll(colors);

        log(
          "✅ Updated specs - RAMs: ${rams.length}, ROMs: ${roms.length}, Colors: ${colors.length}",
        );
      } else {
        log("❌ Failed to fetch filtered specs: ${response?.statusCode}");
        // Fallback: use all specs
        availableRAMs.assignAll(allRAMs);
        availableROMs.assignAll(allROMs);
        availableColors.assignAll(allColors);
      }
    } catch (error) {
      log("❌ Error fetching filtered specs: $error");
      // Fallback: use all specs
      availableRAMs.assignAll(allRAMs);
      availableROMs.assignAll(allROMs);
      availableColors.assignAll(allColors);
    }
  }

  /// Handle scroll for lazy loading
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 100) {
      if (!isLoadingMore.value &&
          hasMoreData.value &&
          searchQuery.value.trim().isEmpty &&
          !isInventoryDataLoading.value) {
        log("🔄 Loading more data - Current page: ${currentPage.value}");
        loadMoreData();
      }
    }
  }

  /// Handle search query changes
  void _onSearchChanged(String query) {
    log("🔍 Search changed: '$query'");
    _resetPagination();
    _searchByCompany(query);
  }

  /// Handle company selection change
  void _onCompanyChanged() async {
    log("🏢 Company changed: '${selectedCompany.value}'");

    // Reset dependent filters when company changes
    selectedModel.value = '';
    selectedRAM.value = '';
    selectedROM.value = '';
    selectedColor.value = '';

    // Clear dependent filter options immediately
    availableModels.clear();
    availableRAMs.clear();
    availableROMs.clear();
    availableColors.clear();

    // Show loading for models
    isModelsLoading.value = true;

    // Update cascading filters
    _updateCascadingFilters();

    isModelsLoading.value = false;

    // Fetch filtered inventory data
    _onFilterChanged();
  }

  /// Handle category selection change
  void _onCategoryChanged() async {
    log("📂 Category changed: '${selectedCategory.value}'");

    // Reset dependent filters when category changes
    selectedModel.value = '';
    selectedRAM.value = '';
    selectedROM.value = '';
    selectedColor.value = '';

    // Clear dependent filter options immediately
    availableModels.clear();
    availableRAMs.clear();
    availableROMs.clear();
    availableColors.clear();

    // Show loading for models if company is also selected
    if (selectedCompany.value.isNotEmpty || selectedCategory.value.isNotEmpty) {
      isModelsLoading.value = true;
      _updateCascadingFilters();
      isModelsLoading.value = false;
    }

    _onFilterChanged();
  }

  /// Handle model selection change
  void _onModelChanged() async {
    log("📱 Model changed: '${selectedModel.value}'");

    // Reset dependent filters when model changes
    selectedRAM.value = '';
    selectedROM.value = '';
    selectedColor.value = '';

    // Clear dependent filter options immediately
    availableRAMs.clear();
    availableROMs.clear();
    availableColors.clear();

    // Show loading for specs
    isSpecsLoading.value = true;

    // Update cascading filters
    _updateCascadingFilters();

    isSpecsLoading.value = false;

    // Fetch filtered inventory data
    _onFilterChanged();
  }

  /// Handle any filter change - fetch filtered data
  void _onFilterChanged() {
    log("🔄 Filter changed, fetching data...");
    _resetPagination();
    fetchInventoryData(isInitial: true);
  }

  /// Build query parameters for API call
  Map<String, String> _buildQueryParams() {
    Map<String, String> params = {
      'page': currentPage.value.toString(),
      'size': itemsPerPage.value.toString(),
      'sort': sortBy.value,
      "sortDir": sortDirection.value,
    };

    // Add filters only if they have values
    if (searchQuery.value.trim().isNotEmpty) {
      params['search'] = searchQuery.value.trim();
    }

    if (selectedCategory.value.isNotEmpty) {
      params['itemType'] = selectedCategory.value;
    }

    if (selectedCompany.value.isNotEmpty) {
      params['company'] = selectedCompany.value;
    }

    if (selectedModel.value.isNotEmpty) {
      params['model'] = selectedModel.value;
    }

    if (selectedRAM.value.isNotEmpty) {
      params['ram'] = selectedRAM.value;
    }

    if (selectedROM.value.isNotEmpty) {
      params['rom'] = selectedROM.value;
    }

    if (selectedColor.value.isNotEmpty) {
      params['color'] = selectedColor.value;
    }

    return params;
  }

  /// Modified fetch inventory data with filters
  Future<void> fetchInventoryData({
    bool isInitial = false,
    bool isLoadMore = false,
  }) async {
    try {
      if (isInitial) {
        isInventoryDataLoading.value = true;
        _resetPagination();
        log("📱 Initial data fetch with filters");
      } else if (isLoadMore) {
        isLoadingMore.value = true;
        log("📱 Load more data - Page: ${currentPage.value}");
      }

      hasInventoryDataError.value = false;
      inventoryDataerrorMessage.value = '';

      final jsessionId = await SecureStorageHelper.getJSessionId();

      if (jsessionId == null || jsessionId.isEmpty) {
        hasInventoryDataError.value = true;
        inventoryDataerrorMessage.value =
            'No session found. Please login again.';
        return;
      }

      // Build query parameters
      Map<String, String> queryParams = _buildQueryParams();

      // Construct URL with query parameters
      String apiUrl = '${_config.baseUrl}/inventory/shop';
      String queryString = queryParams.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');

      if (queryString.isNotEmpty) {
        apiUrl += '?$queryString';
      }

      log("🌐 API URL: $apiUrl");

      dio.Response? response = await _apiService.requestGetWithJSessionId(
        url: apiUrl,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data =
            response.data is String
                ? json.decode(response.data)
                : response.data;
        final payload = data['payload'];

        final pageData = payload['page'];
        final List<dynamic> jsonList = pageData['content'];

        totalItems.value = pageData['totalElements'] ?? 0;
        int totalPages = pageData['totalPages'] ?? 0;
        bool isLastPage = pageData['last'] ?? true;

        hasMoreData.value =
            !isLastPage && (pageData['number'] + 1) < totalPages;

        List<InventoryItem> fetchedItems =
            jsonList.map((item) => InventoryItem.fromJson(item)).toList();

        if (isInitial) {
          allFetchedItems.assignAll(fetchedItems);
          inventoryItems.assignAll(fetchedItems);
          log("✅ Initial load: ${allFetchedItems.length} items");
        } else if (isLoadMore) {
          allFetchedItems.addAll(fetchedItems);
          inventoryItems.addAll(fetchedItems);
          log(
            "✅ Added ${fetchedItems.length} more items. Total: ${allFetchedItems.length}",
          );
        }

        log("🔄 Has more data: ${hasMoreData.value}");
      } else if (response?.statusCode == 401 || response?.statusCode == 403) {
        hasInventoryDataError.value = true;
        inventoryDataerrorMessage.value =
            'Session expired. Please login again.';
        await _handleSessionExpired();
      } else {
        hasInventoryDataError.value = true;
        inventoryDataerrorMessage.value =
            'Failed to fetch data. Status: ${response?.statusCode}';
      }
    } catch (error) {
      hasInventoryDataError.value = true;
      inventoryDataerrorMessage.value = 'Error: $error';
      log("❌ Error in fetchInventoryData: $error");
    } finally {
      isInventoryDataLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  /// Search by company using filter API
  Future<void> _searchByCompany(String company) async {
    try {
      isInventoryDataLoading.value = true;
      hasInventoryDataError.value = false;
      inventoryDataerrorMessage.value = '';

      final jsessionId = await SecureStorageHelper.getJSessionId();
      log("jsessionId: $jsessionId");

      if (jsessionId == null || jsessionId.isEmpty) {
        hasInventoryDataError.value = true;
        inventoryDataerrorMessage.value =
            'No session found. Please login again.';
        return;
      }

      // Use filter API for company search
      String apiUrl =
          '${_config.baseUrl}/inventory/shop?sort=id&sortDir=asc&keyword=${company.toLowerCase()}';
      log("Searching company from URL: $apiUrl");

      dio.Response? response = await _apiService.requestGetWithJSessionId(
        url: apiUrl,
        authToken: true,
      );

      if (response != null) {
        if (response.statusCode == 200) {
          final data =
              response.data is String
                  ? json.decode(response.data)
                  : response.data;
          final inventoryResponse = data["payload"]['page']['content'];
          List<InventoryItem> fetchedItems =
              inventoryResponse.map<InventoryItem>((val) {
                return InventoryItem.fromJson(val);
              }).toList();

          inventoryItems.addAll(fetchedItems);
          totalItems.value = fetchedItems.length;
          hasMoreData.value = false;

          log("Search results loaded: ${allFetchedItems.length}");
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          hasInventoryDataError.value = true;
          inventoryDataerrorMessage.value =
              'Session expired. Please login again.';
          await _handleSessionExpired();
        } else {
          hasInventoryDataError.value = true;
          inventoryDataerrorMessage.value =
              'Failed to search. Status: ${response.statusCode}';
        }
      } else {
        hasInventoryDataError.value = true;
        inventoryDataerrorMessage.value = 'Network error. Please try again.';
      }
    } catch (error) {
      hasInventoryDataError.value = true;
      inventoryDataerrorMessage.value = 'Error: $error';
      log("❌ Error in _searchByCompany: $error");
    } finally {
      isInventoryDataLoading.value = false;
    }
  }

  /// Load more data for lazy loading
  Future<void> loadMoreData() async {
    if (isLoadingMore.value || !hasMoreData.value) {
      return;
    }

    currentPage.value++;
    await fetchInventoryData(isLoadMore: true);
  }

  /// Reset pagination variables
  void _resetPagination() {
    currentPage.value = 0;
    hasMoreData.value = true;
    allFetchedItems.clear();
    inventoryItems.clear();
  }

  void onCompanyFilterChanged(String company) {
    selectedCompany.value = company;
  }

  void onCategoryFilterChanged(String category) {
    selectedCategory.value = category;
  }

  void onModelFilterChanged(String model) {
    selectedModel.value = model;
  }

  void onStockFilterChanged(String stock) {
    selectedStockAvailability.value = stock;
  }

  void onRAMFilterChanged(String ram) {
    selectedRAM.value = ram;
  }

  void onROMFilterChanged(String rom) {
    selectedROM.value = rom;
  }

  void onColorFilterChanged(String color) {
    selectedColor.value = color;
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCompany.value = '';
    selectedCategory.value = '';
    selectedModel.value = '';
    selectedStockAvailability.value = '';
    selectedRAM.value = '';
    selectedROM.value = '';
    selectedColor.value = '';
    sortBy.value = 'id';
    sortDirection.value = 'asc';

    _initializeCascadingFilters();

    // refreshData();
    refreshForSearchData();
  }

  void applyFilters() {
    _resetPagination();
    fetchInventoryData(isInitial: true);
  }

  // Refresh data method
  Future<void> refreshData() async {
    await fetchFiltersData();
    _resetPagination();
    await fetchInventoryData(isInitial: true);
    getSummaryCards();
  }

   Future<void> refreshForSearchData() async {
    await fetchFiltersData();
    _resetPagination();
    await fetchInventoryData(isInitial: true);
  }

  // Helper method to get active filters count
  int getActiveFiltersCount() {
    int count = 0;
    if (searchQuery.value.isNotEmpty) count++;
    if (selectedCompany.value.isNotEmpty) count++;
    if (selectedCategory.value.isNotEmpty) count++;
    if (selectedModel.value.isNotEmpty) count++;
    if (selectedStockAvailability.value.isNotEmpty) count++;
    if (selectedRAM.value.isNotEmpty) count++;
    if (selectedROM.value.isNotEmpty) count++;
    if (selectedColor.value.isNotEmpty) count++;
    return count;
  }

  // Check if a filter dropdown should be enabled
  bool isFilterEnabled(String filterType) {
    switch (filterType) {
      case 'company':
      case 'category':
        return true;
      case 'model':
        return selectedCompany.value.isNotEmpty ||
            selectedCategory.value.isNotEmpty;
      case 'ram':
      case 'rom':
      case 'color':
        return selectedModel.value.isNotEmpty;
      case 'stock':
        return true;
      default:
        return true;
    }
  }

  // Check if a filter is loading
  bool isFilterLoading(String filterType) {
    switch (filterType) {
      case 'model':
        return isModelsLoading.value;
      case 'ram':
      case 'rom':
      case 'color':
        return isSpecsLoading.value;
      default:
        return false;
    }
  }

  void addNewItem() {
    Get.toNamed(AppRoutes.addNewItem);
  }

  void addNewStocks() async {
    final bool isGtsAvailable =
        await SharedPreferencesHelper.getGstNumber() != null;
    Get.toNamed(
      AppRoutes.addNewStock,
      arguments: {"hasGstNumber": isGtsAvailable},
    );
  }

  void exportData() {
    Get.snackbar('Export', 'Exporting ${inventoryItems.length} items...');
  }

  void sellItem(InventoryItem item) {
    Get.toNamed(
      AppRoutes.mobileSalesForm,
      arguments: {'fromInventory': true, 'inventoryItem': item},
    );
  }

  void returnItem(InventoryItem item) {
    log("✅ returnItem: ${item.imeiList.toString()}");
    Get.bottomSheet(
      ReturnItemForm(item: item),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  // Return submission state
  final RxBool isSubmittingReturn = false.obs;
  Future<void> submitProductReturn({
    required InventoryItem item,
    required String distributor,
    required DateTime returnDate,
    required double returnPrice,
    required String returnQuantity,
    required String source,
    required String reason,
    required String notes,
    required String imei,
    File? file,
  }) async {
    try {
      isSubmittingReturn.value = true;

      // Format return date as YYYY-MM-DD
      final returnDateStr = DateFormat('yyyy-MM-dd').format(returnDate);

      // Format RAM/ROM based on source type
      String formatRamRom(String value, String source) {
        String numbers = value.trim().replaceAll(RegExp(r'[^0-9]'), '');

        // ONLINE products: keep lowercase "gb" suffix
        // OFFLINE products: numbers only
        if (source.toUpperCase() == 'ONLINE') {
          return '${numbers}gb';
        } else {
          return numbers;
        }
      }

      bool hasRamRom =
          item.itemCategory.toUpperCase() == 'SMARTPHONE' ||
          item.itemCategory.toUpperCase() == 'TABLET';
      // Build item data with ALL fields
      Map<String, dynamic> itemData = {
        "itemCategory": item.itemCategory,
        "model": item.model.trim(),
        "ram": hasRamRom ? formatRamRom(item.ram, source) : null,
        "rom": hasRamRom ? formatRamRom(item.rom, source) : null,
        "color": item.color.trim(),
        "company": item.company.trim(),
        "imei": imei.isEmpty ? "" : imei,
        "source": source.toUpperCase(),
        "quantity": returnQuantity,
        "returnPrice": returnPrice,
        "reason": reason,
        "notes": notes,
        "id": item.id.toString(),
      };

      // Build request JSON
      final requestData = {
        "distributor": distributor,
        "returnDate": returnDateStr,
        "items": [itemData],
      };

      log("📤 Submitting return request: ${json.encode(requestData)}");
      log("🔍 Source: $source");
      log("🔍 RAM format: ${formatRamRom(item.ram, source)}");
      log("🔍 ROM format: ${formatRamRom(item.rom, source)}");

      // Create FormData
      dio.FormData formData = dio.FormData.fromMap({
        "request": json.encode(requestData),
      });

      // Add file if selected
      if (file != null) {
        String fileName = file.path.split('/').last;
        formData.files.add(
          MapEntry(
            "file",
            await dio.MultipartFile.fromFile(file.path, filename: fileName),
          ),
        );
        log("📎 Attaching file: $fileName");
      }

      // Make API call using api service method
      dio.Response? response = await _apiService.requestMultipartApi(
        url: _config.createProductReturn,
        formData: formData,
        authToken: true,
      );

      if (response == null) {
        Get.snackbar(
          'Error',
          'Network error. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (response.statusCode == 201) {
        final data =
            response.data is String
                ? json.decode(response.data)
                : response.data;

        log("✅ Return submitted successfully: $data");

        // Close the bottom sheet
        Get.back();

        // Show success dialog
        appSuccessDialog(
          title: 'Return Submitted Successfully',
          description: 'Product return has been submitted successfully.',
          onPressed: () {
            Get.back();
            // Refresh inventory data
            refreshData();
          },
        );
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        Get.snackbar(
          'Error',
          'Session expired. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        await _handleSessionExpired();
      } else {
        final errorMessage =
            response.data is Map
                ? response.data['message'] ?? 'Failed to submit return'
                : 'Failed to submit return. Status: ${response.statusCode}';

        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        log(
          "❌ Return submission failed: ${response.statusCode} - ${response.data}",
        );
      }
    } catch (error) {
      log("❌ Error submitting return: $error");
      Get.snackbar(
        'Error',
        'Failed to submit return: ${error.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isSubmittingReturn.value = false;
    }
  }

  void deleteItem({required String itemId, int? index}) {
    appDeleteDialog(
      isLoading: deleting.value,
      title: 'Delete Item',
      description: 'Are you sure you want to delete this item?',
      // textConfirm: 'Delete',
      // textCancel: 'Cancel',
      // confirmTextColor: Colors.white,
      // buttonColor: Colors.red,
      onPressed: () {
        // allFetchedItems.removeWhere((item) => item.id.toString() == itemId);
        // inventoryItems.removeWhere((item) => item.id.toString() == itemId);
        deleteItemID(id: itemId);
        deleting.value ? Get.back() : null;

        // appSuccessDialog(
        //   title: ' Item Deleted Successfully',
        //   description: 'item deleted successfully',

        //   onPressed: () {
        //     Get.back();
        //   },
        // );
      },
    );
  }

  RxBool deleting = false.obs;
  Future<void> deleteItemID({required String id}) async {
    try {
      deleting.value = true;

      dio.Response? response = await _apiService.requestDeleteForApi(
        url: '${_config.getProductDelete}$id',
        authToken: true,
        dictParameter: {},
      );

      if (response != null && response.statusCode == 200) {
        appSuccessDialog(
          title: ' Item Deleted Successfully',
          description: 'item deleted successfully',

          onPressed: () {
            Get.back();
          },
        );
        log(" items deleted successfully");
        refreshData();
      }
    } catch (error) {
      log("❌ Error in items deleted: $error");
    } finally {
      deleting.value = false;
    }
  }

  List<InventoryItem> get filteredItems => inventoryItems;
  int get totalItems_legacy => totalItems.value;

  List<InventoryItem> getPaginatedItems() {
    return inventoryItems;
  }

  void addNewStock() {
    addNewItem();
  }

  void bulkUpload() {
    Get.snackbar('Bulk Upload', 'Bulk upload functionality coming soon!');
  }

  Future<void> onRetry() async {
    await retryFetchInventoryData();
  }

  // Summary cards methods...
  final RxBool isSummaryCardsLoading = false.obs;
  final RxBool hasSummaryCardsError = false.obs;
  final RxString summaryCardsErrorMessage = ''.obs;
  final Rx<SummaryCardsModel?> summaryCardsData = Rx<SummaryCardsModel?>(null);

  Future<void> getSummaryCards() async {
    try {
      isSummaryCardsLoading.value = true;
      hasSummaryCardsError.value = false;
      summaryCardsErrorMessage.value = '';

      final jsessionId = await SecureStorageHelper.getJSessionId();

      if (jsessionId == null || jsessionId.isEmpty) {
        hasSummaryCardsError.value = true;
        summaryCardsErrorMessage.value =
            'No session found. Please login again.';
        return;
      }

      dio.Response? response = await _apiService.requestGetWithJSessionId(
        url: _config.getInventorySummaryCards,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final data =
            response.data is String
                ? json.decode(response.data)
                : response.data;
        final summaryResponse = SummaryCardsResponse.fromJson(data);
        summaryCardsData.value = summaryResponse.payload;
        log("Summary Cards loaded successfully");
      } else if (response?.statusCode == 401 || response?.statusCode == 403) {
        hasSummaryCardsError.value = true;
        summaryCardsErrorMessage.value = 'Session expired. Please login again.';
        await _handleSessionExpired();
      } else {
        hasSummaryCardsError.value = true;
        summaryCardsErrorMessage.value =
            'Failed to fetch summary data. Status: ${response?.statusCode}';
      }
    } catch (error) {
      hasSummaryCardsError.value = true;
      summaryCardsErrorMessage.value = 'Error: $error';
      log("❌ Error in getSummaryCards: $error");
    } finally {
      isSummaryCardsLoading.value = false;
    }
  }

  // Fixed getter methods for easy access to summary data
  int get totalCompaniesAvailable =>
      summaryCardsData.value?.totalCompanies ?? 0;
  int get totalStockAvailable => summaryCardsData.value?.totalStock ?? 0;
  int get lowStockAlert => summaryCardsData.value?.lowStockCount ?? 0;
  int get monthlyPhoneSold => summaryCardsData.value?.thisMonthPhonesSold ?? 0;

  // Session handling
  Future<void> _handleSessionExpired() async {
    await SecureStorageHelper.deleteJSessionId();
    AuthController().logout();
  }

  Future<void> retryFetchInventoryData() async {
    if (await _apiService.isSessionValid()) {
      await fetchInventoryData(isInitial: true);
    } else {
      hasInventoryDataError.value = true;
      inventoryDataerrorMessage.value = 'Please login again to continue.';
    }
  }
}
