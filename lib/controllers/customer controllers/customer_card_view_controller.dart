import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:smartbecho/models/customer%20management/customer_data_model.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/launch_phone_dailer_service.dart';

class CustomerCardsController extends GetxController {
  final ApiServices _apiService = ApiServices();

  // App config instance
  final AppConfig _config = AppConfig.instance;

  // Observable lists
  var apiCustomers = <Customer>[].obs;
  var filteredCustomers = <Customer>[].obs;

  // Observable filters
  var searchQuery = ''.obs;
  var selectedFilter = 'All'.obs;
  var sortBy = 'Name'.obs;
  RxBool isFiltersExpanded = false.obs;
  RxBool isTableView = false.obs;
 void toggleView() {
    isTableView.value = !isTableView.value;
  }

  // Debounce timer for search
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  void toggleFiltersExpanded() {
    isFiltersExpanded.value = !isFiltersExpanded.value;
  }

  // Loading states
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isSearching = false.obs; // New loading state for search
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Pagination
  var currentPage = 0.obs;
  var pageSize = 20.obs;
  var totalPages = 0.obs;
  var totalElements = 0.obs;

  // API response
  CustomerResponse? customerResponse;

  // Statistics
  var totalCustomers = 0.obs;
  var newCustomers = 0.obs;
  var regularCustomers = 0.obs;
  var repeatedCustomers = 0.obs;
  var vipCustomers = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load customers from API instead of arguments
    loadCustomersFromApi();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  // Load customers from API
  Future<void> loadCustomersFromApi({bool loadMore = false, String? keyword}) async {
    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        if (keyword != null && keyword.isNotEmpty) {
          isSearching.value = true;
        } else {
          isLoading.value = true;
        }
        hasError.value = false;
        currentPage.value = 0;
      }

      // Build query parameters
      Map<String, dynamic> queryParams = {
        'page': currentPage.value,
        'size': pageSize.value,
        'sortBy': 'id',
        'direction': 'asc',
      };

      // Add keyword if provided
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/customers/all/paginated',
        dictParameter: queryParams,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        customerResponse = CustomerResponse.fromJson(response.data);

        if (loadMore) {
          apiCustomers.addAll(customerResponse!.payload.content);
        } else {
          apiCustomers.assignAll(customerResponse!.payload.content);
        }

        // Update pagination info
        totalPages.value = customerResponse!.payload.totalPages;
        totalElements.value = customerResponse!.payload.totalElements;

        // Update statistics
        _updateStatistics();

