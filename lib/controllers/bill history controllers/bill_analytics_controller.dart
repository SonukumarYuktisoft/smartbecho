import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/bill%20history/monthly_purchase_chart_reponse_model.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'dart:developer';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';

class BillAnalyticsController extends GetxController {
  // API service instance
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Loading states
  final RxBool isAnalyticsLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Analytics data
  final RxList<BillAnalyticsModel> analyticsData = <BillAnalyticsModel>[].obs;

  // Analytics year and month selection (matching CustomerDuesController pattern)
  final RxInt selectedAnalyticsYear = DateTime.now().year.obs;
  final Rxn<int> selectedAnalyticsMonth = Rxn<int>(null); // null means "All"

  // Old filter states (kept for backward compatibility)
  final RxString selectedCompany = ''.obs;
  final RxString selectedMonth = ''.obs;
  final RxString selectedYear = ''.obs;
  final RxString timePeriodType = 'Month/Year'.obs;

  // Date controllers for custom date selection
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  // Available filter options
  final RxList<String> availableCompanies =
      <String>[
        'All Companies',
        'Apple',
        'Samsung',
        'Xiaomi',
        'OnePlus',
        'Vivo',
        'Oppo',
        'Realme',
        'Google',
        'Nothing',
      ].obs;

  final RxList<String> availableMonths =
      <String>[
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
      ].obs;

