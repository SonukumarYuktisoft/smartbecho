import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';
import 'package:smartbecho/models/account%20management%20models/commission_received_model.dart';
import 'package:smartbecho/services/api_error_handler.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:smartbecho/utils/Dialogs/app_successdialog.dart';
import 'package:smartbecho/utils/helper/date_formatter_helper.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';

class CommissionReceivedController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Form controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController confirmedByController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Date filter controllers
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  var startDateText = ''.obs;
  var endDateText = ''.obs;
  // Predefined received mode options
  final List<String> receivedModeFormOptions = [
    "CASH",
    "BANK",
    "UPI",
    "CREDIT_CARD",
    "DEBIT_CARD",
    "CHEQUE",
    "OTHERS",
    "GIVEN_SALE_DUES",
    "EMI_PENDING",
  ];

  // Form state
  var isFormLoading = false.obs;
  var selectedReceivedModeForm = 'CASH'.obs;
  var selectedFile = Rxn<File>();

  // Observable variables
  var isLoading = false.obs;
  var commissions = <Commission>[].obs;
  var filteredCommissions = <Commission>[].obs;
  var currentPage = 0.obs;
  var totalPages = 0.obs;
  var totalElements = 0.obs;
  var hasMoreData = true.obs;
  var isFilterExpanded = false.obs;

  // Filter variables
  var searchQuery = ''.obs;
  var selectedCompany = 'All'.obs;
  var selectedConfirmedBy = 'All'.obs;
  var selectedReceivedMode = 'All'.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  // Date filter type and custom date range
  var dateFilterType = 'Month'.obs; // 'Month', 'Year', or 'Custom'
  var customStartDate = Rx<DateTime?>(null);
  var customEndDate = Rx<DateTime?>(null);

  // Available filter options
  var companyOptions = <String>['All'].obs;
  var confirmedByOptions = <String>['All'].obs;
  var receivedModeOptions = <String>['All'].obs;

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

  // Analytics variables
  var monthlyCommissionChartData = <Map<String, dynamic>>[].obs;
  var selectedMonthlyCommissionCompany = 'All'.obs;
  var selectedMonthlyCommissionMonth = DateTime.now().month.obs;
  var selectedMonthlyCommissionYear = DateTime.now().year.obs;
  var isLoadingMonthlyCommission = false.obs;

  var companyWiseCommissionChartData = <Map<String, dynamic>>[].obs;
  var selectedWiseCommissionCompany = 'All'.obs;
  var selectedWiseCommissionMonth = DateTime.now().month.obs;
  var selectedWiseCommissionYear = DateTime.now().year.obs;
  var isLoadingWiseCommission = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCommissions(refresh: true);
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
    companyController.dispose();
    amountController.dispose();
    confirmedByController.dispose();
    descriptionController.dispose();
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

  String? validateReceivedMode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a company mode';
    }
    return null;
  }

  String getReceivedModeDisplayName(String mode) {
    switch (mode) {
      case 'CASH':
        return 'Cash';
      case 'BANK':
        return 'Bank Transfer';
      case 'UPI':
        return 'UPI';
      case 'CREDIT_CARD':
        return 'Credit Card';
      case 'DEBIT_CARD':
        return 'Debit Card';
      case 'CHEQUE':
        return 'Cheque';
      case 'OTHERS':
        return 'Others';
      case 'GIVEN_SALE_DUES':
        return 'Given Sale Dues';
      case 'EMI_PENDING':
        return 'EMI Pending';
      default:
        return mode;
    }
  }

  void setReceivedModeForm(String? mode) {
    if (mode != null) {
      selectedReceivedModeForm.value = mode;
    }
  }

  // Date picker for form
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF10B981),
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
      loadCommissions(refresh: true);
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
      loadCommissions(refresh: true);
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

    loadCommissions(refresh: true);
  }

  // File picker
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        selectedFile.value = File(result.files.single.path!);
        ToastHelper.success(
          message: 'File selected successfully: ${result.files.single.name}',
        );
      }
    } catch (e) {
      ToastHelper.error(message: 'Failed to pick file: ${e.toString()}');
    }
  }

  // Save commission
  Future<void> saveCommission() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isFormLoading.value = true;

      final formData = dio.FormData();
      formData.fields.add(MapEntry('company', companyController.text));
      formData.fields.add(MapEntry('amount', amountController.text));
      formData.fields.add(
        MapEntry('receivedMode', selectedReceivedModeForm.value),
      );
      formData.fields.add(MapEntry('confirmedBy', confirmedByController.text));
      formData.fields.add(MapEntry('description', descriptionController.text));
      formData.fields.add(
        MapEntry(
          'date',
          DateTime.parse(dateController.text).toUtc().toIso8601String(),
        ),
      );

      if (selectedFile.value != null) {
        formData.files.add(
          MapEntry(
            'file',
            await dio.MultipartFile.fromFile(
              selectedFile.value!.path,
              filename: selectedFile.value!.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _apiService.requestMultipartApi(
        url: '${_config.baseUrl}/api/commissions',
        formData: formData,
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 201) {
        clearForm();

        await loadCommissions(refresh: true);
        await gotoSellScreen();
      } else {
        Map<String, dynamic> errorMessage = ApiErrorHandler.handleResponse(
          response,
        );
        if (response?.data != null && response!.data['message'] != null) {
          errorMessage = response.data['message'];
        }
        log('Failed to record commission $errorMessage');
      }
    } catch (e) {
      print('Error saving commission: $e');
      log('Failed to record commission: ${e.toString()}');
    } finally {
      isFormLoading.value = false;
    }
  }

  Future<void> gotoSellScreen() async {
    appSuccessDialog(
      title: 'successful'.toUpperCase(),

      description: 'commission successfully',
      onPressed: () {
        Get.back();
        Get.back();
      },
    );
  }

  // Clear form
  void clearForm() {
    dateController.text = DateTime.now().toIso8601String().split('T')[0];
    companyController.clear();
    amountController.clear();
    confirmedByController.clear();
    descriptionController.clear();
    selectedReceivedModeForm.value = 'CASH';
    selectedFile.value = null;
  }

  // Reset form
  void resetForm() {
    clearForm();
    log('Reset Form has been reset');
  }

  Future<void> loadCommissions({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 0;
        commissions.clear();
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
        query['year'] = selectedYear.value.toString();
      } else {
        // Month filter (default)
        query['year'] = selectedYear.value.toString();
        query['month'] = selectedMonth.value.toString();
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/commissions',
        dictParameter: query,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final commissionsResponse = CommissionsResponse.fromJson(response.data);

        if (refresh) {
          commissions.value = commissionsResponse.content;
        } else {
          commissions.addAll(commissionsResponse.content);
        }

        totalPages.value = commissionsResponse.totalPages;
        totalElements.value = commissionsResponse.totalElements;
        hasMoreData.value = !commissionsResponse.last;

        _updateFilterOptions();
        _applyFilters();
      } else {
        log('Failed to load commissions');
      }
    } catch (e) {
      log('An error occurred while loading data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateFilterOptions() {
    final companySet =
        commissions.map((commission) => commission.company).toSet();
    companyOptions.value = ['All', ...companySet.toList()..sort()];

    final confirmedBySet =
        commissions.map((commission) => commission.confirmedBy).toSet();
    confirmedByOptions.value = ['All', ...confirmedBySet.toList()..sort()];

    final receivedModeSet =
        commissions.map((commission) => commission.receivedMode).toSet();
    receivedModeOptions.value = ['All', ...receivedModeSet.toList()..sort()];
  }

  void _applyFilters() {
    var filtered =
        commissions.where((commission) {
          // Search filter
          if (searchQuery.value.isNotEmpty) {
            final query = searchQuery.value.toLowerCase();
            if (!commission.company.toLowerCase().contains(query) &&
                !commission.confirmedBy.toLowerCase().contains(query) &&
                !commission.description.toLowerCase().contains(query) &&
                !commission.receivedMode.toLowerCase().contains(query)) {
              return false;
            }
          }

          // Company filter
          if (selectedCompany.value != 'All' &&
              commission.company != selectedCompany.value) {
            return false;
          }

          // Confirmed by filter
          if (selectedConfirmedBy.value != 'All' &&
              commission.confirmedBy != selectedConfirmedBy.value) {
            return false;
          }

          // Received mode filter
          if (selectedReceivedMode.value != 'All' &&
              commission.receivedMode != selectedReceivedMode.value) {
            return false;
          }

          return true;
        }).toList();

    filteredCommissions.value = filtered;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void onCompanyChanged(String? company) {
    if (company != null) {
      selectedCompany.value = company;
      _applyFilters();
    }
  }

  void onConfirmedByChanged(String? confirmedBy) {
    if (confirmedBy != null) {
      selectedConfirmedBy.value = confirmedBy;
      _applyFilters();
    }
  }

  void onReceivedModeChanged(String? receivedMode) {
    if (receivedMode != null) {
      selectedReceivedMode.value = receivedMode;
      _applyFilters();
    }
  }

  void onMonthChanged(int? month) {
    if (month != null) {
      selectedMonth.value = month;
      loadCommissions(refresh: true);
    }
  }

  void onYearChanged(int? year) {
    if (year != null) {
      selectedYear.value = year;
      loadCommissions(refresh: true);
    }
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCompany.value = 'All';
    selectedConfirmedBy.value = 'All';
    selectedReceivedMode.value = 'All';
    selectedMonth.value = DateTime.now().month;
    selectedYear.value = DateTime.now().year;
    dateFilterType.value = 'Month';
    customStartDate.value = null;
    customEndDate.value = null;
    searchController.clear();
    startDateController.clear();
    startDateText.value = '';
    endDateText.value = '';
    endDateController.clear();

    loadCommissions(refresh: true);
  }

  void loadNextPage() {
    if (hasMoreData.value && !isLoading.value) {
      currentPage.value++;
      loadCommissions();
    }
  }

  void refreshData() {
    loadCommissions(refresh: true);
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
    if (selectedReceivedMode.value != 'All') {
      activeFilters.add('company: ${selectedReceivedMode.value}');
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
      return '${filteredCommissions.length} commissions found';
    }

    return '${activeFilters.join(' • ')} • ${filteredCommissions.length} results';
  }

  bool get hasActiveFilters {
    return searchQuery.value.isNotEmpty ||
        selectedCompany.value != 'All' ||
        selectedConfirmedBy.value != 'All' ||
        selectedReceivedMode.value != 'All' ||
        dateFilterType.value == 'Custom' ||
        (dateFilterType.value == 'Year' &&
            selectedYear.value != DateTime.now().year) ||
        (dateFilterType.value == 'Month' &&
            (selectedMonth.value != DateTime.now().month ||
                selectedYear.value != DateTime.now().year));
  }

  // String get monthDisplayText {
  //   return months[selectedMonth.value - 1];
  // }

  Color getCompanyColor(String company) {
    final colors = {
      'nokia': const Color(0xFF3B82F6),
      'vivo': const Color(0xFF10B981),
      'samsung': const Color(0xFF8B5CF6),
      'pepsie': const Color(0xFFF59E0B),
      'oppo': const Color(0xFFEF4444),
      'apple': const Color(0xFF06B6D4),
      'xiaomi': const Color(0xFFF97316),
      'realme': const Color(0xFF10B981),
    };

    return colors[company.toLowerCase()] ?? const Color(0xFF6366F1);
  }

  Color getConfirmedByColor(String confirmedBy) {
    final colors = {
      'nishant': const Color(0xFF10B981),
      'robert johnson': const Color(0xFF3B82F6),
      'jane smith': const Color(0xFF8B5CF6),
      'john doe': const Color(0xFFF59E0B),
      'praveen': const Color(0xFFEF4444),
      'ranmu': const Color(0xFF06B6D4),
      'shahzad': const Color(0xFF8B5CF6),
    };

    return colors[confirmedBy.toLowerCase()] ?? const Color(0xFF6B7280);
  }

  Color getReceivedModeColor(String receivedMode) {
    final colors = {
      'CASH': const Color(0xFF10B981),
      'cash': const Color(0xFF10B981),
      'BANK': const Color(0xFF3B82F6),
      'neft': const Color(0xFF3B82F6),
      'UPI': const Color(0xFF8B5CF6),
      'upi': const Color(0xFF8B5CF6),
      'CREDIT_CARD': const Color(0xFFF59E0B),
      'DEBIT_CARD': const Color(0xFFF97316),
      'CHEQUE': const Color(0xFFEF4444),
      'cheque': const Color(0xFFEF4444),
      'OTHERS': const Color(0xFF6B7280),
      'GIVEN_SALE_DUES': const Color(0xFF8B5CF6),
      'EMI_PENDING': const Color(0xFFEF4444),
      'rtgs': const Color(0xFFEF4444),
      'account': const Color(0xFF3B82F6),
    };

    return colors[receivedMode.toLowerCase()] ?? const Color(0xFF6B7280);
  }

  IconData getReceivedModeIcon(String receivedMode) {
    final icons = {
      'CASH': Icons.money,
      'cash': Icons.money,
      'BANK': Icons.account_balance,
      'neft': Icons.account_balance,
      'UPI': Icons.phone_android,
      'upi': Icons.phone_android,
      'CREDIT_CARD': Icons.credit_card,
      'DEBIT_CARD': Icons.credit_card_outlined,
      'CHEQUE': Icons.note,
      'cheque': Icons.note,
      'OTHERS': Icons.more_horiz,
      'GIVEN_SALE_DUES': Icons.sell_outlined,
      'EMI_PENDING': Icons.schedule,
      'rtgs': Icons.account_balance_wallet,
      'account': Icons.account_balance,
    };

    return icons[receivedMode.toLowerCase()] ?? Icons.payment;
  }

  // Analytics methods
  void onMonthlyCommissionChanged(String? company) {
    if (company != null) {
      selectedMonthlyCommissionCompany.value = company;
      loadMonthlyCommissionChart();
    }
  }

  void onMonthlyCommissionMonthChanged(int? month) {
    if (month != null) {
      selectedMonthlyCommissionMonth.value = month;
      loadMonthlyCommissionChart();
    }
  }

  void onMonthlyCommissionYearChanged(int? year) {
    if (year != null) {
      selectedMonthlyCommissionYear.value = year;
      loadMonthlyCommissionChart();
    }
  }

  Future<void> loadMonthlyCommissionChart() async {
    try {
      isLoadingMonthlyCommission.value = true;

      final query = {
        'year': selectedMonthlyCommissionYear.value.toString(),
        'month': selectedMonthlyCommissionMonth.value.toString(),
      };
      if (selectedMonthlyCommissionCompany.value != 'All') {
        query['company'] = selectedMonthlyCommissionCompany.value;
      }
      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/commissions/charts/monthly',
        dictParameter: query,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        monthlyCommissionChartData.value = List<Map<String, dynamic>>.from(
          response.data,
        );
        print(monthlyCommissionChartData);
      } else {
        log('Failed to load commissions');
      }
    } catch (e) {
      log('An error occurred while loading data: ${e.toString()}');
    } finally {
      isLoadingMonthlyCommission.value = false;
    }
  }

  void onWiseCommissionCompanyChanged(String? company) {
    if (company != null) {
      selectedWiseCommissionCompany.value = company;
      loadWiseCommissionChart();
    }
  }

  void onWiseCommissionMonthChanged(int? month) {
    if (month != null) {
      selectedWiseCommissionMonth.value = month;
      loadWiseCommissionChart();
    }
  }

  void onWiseCommissionYearChanged(int? year) {
    if (year != null) {
      selectedWiseCommissionYear.value = year;
      loadWiseCommissionChart();
    }
  }

  Future<void> loadWiseCommissionChart() async {
    try {
      isLoadingWiseCommission.value = true;

      final query = {
        'year': selectedMonthlyCommissionYear.value.toString(),
        'month': selectedMonthlyCommissionMonth.value.toString(),
      };
      if (selectedWiseCommissionCompany.value != 'All') {
        query['company'] = selectedWiseCommissionCompany.value;
      }
      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/commissions/charts/company-wise',
        dictParameter: query,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        companyWiseCommissionChartData.value = List<Map<String, dynamic>>.from(
          response.data,
        );
      } else {
        log('Failed to load commissions');
      }
    } catch (e) {
      log('An error occurred while loading data: ${e.toString()}');
    } finally {
      isLoadingWiseCommission.value = false;
    }
  }

  // ✅ NEW VARIABLES FOR CHART API DATA
  var monthlyChartApiData = <dynamic>[].obs;
  var companyChartApiData = <dynamic>[].obs;
  var isLoadingMonthlyChart = false.obs;
  var selectedMonthlyChartCompany = Rx<String?>(null);
  var selectedMonthlyChartYear = DateTime.now().year.obs;
  var selectedMonthlyChartMonth = DateTime.now().month.obs;

  RxBool isMonthlyChartActive = false.obs;

  void updateMonthlyChartYear(String newYear) {
    selectedMonthlyChartYear.value = int.parse(newYear);
              print(isMonthlyChartActive.value);

    loadMonthlyChartData();
  }

  void updateMonthlyMonth(int month) {
    selectedMonthlyChartMonth.value = month;
    loadMonthlyChartData();
  }

  void canClearMonthlyChart() {
    isMonthlyChartActive.value =
        selectedMonthlyChartYear.value != DateTime.now().year ||
        selectedMonthlyChartMonth.value != DateTime.now().month ||
        selectedMonthlyChartCompany.value != null;
  }

  void clearMonthlyChart() {
    selectedMonthlyChartYear.value = DateTime.now().year;
    selectedMonthlyChartMonth.value = DateTime.now().month;

    selectedMonthlyChartCompany.value = null;
    loadMonthlyChartData();
  }

  // ✅ Load Monthly Chart Data from API
  /// API: GET /api/commissions/charts/monthly?year=2026&company=Samsung
  Future<void> loadMonthlyChartData() async {
    try {
      isLoadingMonthlyChart.value = true;

      final query = <String, String>{
        'year': selectedMonthlyChartYear.value.toString(),
        'month': selectedMonthlyChartMonth.value.toString(),
      };

      if (selectedMonthlyChartCompany.value != null &&
          selectedMonthlyChartCompany.value!.isNotEmpty) {
        query['company'] = selectedMonthlyChartCompany.value!;
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/commissions/charts/monthly',
        dictParameter: query,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        // ✅ Store raw API response for AutoChart
        monthlyChartApiData.value = response.data ?? [];

        log('Monthly chart data loaded: $monthlyChartApiData');
      } else {
        monthlyChartApiData.value = [];
        log('Failed to load monthly chart data: ${response?.statusCode}');
      }
    } catch (e) {
      monthlyChartApiData.value = [];
      log('Error loading monthly chart: ${e.toString()}');
    } finally {
      isLoadingMonthlyChart.value = false;
    }
  }

  var isLoadingCompanyChart = false.obs;
  var companyChartStartDateText = ''.obs;
  var companyChartEndDateText = ''.obs;
  var companyChartDateFilterType = 'Month'.obs;
  var selectedCompanyChartMonth = DateTime.now().month.obs;
  var selectedCompanyChartYear = DateTime.now().year.obs;
  RxBool isCompanyChartActive = false.obs;

  void updateCompanyYear(String newYear) {
    selectedCompanyChartYear.value = int.parse(newYear);
    loadCompanyChartData();
  }

  void updateCompanyMonth(int month) {
    selectedCompanyChartMonth.value = month;
    loadCompanyChartData();
  }

  void companyDateFilterTypeChanged(String type) {
    companyChartDateFilterType.value = type;

    // Clear custom dates when switching away from Custom
    if (type != 'Custom') {
      companyChartStartDateText.value = '';
      companyChartEndDateText.value = '';
    }
    loadCompanyChartData();
  }

  // Custom date selection methods
  Future<void> companySelectCustomStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final String formatDate = DateFormatterHelper.format(picked);
      log(name: 'start date log', '$formatDate');
      companyChartStartDateText.value = formatDate;
      loadCompanyChartData();
    }
  }

  Future<void> companySelectCustomEndDate(BuildContext context) async {
    DateTime? startDate = DateFormatterHelper.stringToDateTime(
      companyChartStartDateText.value,
    );

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'End Date',
    );

    if (picked != null) {
      final String formatDate = DateFormatterHelper.format(picked);
      companyChartEndDateText.value = formatDate;
      loadCompanyChartData();
    }
  }

  void canClearCompanyChart() {
    isCompanyChartActive.value =
        selectedCompanyChartYear.value != DateTime.now().year ||
        selectedCompanyChartYear.value != DateTime.now().month ||
        companyChartStartDateText.value.isNotEmpty ||
        companyChartEndDateText.value.isNotEmpty ||
        companyChartDateFilterType.value != 'Month';
  }

  void clearCompanyChartData() {
    selectedCompanyChartMonth.value = DateTime.now().month;
    selectedCompanyChartYear.value = DateTime.now().year;
    loadCompanyChartData();
    companyChartStartDateText.value = '';
    companyChartEndDateText.value = '';
    companyChartDateFilterType.value = 'Month';
  }

  // ✅ Load Company Chart Data from API
  /// API: GET /api/commissions/charts/company-wise?year=2026
  Future<void> loadCompanyChartData() async {
    try {
      isLoadingCompanyChart.value = true;

      final query = <String, String>{};

      if (companyChartDateFilterType.value == 'Custom') {
        // Custom date range
        if (companyChartStartDateText.value.isNotEmpty) {
          query['startDate'] = DateFormatterHelper.toApi(
            companyChartStartDateText.value,
          );
        }
        if (companyChartEndDateText.value.isNotEmpty) {
          query['endDate'] = DateFormatterHelper.toApi(
            companyChartEndDateText.value,
          );
        }
      } else if (companyChartDateFilterType.value == 'Year') {
        // Year filter only
        query['year'] = selectedCompanyChartYear.value.toString();
      } else {
        // Month filter (default)
        query['year'] = selectedCompanyChartYear.value.toString();
        query['month'] = selectedCompanyChartMonth.value.toString();
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/commissions/charts/company-wise',
        dictParameter: query,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        // ✅ Store raw API response for AutoChart
        companyChartApiData.value = response.data ?? [];

        log('Company chart data loaded: $companyChartApiData');
      } else {
        companyChartApiData.value = [];
        log('Failed to load company chart data: ${response?.statusCode}');
      }
    } catch (e) {
      companyChartApiData.value = [];
      log('Error loading company chart: ${e.toString()}');
    } finally {
      isLoadingCompanyChart.value = false;
    }
  }

  // ✅ Clear chart data
  void clearChartData() {
    monthlyChartApiData.value = [];
    companyChartApiData.value = [];
  }
}
