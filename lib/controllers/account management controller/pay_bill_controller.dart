import 'dart:convert';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:smartbecho/models/account%20management%20models/pay_bill_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/utils/Dialogs/app_successdialog.dart';
import 'package:smartbecho/utils/common%20file%20uploader/common_fileupload_controller.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/utils/helper/toast_helper.dart';

class PayBillsController extends GetxController {
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Observable variables for listing
  var isLoading = false.obs;
  var payBills = <PayBill>[].obs;
  var filteredPayBills = <PayBill>[].obs;
  var currentPage = 0.obs;
  var totalPages = 0.obs;
  var totalElements = 0.obs;
  var hasMoreData = true.obs;

  // Filter variables
  var searchQuery = ''.obs;
  var selectedCompany = 'All'.obs;
  var selectedPurpose = 'All'.obs;
  var selectedPaymentMode = 'All'.obs;
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  // Date filter type and custom date range
  var dateFilterType = 'Month'.obs; // 'Month', 'Year', or 'Custom'
  var customStartDate = Rx<DateTime?>(null);
  var customEndDate = Rx<DateTime?>(null);
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  var startDateText = ''.obs;
  var endDateText = ''.obs;
  // Available filter options
  var companies = <String>['All'].obs;
  var purposes = <String>['All'].obs;
  var paymentModes = <String>['All'].obs;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final int pageSize = 10;

  // Add Pay Bill Form Controllers
  final formKey = GlobalKey<FormState>();
  final dateController = TextEditingController();
  final amountController = TextEditingController();
  final paidToController = TextEditingController();
  final paidByController = TextEditingController();
  final companyController = TextEditingController();
  final notesController = TextEditingController();

  // Add Pay Bill Observable variables
  var selectedFormPaymentMode = ''.obs;
  var selectedFormPurpose = ''.obs;
  var isFormLoading = false.obs;
  var isFileUploading = false.obs;
  var selectedFile = Rx<File?>(null);
  var fileName = ''.obs;