  final RxList<String> availableYears = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFilters();
    fetchBillAnalytics();
  }

  @override
  void onClose() {
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }

  void _initializeFilters() {
    // Initialize years (current year and previous years)
    final currentYear = DateTime.now().year;
    availableYears.addAll([
      for (int i = currentYear; i >= currentYear - 5; i--) i.toString(),
    ]);

    // Set default values
    selectedYear.value = currentYear.toString();
    selectedMonth.value = _getMonthName(DateTime.now().month);
    selectedCompany.value = 'All Companies';
    timePeriodType.value = 'Month/Year';
    selectedAnalyticsYear.value = currentYear;
    selectedAnalyticsMonth.value = null; // Show all months by default
  }

  String _getMonthName(int monthNumber) {
    const months = [
      '',
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
    return months[monthNumber];
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };
    return months[monthName] ?? 1;
  }

  // Analytics methods (matching CustomerDuesController pattern)

  /// Method to change selected month filter
  void onAnalyticsMonthChanged(int? month) {
    selectedAnalyticsMonth.value = month;

    // Optional: Show feedback when filtering
    if (month == null) {
      log("Showing all months data");
    } else {
      log("Filtering to month: $month");
    }
  }

  /// Method to change analytics year and fetch new data
  void onAnalyticsYearChanged(int year) {
    if (selectedAnalyticsYear.value != year) {
      selectedAnalyticsYear.value = year;
      selectedAnalyticsMonth.value = null; // Reset month filter
      fetchBillAnalytics(); // Fetch new data for selected year
    }
  }

  /// Get filtered analytics data based on selected month
  List<BillAnalyticsModel> getFilteredAnalyticsData() {
    if (selectedAnalyticsMonth.value == null) {
      // Return all data when "All" is selected
      return analyticsData;
    }

    // Filter by selected month
    return analyticsData.where((data) {
      final monthIndex = _getMonthIndexFromName(data.month ?? '');
      return monthIndex == selectedAnalyticsMonth.value;
    }).toList();
  }

  /// Helper method to get month index from name
  int _getMonthIndexFromName(String monthName) {
    if (monthName.isEmpty) return 0;
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

  // Date selection methods
  void onStartDateChanged(DateTime date) {
    startDate.value = date;
    startDateController.text = DateFormat('dd/MM/yyyy').format(date);
    if (timePeriodType.value == 'Custom Date') {
      fetchBillAnalytics();
    }
  }

  void onEndDateChanged(DateTime date) {
    endDate.value = date;
    endDateController.text = DateFormat('dd/MM/yyyy').format(date);
    if (timePeriodType.value == 'Custom Date') {
      fetchBillAnalytics();
    }
  }

  void onTimePeriodTypeChanged(String? type) {
    if (type != null) {
      timePeriodType.value = type;

      // Clear custom dates when switching to Month/Year
      if (type == 'Month/Year') {
        startDate.value = null;
        endDate.value = null;
        startDateController.clear();
        endDateController.clear();
      }

      fetchBillAnalytics();
    }
  }

  // Fetch bill analytics from API
  // Replace the fetchBillAnalytics method in your BillAnalyticsController with this:

  Future<void> fetchBillAnalytics() async {
    try {
      isAnalyticsLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Build query parameters - use selectedAnalyticsYear for API call
      Map<String, dynamic> queryParams = {'year': selectedAnalyticsYear.value};

      // Note: Month filtering is done client-side after fetching all months for the year
      // This matches the CustomerDuesController pattern

      // Add company filter if not "All Companies"
      if (selectedCompany.value.isNotEmpty &&
          selectedCompany.value != 'All Companies') {
        queryParams['companyName'] = selectedCompany.value;
      }

      log("Fetching bill analytics with params: $queryParams");

      // API endpoint
      final url = '${_config.baseUrl}/api/purchase-bills/monthly-summary';

      dio.Response? response = await _apiService.requestGetForApi(
        url: url,
        authToken: true,
        dictParameter: queryParams,
        featureKey: FeatureKeys.PURCHASE_BILLS.getPurchaseBillsMonthlySummary,
      );

      if (response != null && response.statusCode == 200) {
        List<dynamic> data = response.data;
        analyticsData.value =
            data.map((item) => BillAnalyticsModel.fromJson(item)).toList();

        log("Bill analytics loaded successfully");
        log("Total records: ${analyticsData.length}");

        // Force update observables
        analyticsData.refresh();
      } else {
        // If no response, set empty data to show zero values
        analyticsData.value = [];
        log("No bill analytics data received from server");
      }
    } catch (error) {
      log("❌ Error in fetchBillAnalytics: $error");

      // Set empty data to show zero values instead of error
      analyticsData.value = [];

      // Don't show error snackbar, just log it
      // User will see the UI with zero values
    } finally {
      isAnalyticsLoading.value = false;
    }
  }

  // Filter methods (backward compatibility)
  void onCompanyChanged(String? company) {
    if (company != null) {
      selectedCompany.value = company;
      fetchBillAnalytics();
    }
  }

  void onMonthChanged(String? month) {
    if (month != null) {
      selectedMonth.value = month;
      // Convert month name to number for analytics month filter
      if (month != 'All') {
        selectedAnalyticsMonth.value = _getMonthNumber(month);
      } else {
        selectedAnalyticsMonth.value = null;
      }
      // Don't fetch here - filtering is done client-side
    }
  }

  void onYearChanged(String? year) {
    if (year != null) {
      selectedYear.value = year;
      selectedAnalyticsYear.value = int.parse(year);
      fetchBillAnalytics();
    }
  }

  void clearFilters() {
    selectedCompany.value = 'All Companies';
    selectedMonth.value = _getMonthName(DateTime.now().month);
    selectedYear.value = DateTime.now().year.toString();
    timePeriodType.value = 'Month/Year';
    startDate.value = null;
    endDate.value = null;
    startDateController.clear();
    endDateController.clear();
    selectedAnalyticsYear.value = DateTime.now().year;
    selectedAnalyticsMonth.value = null;
    fetchBillAnalytics();
  }

  void applyFilters() {
    fetchBillAnalytics();
  }

  // Chart data getters
  Map<String, double> get purchaseData {
    Map<String, double> data = {};
    final filtered = getFilteredAnalyticsData();
    for (var item in filtered) {
      String key = item.month ?? item.monthShort ?? 'Unknown';
      data[key] = item.totalPurchase ?? 0.0;
    }
    return data;
  }

  Map<String, double> get paidData {
    Map<String, double> data = {};
    final filtered = getFilteredAnalyticsData();
    for (var item in filtered) {
      String key = item.month ?? item.monthShort ?? 'Unknown';
      data[key] = item.totalPaid ?? 0.0;
    }
    return data;
  }

  // Summary calculations (based on filtered data)
  double get totalPurchaseAmount {
    final filtered = getFilteredAnalyticsData();
    double total = filtered.fold(
      0.0,
      (sum, item) => sum + (item.totalPurchase ?? 0.0),
    );
    log("Total purchase amount: $total");
    return total;
  }

  double get totalPaidAmount {
    final filtered = getFilteredAnalyticsData();
    double total = filtered.fold(
      0.0,
      (sum, item) => sum + (item.totalPaid ?? 0.0),
    );
    log("Total paid amount: $total");
    return total;
  }

  double get totalOutstanding {
    double outstanding = totalPurchaseAmount - totalPaidAmount;
    log("Total outstanding: $outstanding");
    return outstanding;
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchBillAnalytics();
  }
}
