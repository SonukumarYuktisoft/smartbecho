import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/todays_due_retrieval_controller.dart';
import 'package:smartbecho/models/customer%20dues%20management/add_partial_payment_reponse_model.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:smartbecho/models/customer%20dues%20management/all_customer_dues_model.dart';
import 'package:smartbecho/models/customer%20dues%20management/customer_due_detail_model.dart';
import 'package:smartbecho/models/customer%20dues%20management/dues_summary_data_model.dart';
import 'package:smartbecho/models/customer%20dues%20management/monthly_dues_analytics_model.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/services/launch_phone_dailer_service.dart';
import 'package:smartbecho/views/customer%20dues/components/customer_analytics.dart';
import 'package:smartbecho/views/customer%20dues/components/customer%20dues%20details/customer_dues_details.dart';

class CustomerDuesController extends GetxController {
  // API service instance
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;
  final RetrievalDueController retrievalDueController = Get.put(
    RetrievalDueController(),
  );
  // Loading states
  final RxBool isLoading = false.obs;
  var isNotifying = false.obs;

  final RxBool isLoadingMore = false.obs;
  final RxBool isSummaryLoading = false.obs;
  final RxBool isAnalyticsLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Pagination Data
  final RxList<CustomerDue> allDues = <CustomerDue>[].obs;
  final RxList<CustomerDue> paidDues = <CustomerDue>[].obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalElements = 0.obs;
  final RxBool hasNextPage = true.obs;
  final RxBool isLastPage = false.obs;

  // Summary and Analytics
  final Rx<DuesSummaryModel?> summaryData = Rx<DuesSummaryModel?>(null);
  final RxList<MonthlyDuesSummary> analyticsData = <MonthlyDuesSummary>[].obs;

  // Filters and Search
  final RxString searchQuery = ''.obs;
  final RxString selectedTab = 'dues'.obs; // 'dues' or 'paid'
  final RxBool isPaidFilter = false.obs;

  // Filter Parameters
  final RxnInt selectedYear = RxnInt(null);
  final RxnInt selectedMonth = RxnInt(null);
  final Rxn<DateTime> startDate = Rxn<DateTime>(null);
  final Rxn<DateTime> endDate = Rxn<DateTime>(null);
  final RxString sortBy = 'id'.obs;
  final RxString sortDir = 'asc'.obs;
  final RxString timePeriodType = 'Month/Year'.obs;

  // Controllers for date fields
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  // Filter options
  final List<String> timePeriodOptions = ['Month/Year', 'Custom Range'];
  final List<String> sortOptions = [
    'id',
    'creationDate',
    'totalDue',
    'totalPaid',
    'remainingDue',
    'name',
  ];

  final RxBool isFiltersExpanded = false.obs;

  // Constants
  static const int pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    selectedYear.value = DateTime.now().year;
    retrievalDueController.fetchRetrievalDues();
    fetchCustomerDues(isRefresh: true);
    getSummaryData();