  // Form Dropdown options
  final List<String> formPaymentModes = [
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

  final List<String> formPurposes = [
    'Inventory Purchase',
    'Utility Bill',
    'Rent',
    'Salary',
    'Maintenance',
    'Other',
  ];

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

  // ===================
  // ANALYTICS VARIABLES
  // ===================
  var analyticsCurrentView = 'Monthly'.obs;
  var analyticsSelectedCompany = 'All Distributer'.obs;
  var analyticsMonthlyYear = DateTime.now().year.toString().obs;
  var analyticsCompanyYear = DateTime.now().year.toString().obs;

  // Computed chart data
  var monthlyChartData = <String, double>{}.obs;
  var companyChartData = <String, double>{}.obs;

  // Available options
  List<String> get analyticsAvailableYears {
    final currentYear = DateTime.now().year;
    return List.generate(5, (index) => (currentYear - index).toString());
  }

  List<String> get analyticsAvailableCompanies {
    final companies = <String>{'All Distributer'};
    for (var bill in payBills) {
      companies.add(bill.company);
    }
    return companies.toList()..sort();
  }

  // Add file upload controller instance
  final fileUploadController = FileUploadController();

  @override
  void onInit() {
    super.onInit();
    loadPayBills(refresh: true);

    // Set default date to today
    dateController.text = DateTime.now().toString().split(' ')[0];
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    dateController.dispose();
    amountController.dispose();
    paidToController.dispose();
    paidByController.dispose();
    companyController.dispose();
    notesController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  // ===================
  // LISTING METHODS
  // ===================

  Future<void> loadPayBills({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 0;
        payBills.clear();
        filteredPayBills.clear();
        hasMoreData.value = true;
      }

      if (!hasMoreData.value) return;

      isLoading.value = true;

      // Build query parameters including filters
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

      // Add optional filters
      if (searchQuery.value.isNotEmpty) {
        query['search'] = searchQuery.value;
      }
      if (selectedCompany.value != 'All') {
        query['company'] = selectedCompany.value;
      }
      if (selectedPurpose.value != 'All') {
        query['purpose'] = selectedPurpose.value;
      }
      if (selectedPaymentMode.value != 'All') {
        query['paymentMode'] = selectedPaymentMode.value;
      }

      final response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/pay-bills',
        dictParameter: query,
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final payBillsResponse = PayBillsResponse.fromJson(response.data);

        if (refresh) {
          payBills.value = payBillsResponse.content;
          filteredPayBills.value = payBillsResponse.content;
        } else {
          payBills.addAll(payBillsResponse.content);
          filteredPayBills.addAll(payBillsResponse.content);
        }

        totalPages.value = payBillsResponse.totalPages;
        totalElements.value = payBillsResponse.totalElements;
        hasMoreData.value = !payBillsResponse.last;

        // Update filter options only on refresh or first load
        if (refresh || currentPage.value == 0) {
          _updateFilterOptions();
        }
      } else {
        log('Failed to load pay bills');
      }
    } catch (e) {
      log('An error occurred while loading data: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateFilterOptions() {
    // Update companies
    final companySet = payBills.map((bill) => bill.company).toSet();
    companies.value = ['All', ...companySet.toList()..sort()];

    // Update purposes
    final purposeSet = payBills.map((bill) => bill.purpose).toSet();
    purposes.value = ['All', ...purposeSet.toList()..sort()];

    // Update payment modes
    final paymentModeSet = payBills.map((bill) => bill.paymentMode).toSet();
    paymentModes.value = ['All', ...paymentModeSet.toList()..sort()];
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  void onCompanyChanged(String company) {
    selectedCompany.value = company;
    _applyFilters();
  }

  void onPurposeChanged(String purpose) {
    selectedPurpose.value = purpose;
    _applyFilters();
  }

  void onPaymentModeChanged(String paymentMode) {
    selectedPaymentMode.value = paymentMode;
    _applyFilters();
  }

  void onMonthChanged(int month) {
    selectedMonth.value = month;
    _applyFilters();
  }

  void onYearChanged(int year) {
    selectedYear.value = year;
    _applyFilters();
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

    _applyFilters();
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
      _applyFilters();
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
      _applyFilters();
    }
  }

  void _applyFilters() {
    // Since we're now filtering from API, we need to refresh data
    loadPayBills(refresh: true);
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCompany.value = 'All';
    selectedPurpose.value = 'All';
    selectedPaymentMode.value = 'All';
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
    loadPayBills(refresh: true);
  }

  void loadNextPage() {
    if (hasMoreData.value && !isLoading.value) {
      currentPage.value++;
      loadPayBills();
    }
  }

  void refreshData() {
    loadPayBills(refresh: true);
  }

  String getFilterSummary() {
    List<String> activeFilters = [];

    if (searchQuery.value.isNotEmpty) {
      activeFilters.add('Search: "${searchQuery.value}"');
    }
    if (selectedCompany.value != 'All') {
      activeFilters.add('Company: ${selectedCompany.value}');
    }
    if (selectedPurpose.value != 'All') {
      activeFilters.add('Purpose: ${selectedPurpose.value}');
    }
    if (selectedPaymentMode.value != 'All') {
      activeFilters.add('Payment: ${selectedPaymentMode.value}');
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

    return '${activeFilters.join(' • ')} • ${filteredPayBills.length} results';
  }

  bool get hasActiveFilters {
    return searchQuery.value.isNotEmpty ||
        selectedCompany.value != 'All' ||
        selectedPurpose.value != 'All' ||
        selectedPaymentMode.value != 'All' ||
        dateFilterType.value == 'Custom' ||
        (dateFilterType.value == 'Year' &&
            selectedYear.value != DateTime.now().year) ||
        (dateFilterType.value == 'Month' &&
            (selectedMonth.value != DateTime.now().month ||
                selectedYear.value != DateTime.now().year));
  }

  String get monthDisplayText {
    return months[selectedMonth.value - 1];
  }

  Color getCompanyColor(String company) {
    final colors = {
      'apple': const Color(0xFF007AFF),
      'samsung': const Color(0xFF1428A0),
      'google': const Color(0xFF4285F4),
      'xiaomi': const Color(0xFFFF6900),
      'oneplus': const Color(0xFFEB0028),
      'realme': const Color(0xFFFFC900),
      'oppo': const Color(0xFF1BA784),
      'vivo': const Color(0xFF4A90E2),
      'nokia': const Color(0xFF124191),
      'honor': const Color(0xFF2C5BFF),
      'gst': const Color(0xFF8B5CF6),
      'vendor a': const Color(0xFF10B981),
      'vendor b': const Color(0xFFF59E0B),
      'vendor c': const Color(0xFFEF4444),
    };

    return colors[company.toLowerCase()] ?? const Color(0xFF6366F1);
  }

  Color getPurposeColor(String purpose) {
    final colors = {
      'salary': const Color(0xFF10B981),
      'utility bill': const Color(0xFF3B82F6),
      'rent': const Color(0xFF8B5CF6),
      'office stationery': const Color(0xFFF59E0B),
      'maintenance': const Color(0xFFEF4444),
      'internet': const Color(0xFF06B6D4),
      'electricity': const Color(0xFFF97316),
      'other': const Color(0xFF6B7280),
    };

    return colors[purpose.toLowerCase()] ?? const Color(0xFF6B7280);
  }

  // ===================
  // ADD PAY BILL METHODS
  // ===================

  // File picker methods
  Future<void> pickFile() async {
    try {
      isFileUploading.value = true;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        selectedFile.value = File(result.files.single.path!);
        fileName.value = result.files.single.name;

        ToastHelper.success(
          message: 'File selected: ${result.files.single.name}',
        );
      } else {
        ToastHelper.warning(message: 'No file selected');
      }
    } catch (e) {
      ToastHelper.error(message: 'Failed to pick file: ${e.toString()}');
    } finally {
      isFileUploading.value = false;
    }
  }

  void removeFile() {
    selectedFile.value = null;
    fileName.value = '';
  }

  // Save pay bill
  Future<void> savePayBill() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isFormLoading.value = true;

      // Parse the date to ISO format
      DateTime selectedDate = DateTime.parse(dateController.text);
      String isoDate = selectedDate.toUtc().toIso8601String();

      // Create the PayBill object according to the API format
      final payBillData = {
        'date': isoDate,
        'company': companyController.text,
        'paidToPerson': paidToController.text,
        'purpose': selectedFormPurpose.value,
        'paidBy': paidByController.text,
        'amount': double.parse(amountController.text),
        'paymentMode': selectedFormPaymentMode.value,
        'description': notesController.text,
        'uploadedFileUrl': '',
      };

      final formData = dio.FormData();

      formData.fields.add(MapEntry('PayBill', jsonEncode(payBillData)));

      if (fileUploadController.selectedFile.value != null) {
        String fileName =
            fileUploadController.selectedFile.value!.path.split('/').last;
        formData.files.add(
          MapEntry(
            'file',
            dio.MultipartFile.fromFileSync(
              fileUploadController.selectedFile.value!.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _apiService.requestMultipartApi(
        url: '${_config.baseUrl}/api/pay-bills',
        formData: formData,
        authToken: true,
        showToast: true,
      );

      if (response != null && response.statusCode == 201) {
        log('Pay bill saved successfully!');

        clearForm();
        await loadPayBills(refresh: true);
        await gotoSellScreen();

        // Get.back();
      } else {
        String errorMessage = 'Failed to save pay bill';
        if (response?.data != null && response!.data['message'] != null) {
          errorMessage = response.data['message'];
        }

        log('Failed to save pay bill $errorMessage');
      }
    } catch (e) {
      log('Error saving pay bill: $e');
    } finally {
      isFormLoading.value = false;
    }
  }

  Future<void> gotoSellScreen() async {
    appSuccessDialog(
      title: 'successful'.toUpperCase(),

      description: 'Bill successfully',
      onPressed: () {
        Get.back();
        Get.back();
      },
    );
  }

  // Updated generate invoice method
  Future<void> generateInvoice() async {
    ToastHelper.success(message: 'Invoice generated successfully!');
  }

  // Updated clear form method
  void clearForm() {
    dateController.clear();
    amountController.clear();
    paidToController.clear();
    paidByController.clear();
    companyController.clear();
    notesController.clear();
    selectedFormPaymentMode.value = '';
    selectedFormPurpose.value = '';

    // Clear file upload
    fileUploadController.removeFile();

    // Reset date to today
    dateController.text = DateTime.now().toString().split(' ')[0];
  }

  // Validators
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
    if (double.tryParse(value) == null) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  String? validateDropdown(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an option';
    }
    return null;
  }

  // Date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dateController.text = picked.toString().split(' ')[0];
    }
  }

  // ===================
  // ANALYTICS METHODS
  // ===================

  // Just process existing data, don't reload
  void processAnalyticsData() {
    _updateChartData();
  }

  void setAnalyticsView(String view) {
    analyticsCurrentView.value = view;
  }

  void setAnalyticsCompany(String company) {
    analyticsSelectedCompany.value = company;
    _updateChartData();
  }

  void setAnalyticsMonthlyYear(String year) {
    analyticsMonthlyYear.value = year;
    _updateChartData();
  }

  void setAnalyticsCompanyYear(String year) {
    analyticsCompanyYear.value = year;
    _updateChartData();
  }

  void _updateChartData() {
    _updateMonthlyChartData();
    _updateCompanyChartData();
    update(); // This triggers GetBuilder to rebuild
  }

  void _updateMonthlyChartData() {
    final data = <String, double>{};
    final selectedCompany = analyticsSelectedCompany.value;
    final selectedYear = int.parse(analyticsMonthlyYear.value);

    // Initialize all months with 0
    for (int i = 1; i <= 12; i++) {
      final monthKey = '$selectedYear-${i.toString().padLeft(2, '0')}';
      data[monthKey] = 0.0;
    }

    // Filter and aggregate data from already loaded payBills
    for (var bill in payBills) {
      try {
        final billDate = bill.formattedDate;
        if (billDate.year == selectedYear) {
          if (selectedCompany == 'All Distributer' ||
              bill.company.toLowerCase() == selectedCompany.toLowerCase()) {
            final monthKey =
                '$selectedYear-${billDate.month.toString().padLeft(2, '0')}';
            data[monthKey] = (data[monthKey] ?? 0) + bill.amount;
          }
        }
      } catch (e) {
        print('Error processing bill: $e');
        continue;
      }
    }

    monthlyChartData.value = data;
  }

  void _updateCompanyChartData() {
    final data = <String, double>{};
    final selectedYear = int.parse(analyticsCompanyYear.value);

    // Filter and aggregate data from already loaded payBills
    for (var bill in payBills) {
      try {
        final billDate = bill.formattedDate;
        if (billDate.year == selectedYear) {
          data[bill.company] = (data[bill.company] ?? 0) + bill.amount;
        }
      } catch (e) {
        print('Error processing bill: $e');
        continue;
      }
    }

    // If no data, add a placeholder to prevent range errors
    if (data.isEmpty) {
      data['No Data'] = 0.0;
    }

    companyChartData.value = data;
  }
}
