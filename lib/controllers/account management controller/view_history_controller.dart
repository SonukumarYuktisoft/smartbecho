import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/models/account%20management%20models/financial_year_summary_model.dart';
import 'package:smartbecho/models/account%20management%20models/view%20history/transactionList_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/utils/helper/date_formatter_helper.dart';
import 'package:smartbecho/utils/helper/date_picker_helper.dart';

class ViewHistoryController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Observable variables for financial data
  var isLoadingFinancialData = false.obs;
  var selectedYear = DateTime.now().year.obs;
  var financialData = <FinancialSummaryModel>[].obs;
  var availableYears = <int>[].obs;
  var selectedAnalyticsTab = 'monthly'.obs;

  // Observable variables for transactions
  var isLoadingTransactions = false.obs;
  var transactionList = <Transaction>[].obs;
  var currentPage = 0.obs;
  var totalPages = 0.obs;
  var totalElements = 0.obs;
  var hasMoreData = true.obs;
  final int pageSize = 20;

  // Filter variables
  var dateFilterType = 'Month'.obs;
  var customStartDate = Rx<DateTime?>(null);

  var selectedTransactionYear = DateTime.now().year.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedTransactionType = 'ALL'.obs;
  var customEndDate = Rx<DateTime?>(null);
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  var startDateText = ''.obs;
  var endDateText = ''.obs;
  // Scroll controller
  final ScrollController scrollController = ScrollController();

  // Constants
  final List<String> months = [
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

  String get monthDisplayText {
    return months[selectedMonth.value - 1];
  }

  final List<String> years = List.generate(5, (index) {
    final year = DateTime.now().year - index;
    return year.toString();
  });

  final List<String> transactionTypes = ["ALL", "CREDIT", "DEBIT"];

  @override
  void onInit() {
    super.onInit();
    _initializeYears();
    loadFinancialSummary();
    loadTransactionList();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _initializeYears() {
    final currentYear = DateTime.now().year;
    // Add years from 2020 to current year + 1
    for (int year = 2020; year <= currentYear + 1; year++) {
      availableYears.add(year);
    }
  }

  // Financial Summary Methods
  Future<void> loadFinancialSummary() async {
    try {
      isLoadingFinancialData.value = true;
      final query = {'year': selectedYear.value.toString()};

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/commissions/financial-summary',
        dictParameter: query,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final parsed = FinancialSummaryResponse.fromJson(response.data);
        financialData.value = parsed.payload;
        log(
          'Financial summary loaded successfully: ${financialData.length} items',
        );
      } else {
        log('Failed to load financial summary: ${response?.statusCode}');
        financialData.clear();
      }
    } catch (e) {
      log('Error loading financial summary: ${e.toString()}');
      financialData.clear();
      // Optionally show error message to user
      Get.snackbar(
        'Error',
        'Failed to load analytics data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingFinancialData.value = false;
    }
  }

  void onYearChanged(int year) {
    selectedYear.value = year;
    loadFinancialSummary();
  }

  void clearFinancialSummary() {
    selectedYear.value = DateTime.now().year;
    loadFinancialSummary();
  }

  bool activeFinancialSummary() {
    return selectedYear.value != DateTime.now().year;
  }

  void onAnalyticsTabChanged(String tabId) {
    selectedAnalyticsTab.value = tabId;
  }

  void refreshData() {
    loadFinancialSummary();
  }

  // Transaction List Methods
  Future<void> loadTransactionList({bool refresh = false}) async {
    try {
      // Prevent multiple simultaneous requests
      if (isLoadingTransactions.value && !refresh) {
        log('Already loading transactions, skipping...');
        return;
      }

      if (refresh) {
        currentPage.value = 0;
        transactionList.clear();
        hasMoreData.value = true;
      }

      if (!hasMoreData.value && !refresh) {
        log('No more data to load');
        return;
      }

      isLoadingTransactions.value = true;

      final query = <String, String>{
        'page': currentPage.value.toString(),
        'size': pageSize.toString(),
        'sortDir': 'desc',
        // 'year': selectedTransactionYear.value.toString(),
        // 'month': selectedMonth.value.toString(),
      };

      if (selectedTransactionType.value != "ALL") {
        query['transactionType'] = selectedTransactionType.value;
      }
      // Add date filters based on type
      if (dateFilterType.value == 'Custom') {
        // Custom date range
        if (customStartDate.value != null) {
          query['start'] =
              customStartDate.value!.toIso8601String().split('T')[0];
        }
        if (customEndDate.value != null) {
          query['end'] = customEndDate.value!.toIso8601String().split('T')[0];
        }
      } else if (dateFilterType.value == 'Year') {
        // Year filter only
        query['year'] = selectedTransactionYear.value.toString();
      } else {
        // Month filter (default)
        query['year'] = selectedTransactionYear.value.toString();
        query['month'] = selectedMonth.value.toString();
      }
      log('Loading transactions with params: $query');

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/ledger/filter',
        dictParameter: query,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final parsed = TransactionListModel.fromJson(response.data);
        final sortedTransactions = parsed.payload.content;
        sortedTransactions.sort((a, b) {
          DateTime dateA = DateTime.parse(a.date);
          DateTime dateB = DateTime.parse(b.date);
          return dateB.compareTo(dateA);
        });

        if (refresh) {
          transactionList.value = sortedTransactions;
        } else {
          transactionList.addAll(sortedTransactions);
        }
        totalPages.value = parsed.payload.totalPages;
        totalElements.value = parsed.payload.totalElements;
        hasMoreData.value = !parsed.payload.last;

        log('Transactions loaded: ${parsed.payload.content.length} items');
        log(
          'Current page: ${currentPage.value}, Total pages: ${totalPages.value}',
        );
        log('Has more data: ${hasMoreData.value}');
      } else {
        log('Failed to load transactions: ${response?.statusCode}');
        if (refresh) {
          transactionList.clear();
        }
        hasMoreData.value = false;
      }
    } catch (e) {
      log('Error loading transactions: ${e.toString()}');
      if (refresh) {
        transactionList.clear();
      }
      hasMoreData.value = false;

      // Show error message to user
      Get.snackbar(
        'Error',
        'Failed to load transactions',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingTransactions.value = false;
    }
  }

  void loadNextPage() {
    if (!isLoadingTransactions.value && hasMoreData.value) {
      currentPage.value++;
      log('Loading next page: ${currentPage.value}');
      loadTransactionList();
    } else {
      log(
        'Cannot load next page - loading: ${isLoadingTransactions.value}, hasMore: ${hasMoreData.value}',
      );
    }
  }

  void refreshTransactionListData() {
    log('Refreshing transaction list...');
    loadTransactionList(refresh: true);
  }

  // Filter Methods

  void onDateFilterTypeChanged(String type) {
    dateFilterType.value = type;

    // Clear custom dates when switching away from Custom
    if (type != 'Custom') {
      customStartDate.value = null;
      customEndDate.value = null;
      startDateController.clear();
      endDateController.clear();
    }

    applyFilters();
  }

  // Custom date selection methods
  Future<void> selectCustomStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: customStartDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      customStartDate.value = picked;
      final String formatDate = DateFormat('dd/MM/yyyy').format(picked);
      log(name: 'start date log', '$formatDate');
      startDateController.text = formatDate;
      startDateText.value = startDateController.text;
      applyFilters();
    }
  }

  Future<void> selectCustomEndDate(BuildContext context) async {
    final DateTime? picked = await DatePickerHelper.pickDate(
      context: context,
      initialDate: customEndDate.value ?? DateTime.now(),
      firstDate: customStartDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      customEndDate.value = picked;
      final String formatDate = DateFormatterHelper.format(picked);

      startDateController.text = formatDate;
      endDateText.value = startDateController.text;
      applyFilters();
    }
  }

  void onMonthChanged(int month) {
    selectedMonth.value = month;
    log('Month changed to: $month');
  }

  void onTransactionTypeChanged(String type) {
    selectedTransactionType.value = type;
    log('Transaction type changed to: $type');
  }

  void onChangedYear(String year) {
    selectedTransactionYear.value = int.parse(year);
    log('Year changed to: $year');
  }

  void clearFilters() {
    log('Clearing all filters...');
    selectedTransactionType.value = "ALL";
    selectedMonth.value = DateTime.now().month;
    selectedTransactionYear.value = DateTime.now().year;
    dateFilterType.value = 'Month';
    customStartDate.value = null;
    customEndDate.value = null;
    // searchController.clear();
    startDateController.clear();
    endDateController.clear();
    startDateText.value = '';
    endDateText.value = '';

    loadTransactionList(refresh: true);
  }

  void applyFilters() {
    log('Applying filters...');
    log('Year: ${selectedTransactionYear.value}');
    log('Month: ${selectedMonth.value}');
    log('Type: ${selectedTransactionType.value}');
    loadTransactionList(refresh: true);
  }

  // Combined refresh method
  Future<void> refreshAllData() async {
    log('Refreshing all data...');
    await Future.wait([
      loadFinancialSummary(),
      loadTransactionList(refresh: true),
    ]);
  }

  // Formatting and calculation methods
  String formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  double getMaxValue() {
    if (financialData.isEmpty) {
      return 100.0; // Return default value instead of 0
    }

    double maxBills = financialData
        .map((e) => e.totalBillsPaid)
        .reduce((a, b) => a > b ? a : b);
    double maxSales = financialData
        .map((e) => e.totalSalesAmount)
        .reduce((a, b) => a > b ? a : b);
    double maxCommissions = financialData
        .map((e) => e.totalCommissions)
        .reduce((a, b) => a > b ? a : b);

    double maxValue = [
      maxBills,
      maxSales,
      maxCommissions,
    ].reduce((a, b) => a > b ? a : b);

    // Return a minimum value if all data is zero to prevent division by zero
    return maxValue > 0 ? maxValue : 100.0;
  }

  double getHorizontalInterval() {
    double maxValue = getMaxValue();
    return maxValue / 5;
  }

  // Deprecated - kept for backward compatibility
  @Deprecated('Use isLoadingFinancialData or isLoadingTransactions instead')
  var isLoading = false.obs;
}
