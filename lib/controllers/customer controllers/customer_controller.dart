import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/customer%20management/chart/montly_new_customer_model.dart';
import 'package:smartbecho/models/customer%20management/chart/top_customer_model.dart';
import 'package:smartbecho/models/customer%20management/customer_data_model.dart';
import 'package:smartbecho/models/customer%20management/repeated_customer_response_model.dart';
import 'package:smartbecho/models/customer%20management/top_stats_card_model.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/services/launch_phone_dailer_service.dart';
import 'package:smartbecho/views/customer/components/repeated_customer_bottom_sheet.dart';

class CustomerController extends GetxController {
  // API service instance
  final ApiServices _apiService = ApiServices();

  // App config instance
  final AppConfig _config = AppConfig.instance;

  // Observable variables for customer data
  var isLoading = false.obs;
  var isLoadingState = false.obs;

  var hasError = false.obs;
  var errorMessage = ''.obs;

  // View toggle
  var isTableView = true.obs;

  // Customer statistics
  var totalCustomers = 0.obs;
  var repeatedCustomers = 0.obs;
  var newCustomersThisMonth = 0.obs;
  var totalPurchases = 0.obs;

  // API Customer data
  var apiCustomers = <Customer>[].obs;
  var filteredApiCustomers = <Customer>[].obs;

  // Pagination
  var currentPage = 0.obs;
  var totalPages = 0.obs;
  var totalElements = 0.obs;
  var pageSize = 10.obs;
  var isLoadingMore = false.obs;

  // Search and filters
  var searchQuery = ''.obs;
  var selectedFilter = 'All Customers'.obs;
  var filterOptions =
      [
        'All Customers',
        'New Customers',
        'Regular Customers',
        'Repeated Customers',
        'VIP Customers',
      ].obs;
  // Add this to your controller
  final RxBool isFiltersExpanded = false.obs;

  void toggleFiltersExpanded() {
    isFiltersExpanded.value = !isFiltersExpanded.value;
  }

  // Pluto Grid
  PlutoGridStateManager? plutoGridStateManager;
  List<PlutoColumn> columns = [];
  RxList<PlutoRow> rows = <PlutoRow>[].obs;
  var selectedCustomer = Rxn<Customer>();


 Worker? _searchDebouncer;

  // Add search keyword observable
  final RxString searchKeyword = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeColumns();
    
    // Set up search debouncer
    _searchDebouncer = debounce(
      searchKeyword,
      (String query) => loadCustomersFromApi(),
      time: const Duration(milliseconds: 800),
    );
    
    getTopCardStats();
    loadCustomersFromApi();
  }