    debounce(
      searchQuery,
      (_) => _handleSearch(),
      time: Duration(milliseconds: 500),
    );
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }

  // Fetch customer dues from API with pagination and filters
  Future<void> fetchCustomerDues({
    bool isRefresh = false,
    bool isLoadMore = false,
  }) async {
    try {
      if (isRefresh) {
        isLoading.value = true;
        currentPage.value = 0;
        if (isPaidFilter.value) {
          paidDues.clear();
        } else {
          allDues.clear();
        }
        hasError.value = false;
        errorMessage.value = '';
      } else if (isLoadMore) {
        if (isLastPage.value || isLoadingMore.value) return;
        isLoadingMore.value = true;
        currentPage.value++;
      }

      Map<String, dynamic> queryParams = {
        'page': currentPage.value,
        'size': pageSize,
        'isPaid': isPaidFilter.value,
        'sortBy': sortBy.value,
        'sortDir': sortDir.value,
      };

      if (searchQuery.value.isNotEmpty) {
        queryParams['keyword'] = searchQuery.value;
      }

      if (timePeriodType.value == 'Month/Year') {
        if (selectedYear.value != null) {
          queryParams['year'] = selectedYear.value;
        }
        if (selectedMonth.value != null) {
          queryParams['month'] = selectedMonth.value;
        }
      } else if (timePeriodType.value == 'Custom Range') {
        if (startDate.value != null) {
          queryParams['startDate'] = _formatDateForAPI(startDate.value!);
        }
        if (endDate.value != null) {
          queryParams['endDate'] = _formatDateForAPI(endDate.value!);
        }
      }

      log("Fetching dues with params: $queryParams");

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/dues/all',
        authToken: true,
        dictParameter: queryParams,
        // featureKey: FeatureKeys.DUES.viewAllDues,
      );

      if (response != null) {
        final duesResponse = CustomerDuesResponse.fromJson(response.data);

        if (duesResponse.status == "Success") {
          totalPages.value = duesResponse.payload.totalPages;
          totalElements.value = duesResponse.payload.totalElements;
          isLastPage.value = duesResponse.payload.last;
          hasNextPage.value = !duesResponse.payload.last;

          if (isRefresh) {
            if (isPaidFilter.value) {
              paidDues.value = duesResponse.payload.content;
            } else {
              allDues.value = duesResponse.payload.content;
            }
          } else if (isLoadMore) {
            if (isPaidFilter.value) {
              paidDues.addAll(duesResponse.payload.content);
            } else {
              allDues.addAll(duesResponse.payload.content);
            }
          }

          log("Customer dues loaded successfully");
          log("Page: ${currentPage.value}, Total Pages: ${totalPages.value}");
          log(
            "Total dues loaded: ${isPaidFilter.value ? paidDues.length : allDues.length}",
          );
        } else {
          throw Exception(duesResponse.message);
        }
      } else {
        throw Exception('No data received from server');
      }
    } catch (error) {
      hasError.value = true;
      errorMessage.value = 'Error: $error';
      log("❌ Error in fetchCustomerDues: $error");
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreDues() async {
    if (!hasNextPage.value || isLoadingMore.value) return;
    await fetchCustomerDues(isLoadMore: true);
  }

  RxBool isSummaryDataLoading = false.obs;
  MonthlyDueSummaryResponse? dueSummaryResponse;
  Future getSummaryData() async {
    try {
      isSummaryDataLoading.value = true;

      dio.Response? response = await _apiService.requestGetForApi(
        url: _config.getSummaryData,
        authToken: true,
        // featureKey: FeatureKeys.DUES.viewCurrentMonthDues,
      );

      if (response != null && response.statusCode == 200) {
        dueSummaryResponse = MonthlyDueSummaryResponse.fromJson(response.data);
        summaryData.value = DuesSummaryModel(
          totalGiven: dueSummaryResponse!.payload.totalDue,
          totalCollected: dueSummaryResponse!.payload.totalCollected,
          totalRemaining: dueSummaryResponse!.payload.remainingDue,
          thisMonthCollection: dueSummaryResponse!.payload.totalPaid,
        );
      } else {
        throw Exception('Failed to load due summary');
      }
    } catch (error) {
      log("❌ Error loading summary: $error");
    } finally {
      isSummaryDataLoading.value = false;
    }
  }

  void _handleSearch() {
    currentPage.value = 0;
    fetchCustomerDues(isRefresh: true);
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void onTabChanged(String tab) {
    selectedTab.value = tab;
    isPaidFilter.value = (tab == 'paid');
    currentPage.value = 0;
    fetchCustomerDues(isRefresh: true);
  }

  void onTimePeriodTypeChanged(String? value) {
    if (value != null) {
      timePeriodType.value = value;
      if (value == 'Month/Year') {
        startDate.value = null;
        endDate.value = null;
        startDateController.clear();
        endDateController.clear();
      } else {
        selectedMonth.value = null;
        selectedYear.value = null;
      }
      currentPage.value = 0;
      fetchCustomerDues(isRefresh: true);
    }
  }

  void onMonthChanged(int? month) {
    selectedMonth.value = month;
    currentPage.value = 0;
    fetchCustomerDues(isRefresh: true);
  }

  void onYearChanged(int? year) {
    selectedYear.value = year;
    currentPage.value = 0;
    fetchCustomerDues(isRefresh: true);
  }

  void onStartDateChanged(DateTime date) {
    startDate.value = date;
    startDateController.text = _formatDateForDisplay(date);
    currentPage.value = 0;
    fetchCustomerDues(isRefresh: true);
  }

  void onEndDateChanged(DateTime date) {
    endDate.value = date;
    endDateController.text = _formatDateForDisplay(date);
    currentPage.value = 0;
    fetchCustomerDues(isRefresh: true);
  }

  void onSortChanged(String field) {
    if (sortBy.value == field) {
      sortDir.value = sortDir.value == 'asc' ? 'desc' : 'asc';
    } else {
      sortBy.value = field;
      sortDir.value = 'desc';
    }
    currentPage.value = 0;
    fetchCustomerDues(isRefresh: true);
  }

  String _formatDateForAPI(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatDateForDisplay(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
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

  Future<void> refreshData() async {
    await fetchCustomerDues(isRefresh: true);
    await getSummaryData();
    await retrievalDueController.refreshData();
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedYear.value = DateTime.now().year;
    selectedMonth.value = null;
    startDate.value = null;
    endDate.value = null;
    startDateController.clear();
    endDateController.clear();
    sortBy.value = 'id';
    sortDir.value = 'asc';
    timePeriodType.value = 'Month/Year';
    fetchCustomerDues(isRefresh: true);
  }

  RxBool isPartialAddedloading = RxBool(false);

  Future<void> addPartialPayment(
    int id,
    double amount,
    String paymentMode,
  ) async {
    isPartialAddedloading.value = true;
    try {
      String paymentMethod = paymentMode.toUpperCase();

      final url =
          '${_config.addPartialPayment}?Id=$id&amount=${amount.ceil()}&paymentMethod=$paymentMethod&remarks=';

      final response = await _apiService.requestPostForApi(
        url: url,
        dictParameter: {},
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 200) {
        final model = PartialPaymentResponseModel.fromJson(response.data);

        if (model.status == 'Success') {
          await refreshData();
        } else {
          throw Exception(model.message);
        }
      } else {
        throw Exception(response?.statusMessage ?? 'Server error');
      }
    } catch (error) {
    } finally {
      isPartialAddedloading.value = false;
    }
  }

  Future<void> markAsPaid(int dueId) async {
    try {
      final url = '${_config.baseUrl}/api/dues/$dueId/mark-paid';

      dio.Response? response = await _apiService.requestPutForApi(
        url: url,
        authToken: true,
        dictParameter: {},
        showToast: true,
      );

      if (response != null && response.data['status'] == 'Success') {
        await refreshData();
      } else {
        throw Exception(response?.data['message'] ?? 'Failed to mark as paid');
      }
    } catch (error) {
      log('markAsPaid: $error');
    }
  }

  void callCustomer(String phoneNumber) async {
    try {
      bool success = await PhoneDialerService.launchPhoneDialer(phoneNumber);
      if (!success) {
        Get.snackbar(
          'Error',
          'Unable to make call',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to make call: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  Future<void> notifyCustomer(int customerId, String customerName) async {
    isNotifying.value = true;
    try {
      Map<String, dynamic> requestData = {
        'customerIds': [customerId],
      };

      dio.Response? response = await _apiService.requestPostForApi(
        url: _config.notifyDueCustomer,
        dictParameter: requestData,
        authToken: true,
        showToast: true,
      );

      if (response != null && response.data['status'] == 'Success') {
        // Get.snackbar(
        //   'Success',
        //   'Notification sent to $customerName',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.blue.withValues(alpha: 0.8),
        //   colorText: Colors.white,
        // );
      } else {
        throw Exception(
          response?.data['message'] ?? 'Failed to send notification',
        );
      }
    } catch (error) {
      // Get.snackbar(
      //   'Success',
      //   'Failed to send notification to $customerName',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.blue.withValues(alpha: 0.8),
      //   colorText: Colors.white,
      // );
      isNotifying.value = false;
    } finally {
      isNotifying.value = false;
    }
  }

  void viewCustomerDetails(CustomerDue due) {
    Get.to(() => CustomerDueDetailsScreen(dueId: due.id));
  }

  void createDueEntry() {
    Get.toNamed(AppRoutes.addCustomerDue);
  }

  void exportDues() {
    Get.snackbar(
      'Success',
      'Dues exported successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
    );
  }

  // Analytics methods
  final RxInt selectedAnalyticsYear = DateTime.now().year.obs;
  final Rxn<int> selectedAnalyticsMonth = Rxn<int>(null); // null means "All"

  // Method to change selected month filter
  void onAnalyticsMonthChanged(int? month) {
    selectedAnalyticsMonth.value = month;

    // Optional: Show feedback when filtering
    if (month == null) {
      log("Showing all months data");
    } else {
      log("Filtering to month: $month");
    }
  }

  // Method to change analytics year and fetch new data
  void onAnalyticsYearChanged(int year) {
    if (selectedAnalyticsYear.value != year) {
      selectedAnalyticsYear.value = year;
      selectedAnalyticsMonth.value = null; // Reset month filter
      fetchMonthlyAnalytics(); // Fetch new data for selected year
    }
  }

  // Get filtered analytics data based on selected month
  List<MonthlyDuesSummary> getFilteredAnalyticsData() {
    if (selectedAnalyticsMonth.value == null) {
      // Return all data when "All" is selected
      return analyticsData;
    }

    // Filter by selected month
    return analyticsData.where((data) {
      final monthIndex = _getMonthIndexFromName(data.month);
      return monthIndex == selectedAnalyticsMonth.value;
    }).toList();
  }

  // Get chart data for pie chart
  Map<String, double> getFilteredChartData() {
    final filteredData = getFilteredAnalyticsData();
    Map<String, double> chartData = {};

    for (var data in filteredData) {
      chartData[data.monthShort] = data.remaining;
    }

    return chartData;
  }

  // Helper method to get month index from name
  int _getMonthIndexFromName(String monthName) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return months.indexOf(monthName.toUpperCase()) + 1;
  }

  Future<void> fetchMonthlyAnalytics() async {
    try {
      isAnalyticsLoading.value = true;

      Map<String, dynamic> queryParams = {'year': selectedAnalyticsYear.value};

      dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/dues/monthly-summary',
        authToken: true,
        dictParameter: queryParams,
        featureKey: FeatureKeys.DUES.viewMonthlyDuesSummary,
      );

      if (response != null) {
        final analyticsResponse = MonthlyDuesAnalyticsResponse.fromJson(
          response.data,
        );
        if (analyticsResponse.status == "Success") {
          analyticsData.value = analyticsResponse.payload;
          // Reset month filter when new data is loaded
          selectedAnalyticsMonth.value = null;
          log("Monthly analytics loaded successfully");
        } else {
          // If API returns unsuccessful status, set empty data to show zero values
          analyticsData.value = [];
          selectedAnalyticsMonth.value = null;
          log("No analytics data available: ${analyticsResponse.message}");
        }
      } else {
        // If no response, set empty data to show zero values
        analyticsData.value = [];
        selectedAnalyticsMonth.value = null;
        log("No analytics data received from server");
      }
      isAnalyticsLoading.value = false;
    } catch (error) {
      log("❌ Error in fetchMonthlyAnalytics: $error");

      // Set empty data to show zero values instead of error
      analyticsData.value = [];
      selectedAnalyticsMonth.value = null;
      isAnalyticsLoading.value = false;

      // Don't show error snackbar, just log it
      // User will see the UI with zero values
    } finally {
      isAnalyticsLoading.value = false;
    }
  }

  void showAnalyticsModal() {
    Get.bottomSheet(
      CustomerDuesAnalyticsModal(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    fetchMonthlyAnalytics();
  }

  Map<String, double> get collectedData {
    Map<String, double> data = {};
    for (var item in analyticsData) {
      data[item.monthShort] = item.collected;
    }
    return data;
  }

  Map<String, double> get remainingData {
    Map<String, double> data = {};
    for (var item in analyticsData) {
      data[item.monthShort] = item.remaining;
    }
    return data;
  }

  final RxBool isDetailsLoading = false.obs;
  final Rx<CustomerDueDetailsModel?> customerDueDetails =
      Rx<CustomerDueDetailsModel?>(null);
  final RxString detailsErrorMessage = ''.obs;
  final RxBool hasDetailsError = false.obs;

  Future<void> fetchCustomerDueDetails(int dueId) async {
    try {
      isDetailsLoading.value = true;
      hasDetailsError.value = false;
      detailsErrorMessage.value = '';

      log("Fetching customer due details for ID: $dueId");

      final url = '${_config.baseUrl}/api/dues/$dueId';

      dio.Response? response = await _apiService.requestGetForApi(
        url: url,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final customerDueData = CustomerDueDetailsModel.fromJson(response.data);
        customerDueDetails.value = customerDueData;

        log("Customer due details loaded successfully");
        log("Customer: ${customerDueData.customer.name}");
        log("Total Due: ${customerDueData.totalDue}");
        log("Remaining Due: ${customerDueData.remainingDue}");
      } else {
        throw Exception('Failed to load customer due details');
      }
    } catch (error) {
      hasDetailsError.value = true;
      detailsErrorMessage.value = 'Error: $error';
      log("❌ Error in fetchCustomerDueDetails: $error");
    } finally {
      isDetailsLoading.value = false;
    }
  }

  String get retrievalCustomer =>
      retrievalDueController.totalCount.value.toString();
}

class DuesSummaryModel {
  final double totalGiven;
  final double totalCollected;
  final double totalRemaining;
  final double thisMonthCollection;

  DuesSummaryModel({
    required this.totalGiven,
    required this.totalCollected,
    required this.totalRemaining,
    required this.thisMonthCollection,
  });

  static DuesSummaryModel fromDuesList(List<CustomerDue> dues) {
    double totalGiven = 0;
    double totalCollected = 0;
    double totalRemaining = 0;
    double thisMonthCollection = 0;

    for (var due in dues) {
      totalGiven += due.totalDue;
      totalCollected += due.totalPaid;
      totalRemaining += due.remainingDue;

      final now = DateTime.now();
      for (var payment in due.partialPayments) {
        try {
          final paymentDate = DateTime.parse(payment.paidDate);
          if (paymentDate.year == now.year && paymentDate.month == now.month) {
            thisMonthCollection += payment.paidAmount;
          }
        } catch (e) {
          // Skip if date parsing fails
        }
      }
    }

    return DuesSummaryModel(
      totalGiven: totalGiven,
      totalCollected: totalCollected,
      totalRemaining: totalRemaining,
      thisMonthCollection: thisMonthCollection,
    );
  }
}
