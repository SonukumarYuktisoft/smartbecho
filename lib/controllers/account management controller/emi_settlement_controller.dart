import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/models/account%20management%20models/emi%20settlement/emi_settlement_chart_model.dart';
import 'package:smartbecho/models/account%20management%20models/emi%20settlement/emi_settlement_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/utils/Dialogs/app_successdialog.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';

class EmiSettlementController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Form controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController confirmedByController = TextEditingController();

  // Date filter controllers
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  var startDateText = ''.obs;
  var endDateText = ''.obs;
  // Form state
  var isFormLoading = false.obs;

  // Observable variables
  var isLoading = false.obs;
  var settlements = <EmiSettlement>[].obs;
  var filteredSettlements = <EmiSettlement>[].obs;
  var currentPage = 0.obs;
  var totalPages = 0.obs;
  var totalElements = 0.obs;
  var hasMoreData = true.obs;
  var isFilterExpanded = false.obs;

  // Chart data
  var isChartLoading = false.obs;
  final RxList<MonthlyEmiData> chartData = <MonthlyEmiData>[].obs;
  var chartYear = DateTime.now().year.obs;
  final List<String> years = List.generate(5, (index) => (DateTime.now().year - index).toString());
  // Filter variables
  var searchQuery = ''.obs;
  var selectedCompany = 'All'.obs;
  var selectedConfirmedBy = 'All'.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  // Date filter type and custom date range
  var dateFilterType = 'Month'.obs; // 'Month', 'Year', or 'Custom'
  var customStartDate = Rx<DateTime?>(null);
  var customEndDate = Rx<DateTime?>(null);

  // Available filter options
  var companyOptions = <String>['All'].obs;
  var confirmedByOptions = <String>['All'].obs;
  var isCompanyLoading = false.obs;

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final int pageSize = 10;

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

  @override
  void onInit() {
    super.onInit();
    loadSettlements(refresh: true);
    loadCompanyDropdownData(); // 🆕 Load company options on init
    dateController.text = DateTime.now().toIso8601String().split('T')[0];

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    dateController.dispose();
    companyNameController.dispose();
    amountController.dispose();
    confirmedByController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  // Form validation methods
  String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount';
    }
    return null;
  }

  // Date picker for form
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateController.text = picked.toIso8601String().split('T')[0];
    }
  }

  // Custom date selection methods for filters
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
      startDateController.text = formatDate;
      startDateText.value = startDateController.text;
      loadSettlements(refresh: true);
    }
  }

  Future<void> selectCustomEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: customEndDate.value ?? DateTime.now(),
      firstDate: customStartDate.value ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      customEndDate.value = picked;
   final String formatDate = DateFormat('dd/MM/yyyy').format(picked);
      startDateController.text = formatDate;
      endDateText.value = startDateController.text;
      loadSettlements(refresh: true);
    }
  }

  void onDateFilterTypeChanged(String type) {
    dateFilterType.value = type;

    // Clear custom dates when switching away from Custom
    if (type != 'Custom') {
      customStartDate.value = null;
      customEndDate.value = null;
      startDateController.clear();
      endDateController.clear();
    }

    loadSettlements(refresh: true);
  }

  // Save EMI settlement
  Future<void> saveEmiSettlement() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isFormLoading.value = true;

      final requestBody = {
        'companyName': companyNameController.text,
        'amount': double.parse(amountController.text),
        'confirmedBy': confirmedByController.text,
       'date': dateController.text,
      };

      final response = await _apiService.requestPostForApi(
        url: '${_config.baseUrl}/api/emi-settlements',
        dictParameter: requestBody,
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 201) {
        log('EMI settlement recorded successfully!');
        clearForm();

        // Refresh data and company options
        await loadCompanyDropdownData();
        await loadSettlements(refresh: true);

        await gotoSellScreen();
      } else {
        String errorMessage = 'Failed to record EMI settlement';
        if (response?.data != null && response!.data['message'] != null) {
          errorMessage = response.data['message'];
        }
        log('Failed to record EMI settlement $errorMessage');
      }
    } catch (e) {
      print('Error saving EMI settlement: $e');
    } finally {
      isFormLoading.value = false;
    }
  }

  Future<void> gotoSellScreen() async {
    appSuccessDialog(
      title: 'successful'.toUpperCase(),
      description: 'EMI settlement successfully',
      onPressed: () {
        Get.back();
        Get.back();
      },
    );
  }

  // Clear form
  void clearForm() {
    dateController.text = DateTime.now().toIso8601String().split('T')[0];
    companyNameController.clear();
    amountController.clear();
    confirmedByController.clear();
  }

  // Reset form
  void resetForm() {
    clearForm();
    log('Reset Form has been reset');
  }

  // 🆕 Load company dropdown data from API
  Future<void> loadCompanyDropdownData() async {
    try {
      isCompanyLoading.value = true;

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/emi-settlements/dropdowns/company-names',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        // Parse the response
        final List<String> companies = List<String>.from(
          response.data['payload'] ?? [],
        );

        // Add 'All' option at the beginning
        companyOptions.value = ['All', ...companies];

        log('✅ Company options loaded: ${companyOptions.length}');
      } else {
        log('Failed to load company options');
        companyOptions.value = ['All'];
      }
    } catch (e) {
      log('Error loading company dropdown data: $e');
      companyOptions.value = ['All'];
    } finally {
      isCompanyLoading.value = false;
    }
  }

  Future<void> loadSettlements({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 0;
        settlements.clear();
        hasMoreData.value = true;
      }

      if (!hasMoreData.value) return;

      isLoading.value = true;

      final query = <String, String>{
        'page': currentPage.value.toString(),
        'size': pageSize.toString(),
        'sortBy': 'id',
        'sortDir': 'desc',
      };

      // Add date filters based on type
      if (dateFilterType.value == 'Custom') {
        // Custom date range - API uses startDate and endDate
        if (customStartDate.value != null) {
          query['startDate'] =
              customStartDate.value!.toIso8601String().split('T')[0];
        }
        if (customEndDate.value != null) {
          query['endDate'] =
              customEndDate.value!.toIso8601String().split('T')[0];
        }
      } else if (dateFilterType.value == 'Year') {
        // Year filter only
        query['year'] = selectedYear.value.toString();
      } else {
        // Month filter (default)
        query['year'] = selectedYear.value.toString();
        query['month'] = selectedMonth.value.toString();
      }

      // Add company filter if selected
      if (selectedCompany.value != 'All') {
        query['companyName'] = selectedCompany.value;
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/emi-settlements',
        dictParameter: query,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final settlementsResponse = EmiSettlementsResponse.fromJson(
          response.data,
        );

        if (refresh) {
          settlements.value = settlementsResponse.content;
        } else {
          settlements.addAll(settlementsResponse.content);
        }

        totalPages.value = settlementsResponse.totalPages;
        totalElements.value = settlementsResponse.totalElements;
        hasMoreData.value = !settlementsResponse.last;

        _updateFilterOptions();
        _applyFilters();
      } else {
        log('Failed to load EMI settlements');
      }
    } catch (e) {
      log('An error occurred while loading data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Load chart
  Future<void> loadChartData({int? year}) async {
    try {
      isChartLoading.value = true;
      final targetYear = year ?? chartYear.value;
      final query = {'year': targetYear.toString()};

      // Add company filter if selected
      if (selectedCompany.value != 'All') {
        query['companyName'] = selectedCompany.value;
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/emi-settlements/monthly-summary/chart',
        dictParameter: query,
        authToken: true,
        featureKey: FeatureKeys.EMI.getEmiSettlementsMonthlySummary
      );

      if (response != null && response.statusCode == 200) {
        final chartResponse = EmiSettlementChartResponse.fromJson(
          response.data,
        );

        chartData.clear();
        chartData.addAll(chartResponse.payload);

        chartYear.value = targetYear;

        log('✅ Chart data loaded successfully');
      } else {
        log('emi-settlements Failed to load chart data');
      }
    } catch (e) {
      log('Error loading chart data: $e');
    } finally {
      isChartLoading.value = false;
    }
  }

  void onChartYearChanged(int year) {
    if (year != chartYear.value) {
      loadChartData(year: year);
    }
  }

  bool get hasChartData =>
      chartData.isNotEmpty && chartData.any((item) => item.amount > 0);

  void _updateFilterOptions() {
    final companySet =
        settlements.map((settlement) => settlement.companyName).toSet();
    // Note: companyOptions is already loaded from dropdown API
    // Only update from settlements if needed for additional options
    if (companySet.isNotEmpty) {
      for (var company in companySet) {
        if (!companyOptions.contains(company)) {
          companyOptions.add(company);
        }
      }
    }

    final confirmedBySet =
        settlements.map((settlement) => settlement.confirmedBy).toSet();
    confirmedByOptions.value = ['All', ...confirmedBySet.toList()..sort()];
  }

  void _applyFilters() {
    var filtered =
        settlements.where((settlement) {
          // Search filter
          if (searchQuery.value.isNotEmpty) {
            final query = searchQuery.value.toLowerCase();
            if (!settlement.companyName.toLowerCase().contains(query) &&
                !settlement.confirmedBy.toLowerCase().contains(query) &&
                !settlement.shopId.toLowerCase().contains(query)) {
              return false;
            }
          }

          // Company filter
          if (selectedCompany.value != 'All' &&
              settlement.companyName != selectedCompany.value) {
            return false;
          }

          // Confirmed by filter
          if (selectedConfirmedBy.value != 'All' &&
              settlement.confirmedBy != selectedConfirmedBy.value) {
            return false;
          }

          return true;
        }).toList();

    filteredSettlements.value = filtered;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void onCompanyChanged(String? company) {
    if (company != null) {
      selectedCompany.value = company;
      // Reload chart data with company filter
      loadChartData();
      // Reload settlements with company filter
      loadSettlements(refresh: true);
    }
  }

  void onConfirmedByChanged(String? confirmedBy) {
    if (confirmedBy != null) {
      selectedConfirmedBy.value = confirmedBy;
      _applyFilters();
    }
  }

  void onMonthChanged(int? month) {
    if (month != null) {
      selectedMonth.value = month;
      loadSettlements(refresh: true);
    }
  }

  void onYearChanged(int? year) {
    if (year != null) {
      selectedYear.value = year;
      loadSettlements(refresh: true);
    }
  }

  void clearCharFilters() {
    chartYear.value = DateTime.now().year;
    selectedCompany.value = 'All';
    loadChartData();
  }


  bool activeCharFilters () {
    return chartYear.value != DateTime.now().year||
    selectedCompany.value != 'All';
    
  }
  void clearFilters() {
    searchQuery.value = '';
    selectedCompany.value = 'All';
    selectedConfirmedBy.value = 'All';
    selectedMonth.value = DateTime.now().month;
    selectedYear.value = DateTime.now().year;

    dateFilterType.value = 'Month';
    customStartDate.value = null;
    customEndDate.value = null;
    searchController.clear();
    startDateController.clear();
    endDateController.clear();
     startDateText.value ='';
    endDateText.value='';
    loadSettlements(refresh: true);
    loadChartData();
  }

  void loadNextPage() {
    if (hasMoreData.value && !isLoading.value) {
      currentPage.value++;
      loadSettlements();
    }
  }

  void refreshData() {
    loadCompanyDropdownData();
    loadSettlements(refresh: true);
    loadChartData();
  }

  String getFilterSummary() {
    List<String> activeFilters = [];

    if (searchQuery.value.isNotEmpty) {
      activeFilters.add('Search: "${searchQuery.value}"');
    }
    if (selectedCompany.value != 'All') {
      activeFilters.add('Company: ${selectedCompany.value}');
    }
    if (selectedConfirmedBy.value != 'All') {
      activeFilters.add('Confirmed By: ${selectedConfirmedBy.value}');
    }

    // Add date filter info
    if (dateFilterType.value == 'Custom') {
      if (customStartDate.value != null && customEndDate.value != null) {
        activeFilters.add(
          '${startDateController.text} to ${endDateController.text}',
        );
      }
    } else if (dateFilterType.value == 'Year') {
      activeFilters.add('Year: ${selectedYear.value}');
    } else {
      final monthName = months[selectedMonth.value - 1];
      activeFilters.add('$monthName ${selectedYear.value}');
    }

    if (activeFilters.isEmpty) {
      return '${filteredSettlements.length} settlements found';
    }

    return '${activeFilters.join(' • ')} • ${filteredSettlements.length} results';
  }

  bool get hasActiveFilters {
    return searchQuery.value.isNotEmpty ||
        selectedCompany.value != 'All' ||
        selectedConfirmedBy.value != 'All' ||
        dateFilterType.value == 'Custom' ||
        (dateFilterType.value == 'Year' &&
            selectedYear.value != DateTime.now().year) ||
        (dateFilterType.value == 'Month' &&
            (selectedMonth.value != DateTime.now().month ||
                selectedYear.value != DateTime.now().year));
  }

  Color getCompanyColor(String company) {
    final colors = {
      'nokia': const Color(0xFF3B82F6),
      'lava': const Color(0xFF10B981),
      'samsung': const Color(0xFF8B5CF6),
      'hdfc': const Color(0xFFF59E0B),
      'icici': const Color(0xFFEF4444),
      'sbi': const Color(0xFF06B6D4),
      'axis': const Color(0xFFF97316),
      'amazin': const Color(0xFFEC4899),
      'dmi': const Color(0xFF14B8A6),
    };

    return colors[company.toLowerCase()] ?? const Color(0xFF6366F1);
  }

  Color getConfirmedByColor(String confirmedBy) {
    final colors = {
      'nishant': const Color(0xFF10B981),
      'raja bhiya': const Color(0xFF3B82F6),
      'jane smith': const Color(0xFF8B5CF6),
      'john doe': const Color(0xFFF59E0B),
      'praveen': const Color(0xFFEF4444),
      'ranmu': const Color(0xFF06B6D4),
    };

    return colors[confirmedBy.toLowerCase()] ?? const Color(0xFF6B7280);
  }

  IconData getCompanyIcon(String company) {
    final icons = {
      'nokia': Icons.phone_android,
      'lava': Icons.phone_android,
      'samsung': Icons.phone_android,
      'hdfc': Icons.account_balance,
      'icici': Icons.account_balance,
      'sbi': Icons.account_balance,
      'axis': Icons.account_balance,
      'amazin': Icons.shopping_bag,
      'dmi': Icons.business,
    };

    return icons[company.toLowerCase()] ?? Icons.business;
  }
}