@override
  void onClose() {
    searchController.dispose();
    _searchDebouncer?.dispose();
    super.onClose();
  }

  void toggleView() {
    isTableView.value = !isTableView.value;
  }

  void _initializeColumns() {
    columns = [
      PlutoColumn(
        title: 'ID',
        field: 'id',
        type: PlutoColumnType.number(),
        width: 80,
        enableRowDrag: false,
        hide: true,
        enableRowChecked: false,
        enableSorting: true,
        enableHideColumnMenuItem: false,
        renderer: (rendererContext) {
          return Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              rendererContext.cell.value.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6C5CE7),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Customer Name',
        field: 'name',
        type: PlutoColumnType.text(),
        width: 180,
        enableSorting: true,
        renderer: (rendererContext) {
          final customer = apiCustomers.firstWhere(
            (c) =>
                c.id.toString() ==
                rendererContext.row.cells['id']?.value.toString(),
            orElse:
                () => Customer(
                  id: 0,
                  name: '',
                  primaryPhone: '',
                  primaryAddress: '',
                  location: '',
                  profilePhotoUrl: '',
                  alternatePhones: [],
                  totalDues: 0.0,
                  totalPurchase: 0.0,
                ),
          );

          return Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  rendererContext.cell.value.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (customer.id != 0)
                  Text(
                    customer.location,
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Phone',
        field: 'phone',
        type: PlutoColumnType.text(),
        width: 130,
        enableSorting: true,
        renderer: (rendererContext) {
          return Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerLeft,
            child: Text(
              rendererContext.cell.value.toString(),
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Location',
        field: 'location',
        type: PlutoColumnType.text(),
        width: 120,
        enableSorting: true,
        renderer: (rendererContext) {
          return Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF6C5CE7).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                rendererContext.cell.value.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6C5CE7),
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Total Purchase',
        field: 'totalPurchase',
        type: PlutoColumnType.currency(symbol: '₹', decimalDigits: 0),
        width: 120,
        enableSorting: true,
        textAlign: PlutoColumnTextAlign.right,
        renderer: (rendererContext) {
          final amount = rendererContext.cell.value as num;
          return Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerRight,
            child: Text(
              formatCurrency(amount.toInt()),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: amount > 20000 ? Color(0xFF51CF66) : Colors.black87,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Total Dues',
        field: 'totalDues',
        type: PlutoColumnType.currency(symbol: '₹', decimalDigits: 0),
        width: 120,
        enableSorting: true,
        textAlign: PlutoColumnTextAlign.right,
        renderer: (rendererContext) {
          final amount = rendererContext.cell.value as num;
          return Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerRight,
            child: Text(
              formatCurrency(amount.toInt()),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: amount > 0 ? Color(0xFFE74C3C) : Colors.black87,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Customer Type',
        field: 'type',
        type: PlutoColumnType.select(['New', 'Regular', 'VIP', 'Repeated']),
        width: 110,
        enableSorting: true,
        renderer: (rendererContext) {
          final type = rendererContext.cell.value.toString();
          Color typeColor;
          Color bgColor;

          switch (type) {
            case 'VIP':
              typeColor = Color(0xFFFF9500);
              bgColor = Color(0xFFFF9500).withValues(alpha:0.1);
              break;
            case 'Repeated':
              typeColor = Color(0xFF51CF66);
              bgColor = Color(0xFF51CF66).withValues(alpha:0.1);
              break;
            case 'Regular':
              typeColor = Color(0xFF00CEC9);
              bgColor = Color(0xFF00CEC9).withValues(alpha:0.1);
              break;
            default:
              typeColor = Color(0xFF6C5CE7);
              bgColor = Color(0xFF6C5CE7).withValues(alpha:0.1);
          }

          return Container(
            padding: EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: typeColor,
                ),
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Actions',
        field: 'actions',
        type: PlutoColumnType.text(),
        width: 120,
        enableSorting: false,
        enableColumnDrag: false,
        enableContextMenu: false,
        renderer: (rendererContext) {
          return Container(
            padding: EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    final customer = _getCustomerFromRow(rendererContext.row);
                    viewCustomerDetails(customer);
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(0xFF6C5CE7).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.visibility,
                      size: 16,
                      color: Color(0xFF6C5CE7),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    final customer = _getCustomerFromRow(rendererContext.row);
                    editCustomer(customer);
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF9500).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.edit, size: 16, color: Color(0xFFFF9500)),
                  ),
                ),
                InkWell(
                  onTap: () {
                    final customer = _getCustomerFromRow(rendererContext.row);
                    deleteCustomer(customer);
                  },
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Color(0xFFE74C3C).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.delete,
                      size: 16,
                      color: Color(0xFFE74C3C),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ];
  }

  Customer _getCustomerFromRow(PlutoRow row) {
    return apiCustomers.firstWhere(
      (customer) => customer.id.toString() == row.cells['id']?.value.toString(),
      orElse:
          () => Customer(
            id: 0,
            name: '',
            primaryPhone: '',
            primaryAddress: '',
            location: '',
            profilePhotoUrl: '',
            alternatePhones: [],
            totalDues: 0.0,
            totalPurchase: 0.0,
          ),
    );
  }

  CustomerResponse? customerResponse;
  Future<void> loadCustomersFromApi({bool loadMore = false}) async {
    try {
      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoading.value = true;
        hasError.value = false;
        currentPage.value = 0;
      }

      // Build query parameters
      final queryParams = <String, dynamic>{
        'page': currentPage.value.toString(),
        'size': pageSize.value.toString(),
        'sortBy': 'id',
        'direction': 'asc',
      };

      // Add search keyword if present
      if (searchKeyword.value.trim().isNotEmpty) {
        queryParams['keyword'] = searchKeyword.value.trim();
      }

      // Add filter if not 'All Customers'
      if (selectedFilter.value != 'All Customers') {
        String filterType = selectedFilter.value
            .toLowerCase()
            .replaceAll(' customers', '')
            .replaceAll(' ', '_');
        queryParams['customerType'] = filterType;
      }

      log('🔍 Loading customers with params: $queryParams');

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

        // Update filtered list
        filteredApiCustomers.assignAll(apiCustomers);
        _generateRows();

        log('✅ Loaded ${apiCustomers.length} customers');
      } else {
        hasError.value = true;
        errorMessage.value =
            'Failed to load customers. Status: ${response?.statusCode}';
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error loading customers: $e';
      log('❌ Error loading customers: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

   void loadMoreCustomers() {
    if (currentPage.value < totalPages.value - 1 && !isLoadingMore.value) {
      currentPage.value++;
      loadCustomersFromApi(loadMore: true);
    }
  }

  void _generateRows() {
    rows.clear();
    for (var customer in filteredApiCustomers) {
      rows.add(
        PlutoRow(
          cells: {
            'id': PlutoCell(value: customer.id),
            'name': PlutoCell(value: customer.name),
            'phone': PlutoCell(value: customer.primaryPhone),
            'location': PlutoCell(value: customer.location),
            'totalPurchase': PlutoCell(value: customer.totalPurchase),
            'totalDues': PlutoCell(value: customer.totalDues),
            'type': PlutoCell(value: customer.customerType),
            'actions': PlutoCell(value: ''), // Placeholder for actions
          },
        ),
      );
    }
    plutoGridStateManager?.notifyListeners();
  }
   TextEditingController searchController = TextEditingController();
  void clearFilters() {
    searchController.clear();
    searchKeyword.value = '';
    searchQuery.value = '';
    selectedFilter.value = 'All Customers';
    currentPage.value = 0;
    loadCustomersFromApi();
  }

 
   void filterCustomers() {
    // Since we're using API-based filtering, this just updates the rows
    _generateRows();
  }

 void onSearchChanged(String query) {
    searchKeyword.value = query.trim();
    // Debounce will automatically trigger loadCustomersFromApi after 800ms
  }
  void onFilterChanged(String filter) {
    selectedFilter.value = filter;
    currentPage.value = 0;
    loadCustomersFromApi();
  }
  void clearSearch() {
    searchController.clear();
    searchKeyword.value = '';
    searchQuery.value = '';
  }
  void viewCustomerDetails(Customer customer) {
    selectedCustomer.value = customer;
    // Navigate to detail view
    print('Viewing: ${customer.name}');
  }

  void editCustomer(Customer customer) {
    selectedCustomer.value = customer;
    // Navigate to edit screen
    print('Editing: ${customer.name}');
  }

  void deleteCustomer(Customer customer) {
    // Call delete API first, then update local data
    apiCustomers.removeWhere((c) => c.id == customer.id);
    filterCustomers();
    print('Deleted: ${customer.name}');
  }

  String formatCurrency(int value) {
    return '₹${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  void refreshData() {
    loadCustomersFromApi();
  }
// Monthly New Customer Chart API
RxBool isMonthlyNewCustomerChartLoading = false.obs;
var monthlyNewCustomerCharterrorMessage = ''.obs;
var hasMonthlyNewCustomerChartError = false.obs;
RxMap<String, double> monthlyNewCustomerPayload = RxMap<String, double>({});

Future<void> fetchMonthlyNewCustomerChart({
  int? year,
  int? month,
}) async {
  try {
    isMonthlyNewCustomerChartLoading.value = true;
    hasMonthlyNewCustomerChartError.value = false;
    monthlyNewCustomerCharterrorMessage.value = '';

    // Build query parameters
    final queryParams = <String, dynamic>{};
    if (year != null) queryParams['year'] = year;
    if (month != null) queryParams['month'] = month;

    dio.Response? response = await _apiService.requestGetForApi(
      url: _config.getMonthlyNewCustomerEndpoint,
      dictParameter: queryParams.isNotEmpty ? queryParams : null,
      authToken: true,
    );

    if (response != null && response.statusCode == 200) {
      final responseData = CustomerMonthlyDataResponse.fromJson(
        response.data,
      );
      monthlyNewCustomerPayload.value = Map<String, double>.from(
        responseData.payload,
      );
    } else {
      hasMonthlyNewCustomerChartError.value = true;
      monthlyNewCustomerCharterrorMessage.value =
          'Failed to fetch data. Status: ${response?.statusCode}';
    }
  } catch (error) {
    hasMonthlyNewCustomerChartError.value = true;
    monthlyNewCustomerCharterrorMessage.value = 'Error: $error';
  } finally {
    isMonthlyNewCustomerChartLoading.value = false;
  }
}

// Village Distribution Chart API
RxBool isVillageDistributionChartLoading = false.obs;
var villageDistributionChartErrorMessage = ''.obs;
var hasVillageDistributionChartError = false.obs;
RxMap<String, double> villageDistributionPayload = RxMap<String, double>({});

Future<void> fetchVillageDistributionChart({
  int? year,
  int? month,
}) async {
  try {
    isVillageDistributionChartLoading.value = true;
    hasVillageDistributionChartError.value = false;
    villageDistributionChartErrorMessage.value = '';

    // Build query parameters
    final queryParams = <String, dynamic>{};
    if (year != null) queryParams['year'] = year;
    if (month != null) queryParams['month'] = month;

    dio.Response? response = await _apiService.requestGetForApi(
      url: _config.getVillageDistributionEndpoint,
      dictParameter: queryParams.isNotEmpty ? queryParams : null,
      authToken: true,
    );

    if (response != null && response.statusCode == 200) {
      final responseData = CustomerMonthlyDataResponse.fromJson(
        response.data,
      );
      villageDistributionPayload.value = Map<String, double>.from(
        responseData.payload,
      );
    } else {
      hasVillageDistributionChartError.value = true;
      villageDistributionChartErrorMessage.value =
          'Failed to fetch data. Status: ${response?.statusCode}';
    }
  } catch (error) {
    hasVillageDistributionChartError.value = true;
    villageDistributionChartErrorMessage.value = 'Error: $error';
  } finally {
    isVillageDistributionChartLoading.value = false;
  }
}

// Monthly Repeat Customer Chart API
RxBool isMonthlyRepeatCustomerChartLoading = false.obs;
var monthlyRepeatCustomerChartErrorMessage = ''.obs;
var hasMonthlyRepeatCustomerChartError = false.obs;
RxMap<String, double> monthlyRepeatCustomerPayload = RxMap<String, double>({});

Future<void> fetchMonthlyRepeatCustomerChart({
  int? year,
  int? month,
}) async {
  
  try {
    isMonthlyRepeatCustomerChartLoading.value = true;
    hasMonthlyRepeatCustomerChartError.value = false;
    monthlyRepeatCustomerChartErrorMessage.value = '';

    // Build query parameters
    final queryParams = <String, dynamic>{};
    if (year != null) queryParams['year'] = year;
    if (month != null) queryParams['month'] = month;

    dio.Response? response = await _apiService.requestGetForApi(
      url: _config.getMonthlyRepeatCustomerEndpoint,
      dictParameter: queryParams.isNotEmpty ? queryParams : null,
      authToken: true,
    );

    if (response != null && response.statusCode == 200) {
      final responseData = CustomerMonthlyDataResponse.fromJson(
        response.data,
      );
      monthlyRepeatCustomerPayload.value = Map<String, double>.from(
        responseData.payload,
      );
    } else {
      hasMonthlyRepeatCustomerChartError.value = true;
      monthlyRepeatCustomerChartErrorMessage.value =
          'Failed to fetch data. Status: ${response?.statusCode}';
    }
  } catch (error) {
    hasMonthlyRepeatCustomerChartError.value = true;
    monthlyRepeatCustomerChartErrorMessage.value = 'Error: $error';
  } finally {
    isMonthlyRepeatCustomerChartLoading.value = false;
  }
}
  // Top Customer Overview
  RxBool isTopCustomerChartLoading = false.obs;
  var topCustomerChartErrorMessage = ''.obs;
  var hasTopCustomerChartError = false.obs;
  RxList<Map<String, dynamic>> topCustomerChartData =
      <Map<String, dynamic>>[].obs;

  Future<void> fetchTopCustomerChart() async {
    try {
      isTopCustomerChartLoading.value = true;
      hasTopCustomerChartError.value = false;
      topCustomerChartErrorMessage.value = '';

      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.getTopCustomerOverviewEndpoint,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final responseData = TopCustomersResponse.fromJson(response.data);
        topCustomerChartData.value =
            responseData.payload
                .map(
                  (customer) => {
                    'customerId': customer.customerId,
                    'totalSales': customer.totalSales,
                    'name': customer.name,
                  },
                )
                .toList();
      } else {
        hasTopCustomerChartError.value = true;
        topCustomerChartErrorMessage.value =
            'Failed to fetch data. Status: ${response?.statusCode}';
      }
    } catch (error) {
      hasTopCustomerChartError.value = true;
      topCustomerChartErrorMessage.value = 'Error: $error';
    } finally {
      isTopCustomerChartLoading.value = false;
    }
  }

  // Additional utility methods
  void sortCustomersByName() {
    apiCustomers.sort((a, b) => a.name.compareTo(b.name));
    filterCustomers();
  }

  void sortCustomersByPurchase() {
    apiCustomers.sort((a, b) => b.totalPurchase.compareTo(a.totalPurchase));
    filterCustomers();
  }

  void sortCustomersByDues() {
    apiCustomers.sort((a, b) => b.totalDues.compareTo(a.totalDues));
    filterCustomers();
  }

  // Export functionality
  Future<void> exportCustomersToCSV() async {
    try {
      // Implementation for CSV export
      List<List<String>> csvData = [
        [
          'ID',
          'Name',
          'Phone',
          'Location',
          'Total Purchase',
          'Total Dues',
          'Type',
        ],
      ];

      for (var customer in filteredApiCustomers) {
        csvData.add([
          customer.id.toString(),
          customer.name,
          customer.primaryPhone,
          customer.location,
          customer.totalPurchase.toString(),
          customer.totalDues.toString(),
          customer.customerType,
        ]);
      }

      // Here you would implement the actual CSV export logic
      print('Exporting ${csvData.length - 1} customers to CSV');
    } catch (e) {
      print('Error exporting to CSV: $e');
    }
  }

  //go to all customer screen
  void gotoAllCustomerPage() {
    Get.toNamed(AppRoutes.customerDetails);
  }

  // Bulk operations
  Future<void> bulkDeleteCustomers(List<int> customerIds) async {
    try {
      isLoading.value = true;

      for (int id in customerIds) {
        dio.Response? response = await _apiService.requestPostForApi(
          url: '${_config.baseUrl}/customers/$id',
          authToken: true,
          dictParameter: {},
        );

        if (response?.statusCode == 200) {
          apiCustomers.removeWhere((customer) => customer.id == id);
        }
      }

      filterCustomers();
    } catch (e) {
      print('Error in bulk delete: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Customer creation
  Future<bool> createCustomer(Map<String, dynamic> customerData) async {
    try {
      isLoading.value = true;

      dio.Response? response = await _apiService.requestPostForApi(
        url: '${_config.baseUrl}/customers',
        dictParameter: customerData,
        authToken: true,
      );

      if (response != null && response.statusCode == 201) {
        // Refresh the customer list
        await loadCustomersFromApi();
        return true;
      }
      return false;
    } catch (e) {
      print('Error creating customer: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Customer update
  Future<bool> updateCustomer(
    int customerId,
    Map<String, dynamic> customerData,
  ) async {
    try {
      isLoading.value = true;

      dio.Response? response = await _apiService.requestPostForApi(
        url: '${_config.baseUrl}/customers/$customerId',
        dictParameter: customerData,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        // Update local data
        final index = apiCustomers.indexWhere(
          (customer) => customer.id == customerId,
        );
        if (index != -1) {
          // Update the customer in the list
          await loadCustomersFromApi();
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating customer: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Customer details by ID
  Future<Customer?> getCustomerById(int customerId) async {
    try {
      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/customers/$customerId',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        return Customer.fromJson(response.data['payload']);
      }
      return null;
    } catch (e) {
      print('Error fetching customer by ID: $e');
      return null;
    }
  }

  //get top cards stats
  Future getTopCardStats() async {
    try {
      isLoadingState.value = true;
      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.getTopStatsCardsDataEndpoint,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final cardData = CustomerStatsResponse.fromJson(response.data);
        totalCustomers.value = cardData.payload.totalCustomers;
        repeatedCustomers.value = cardData.payload.repeatedCustomers;
        newCustomersThisMonth.value = cardData.payload.newCustomersThisMonth;
      }
      return null;
    } catch (e) {

      print('Error fetching customer by ID: $e');
      
      return null;
    }finally{
      isLoadingState.value =false;
    }
  }

  // Advanced search with multiple criteria
  void advancedSearch({
    String? name,
    String? phone,
    String? location,
    String? customerType,
    double? minPurchase,
    double? maxPurchase,
    double? minDues,
    double? maxDues,
  }) {
    filteredApiCustomers.assignAll(
      apiCustomers.where((customer) {
        bool matches = true;

        if (name != null && name.isNotEmpty) {
          matches =
              matches &&
              customer.name.toLowerCase().contains(name.toLowerCase());
        }

        if (phone != null && phone.isNotEmpty) {
          matches = matches && customer.primaryPhone.contains(phone);
        }

        if (location != null && location.isNotEmpty) {
          matches =
              matches &&
              customer.location.toLowerCase().contains(location.toLowerCase());
        }

        if (customerType != null &&
            customerType.isNotEmpty &&
            customerType != 'All') {
          matches =
              matches &&
              customer.customerType.toLowerCase() == customerType.toLowerCase();
        }

        if (minPurchase != null) {
          matches = matches && customer.totalPurchase >= minPurchase;
        }

        if (maxPurchase != null) {
          matches = matches && customer.totalPurchase <= maxPurchase;
        }

        if (minDues != null) {
          matches = matches && customer.totalDues >= minDues;
        }

        if (maxDues != null) {
          matches = matches && customer.totalDues <= maxDues;
        }

        return matches;
      }),
    );

    _generateRows();
  }

  // Reset all filters
  void resetFilters() {
    searchController.clear();
    searchKeyword.value = '';
    searchQuery.value = '';
    selectedFilter.value = 'All Customers';
    currentPage.value = 0;
    loadCustomersFromApi();
  }

  // Method to handle PlutoGrid state manager
  void onPlutoGridLoaded(PlutoGridOnLoadedEvent event) {
    plutoGridStateManager = event.stateManager;
    _generateRows();
  }

  // Method to handle row selection
  void onRowSelected(PlutoGridOnSelectedEvent event) {
    if (event.row != null) {
      final customer = _getCustomerFromRow(event.row!);
      selectedCustomer.value = customer;
    }
  }

  // Method to handle double tap on row
  void onRowDoubleTap(PlutoGridOnRowDoubleTapEvent event) {
    final customer = _getCustomerFromRow(event.row);
    viewCustomerDetails(customer);
  }




  // Repeated Customers Modal
RxBool isRepeatedCustomersLoading = false.obs;
var repeatedCustomersErrorMessage = ''.obs;
var hasRepeatedCustomersError = false.obs;
RxList<RepeatedCustomer> repeatedCustomersList = <RepeatedCustomer>[].obs;

// Add this method to your CustomerController class:

Future<void> fetchRepeatedCustomers() async {
  try {
    isRepeatedCustomersLoading.value = true;
    hasRepeatedCustomersError.value = false;
    repeatedCustomersErrorMessage.value = '';

    dio.Response? response = await _apiService.requestGetForApi(
      url: '${_config.baseUrl}/api/customers/stats',
      authToken: true,
    );

    if (response != null && response.statusCode == 200) {
      final responseData = RepeatedCustomerResponse.fromJson(response.data);
      repeatedCustomersList.value = responseData.payload.repeatedCustomerList;
    } else {
      hasRepeatedCustomersError.value = true;
      repeatedCustomersErrorMessage.value =
          'Failed to fetch repeated customers. Status: ${response?.statusCode}';
    }
  } catch (error) {
    hasRepeatedCustomersError.value = true;
    repeatedCustomersErrorMessage.value = 'Error: $error';
    log('Error fetching repeated customers: $error');
  } finally {
    isRepeatedCustomersLoading.value = false;
  }
}

// Method to show repeated customers modal
void showRepeatedCustomersModal() {
  fetchRepeatedCustomers();
  
  Get.bottomSheet(
    RepeatedCustomersModal(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
  );
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

  
  // Call customer
  void callCustomer(String phoneNumber) async {
    try {
      bool success = await PhoneDialerService.launchPhoneDialer(phoneNumber);
      if (!success) {
        print('Failed to launch phone dialer');
      }
    } catch (e) {
      print('Error calling customer: $e');
      
      Get.snackbar('Error', 'Unable to make call: ${e.toString()}');
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

    // Sort logic
    filteredApiCustomers.sort((a, b) {
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

  var isLastPage = false.obs;
  Future<void> loadMoreCustomersn() async {
  if (isLoadingMore.value || isLastPage.value) return;

  isLoadingMore.value = true;
  try {
     dio.Response? newCustomers = await _apiService.requestGetForApi(
        url:
            '${_config.baseUrl}/api/customers/all/paginated?page=${currentPage.value}&size=${pageSize.value}&sortBy=id&direction=asc',
        authToken: true,
      );
    
     
  
    if (newCustomers!=null) {
      isLastPage.value = true;
    } else {
      currentPage++;
      // apiCustomers.addAll(newCustomers);
      filteredApiCustomers.assignAll(apiCustomers);
    }
  } catch (e) {
    hasError.value = true;
  } finally {
    isLoadingMore.value = false;
  }
}

}