        // Apply current filters (excluding search since it's handled by API)
        _applyLocalFilters();
      } else {
        hasError.value = true;
        errorMessage.value =
            'Failed to load customers. Status: ${response?.statusCode}';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading customers: $e';
      log('Error loading customers: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
      isSearching.value = false;
    }
  }

  // Load more customers (pagination)
  Future<void> loadMoreCustomers() async {
    if (currentPage.value < totalPages.value - 1 && !isLoadingMore.value) {
      currentPage.value++;
      String keyword = searchQuery.value.trim();
      await loadCustomersFromApi(
        loadMore: true, 
        keyword: keyword.isNotEmpty ? keyword : null
      );
    }
  }

  // Refresh customers
  Future<void> refreshCustomers() async {
    String keyword = searchQuery.value.trim();
    await loadCustomersFromApi(keyword: keyword.isNotEmpty ? keyword : null);
  }

  // Update statistics based on loaded customers
  void _updateStatistics() {
    totalCustomers.value = apiCustomers.length;
    newCustomers.value =
        apiCustomers.where((c) => c.customerType == 'New').length;
    regularCustomers.value =
        apiCustomers.where((c) => c.customerType == 'Regular').length;
    repeatedCustomers.value =
        apiCustomers.where((c) => c.customerType == 'Repeated').length;
    vipCustomers.value =
        apiCustomers.where((c) => c.customerType == 'VIP').length;
  }

  // Debounced search functionality
  void onSearchChanged(String query) {
    searchQuery.value = query;
    
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Start new timer
    _debounceTimer = Timer(_debounceDuration, () {
      _performSearch(query.trim());
    });
  }

  // Perform actual search
  Future<void> _performSearch(String keyword) async {
    if (keyword.isEmpty) {
      // If search is empty, load all customers
      await loadCustomersFromApi();
    } else {
      // Perform API search with keyword
      await loadCustomersFromApi(keyword: keyword);
    }
  }

  // Filter functionality (now only for customer type, search is handled by API)
  void onFilterChanged(String filter) {
    selectedFilter.value = filter;
    _applyLocalFilters();
  }

  // Sort functionality
  void onSortChanged(String sort) {
    sortBy.value = sort;
    _applyLocalFilters();
  }

  // Apply local filters (excluding search which is handled by API)
  void _applyLocalFilters() {
    filteredCustomers.value = apiCustomers.where((customer) {
      // Category filter only (search is handled by API)
      bool matchesCategory = selectedFilter.value == 'All' ||
          customer.customerType == selectedFilter.value;

      return matchesCategory;
    }).toList();

    // Sort customers
    _sortCustomers();
  }

  // Legacy method for backward compatibility
  void filterCustomers() {
    _applyLocalFilters();
  }

  // Sort customers based on selected criteria
  void _sortCustomers() {
    switch (sortBy.value) {
      case 'Name':
        filteredCustomers.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Total Purchase':
        filteredCustomers.sort(
          (a, b) => b.totalPurchase.compareTo(a.totalPurchase),
        );
        break;
      case 'Total Dues':
        filteredCustomers.sort((a, b) => b.totalDues.compareTo(a.totalDues));
        break;
      case 'Location':
        filteredCustomers.sort((a, b) => a.location.compareTo(b.location));
        break;
    }
  }

  // Reset all filters
  void resetFilters() {
    // Cancel any pending search
    _debounceTimer?.cancel();
    
    searchQuery.value = '';
    selectedFilter.value = 'All';
    sortBy.value = 'Name';
    
    // Load all customers without search
    loadCustomersFromApi();
  }

  // Get customer type color
  Color getCustomerTypeColor(String type) {
    switch (type) {
      case 'VIP':
        return Color(0xFFFFD700); // Gold
      case 'Repeated':
        return Color(0xFF51CF66); // Green
      case 'Regular':
        return Color(0xFF6C5CE7); // Purple
      case 'New':
        return Color(0xFF00CEC9); // Teal
      default:
        return Colors.grey;
    }
  }

  // Get customer type icon
  IconData getCustomerTypeIcon(String type) {
    switch (type) {
      case 'VIP':
        return Icons.star;
      case 'Repeated':
        return Icons.refresh;
      case 'Regular':
        return Icons.person;
      case 'New':
        return Icons.person_add;
      default:
        return Icons.person_outline;
    }
  }

  // Get stats for each customer type
  int getCustomerCountByType(String type) {
    switch (type) {
      case 'All':
        return totalCustomers.value;
      case 'New':
        return newCustomers.value;
      case 'Regular':
        return regularCustomers.value;
      case 'Repeated':
        return repeatedCustomers.value;
      case 'VIP':
        return vipCustomers.value;
      default:
        return 0;
    }
  }

  // Edit customer
  void editCustomer(Customer customer) {
    // Navigate to edit customer page
    // Get.toNamed(AppRoutes.editCustomer, arguments: customer);
    print('Edit customer: ${customer.name}');
  }

  // Delete customer
  void deleteCustomer(Customer customer) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () async {
              apiCustomers.removeWhere((c) => c.id == customer.id);
              _updateStatistics();
              _applyLocalFilters();
              Get.back();
            
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Call customer
  void callCustomer(String phoneNumber) async {
    try {
      bool success = await PhoneDialerService.launchPhoneDialer(phoneNumber);
      if (!success) {
        print('Failed to launch phone dialer');
      }
    } catch (e) {
      print('Error calling customer: $e');
      
    }
  }

  RxString sortColumn = 'name'.obs;
  RxBool isAscending = true.obs;
  
  void sortCustomers(String column) {
    if (sortColumn.value == column) {
      isAscending.value = !isAscending.value;
    } else {
      sortColumn.value = column;
      isAscending.value = true;
    }

    filteredCustomers.sort((a, b) {
      int compare = 0;
      switch (column) {
        case 'name':
          compare = a.name.compareTo(b.name);
          break;
        case 'phone':
          compare = a.primaryPhone.compareTo(b.primaryPhone);
          break;
        case 'location':
          compare = a.location.compareTo(b.location);
          break;
        case 'purchase':
          compare = a.totalPurchase.compareTo(b.totalPurchase);
          break;
        case 'dues':
          compare = a.totalDues.compareTo(b.totalDues);
          break;
        case 'type':
          compare = a.customerType.compareTo(b.customerType);
          break;
      }
      return isAscending.value ? compare : -compare;
    });
  }

}