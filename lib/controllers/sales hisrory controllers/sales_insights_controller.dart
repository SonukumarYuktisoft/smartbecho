import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:intl/intl.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_Insights_models/BrandSalesResponse.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_Insights_models/MonthlyRevenue.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_Insights_models/TopSellingModelsResponse.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_Insights_models/payment_distribution_model.dart';
import 'package:smartbecho/utils/helper/date_formatter_helper.dart';

class SalesInsightsController extends GetxController {
  // Utility methods
  bool get isSmallScreen => Get.width < 360;
  bool get isMediumScreen => Get.width >= 360 && Get.width < 400;
  double get screenWidth => Get.width;
  double get screenHeight => Get.height;

  // API service instance
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  final RxBool isLoading = false.obs;

  // Base URLs for sales API
  String get revenueTrendsUrl =>
      '${_config.baseUrl}/api/sales/revenue/monthly?';
  String get brandDistributionUrl =>
      '${_config.baseUrl}/api/sales/brand-sales?';
  String get topSellingModelsUrl => '${_config.baseUrl}/api/sales/top-models?';
  String get paymentMethodsUrl =>
      '${_config.baseUrl}/api/sales/payment-distribution?';

  // Revenue Section
  var selectedRevenueYear = DateTime.now().year.obs;

  // Brand Distribution Section
  var selectedbrandDisMonth = DateTime.now().month.obs;
  var selectedBrandDisYear = DateTime.now().year.obs;

  // Payment Method Distribution Section
  var selectedPaymentrandDisMonth = DateTime.now().month.obs;
  var selectedPaymentYear = DateTime.now().year.obs;

  // General
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var availableYears = <int>[].obs;
  var isCustomDateRange = false.obs;

  @override
  void onInit() {
    fetchRevenueTrends();
    fetchBrandDistribution();
    fetchTopModels();
    fetchPaymentMethodDistribution();
    fetchMobileFilters();
    super.onInit();
  }

  final List<String> years = List.generate(5, (index) {
    final year = DateTime.now().year - index;
    return year.toString();
  });

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

  // Get month display text based on selected payment month
  String get monthDisplayText {
    final monthIndex = selectedPaymentrandDisMonth.value - 1;
    if (monthIndex >= 0 && monthIndex < months.length) {
      return months[monthIndex];
    }
    return 'Select Month';
  }

  @override
  void onClose() {
    super.onClose();
  }

  // ==================== REVENUE TRENDS ====================
  void updateSelectedYear(String newYear) {
    selectedRevenueYear.value = int.parse(newYear);
    fetchRevenueTrends();
  }

  bool canClearRevenueTrends() {
    return selectedRevenueYear.value != DateTime.now().year;
  }

  void clearRevenueTrends() {
    selectedRevenueYear.value = DateTime.now().year;
    fetchRevenueTrends();
  }

  // Rx<MonthlyRevenueResponse?>  revenueData = Rx<MonthlyRevenueResponse?>(null);
  RxBool isRevenueChartLoading = false.obs;
  var revenueData = <String, double>{}.obs;
  Future<void> fetchRevenueTrends() async {
    try {
      isRevenueChartLoading.value = true;
      final query = <String, String>{
        'year': selectedRevenueYear.value.toString(),
      };

      var response = await _apiService.requestGetForApi(
        url: revenueTrendsUrl,
        authToken: true,
        dictParameter: query,
        featureKey: FeatureKeys.SALES.monthlyRevenue,
      );
      if (response != null && response.statusCode == 200) {
        final data = MonthlyRevenueResponse.fromJson(response.data);
        // revenueData.value = MonthlyRevenueResponse.fromJson(response.data);
        revenueData.value = data.payload;
      }
      print('Revenue Trends Response: $response');
    } catch (e) {
      isRevenueChartLoading.value = false;
      print('Error fetching revenue trends: $e');
    } finally {
      isRevenueChartLoading.value = false;
    }
  }

  // ==================== BRAND DISTRIBUTION ====================
  RxBool isBrandChartLoading = false.obs;
  var brandChartStartDateText = ''.obs;
  var brandChartEndDateText = ''.obs;
  var brandChartDateFilterType = 'Month'.obs;
  var selectedItemCategory = Rx<String?>(null);
  var brandSalesList = <BrandSaleItem>[].obs;

  void updateBrandDisYear(String newYear) {
    selectedBrandDisYear.value = int.parse(newYear);
    fetchBrandDistribution();
  }

  void updateBrandDisMonth(int month) {
    selectedbrandDisMonth.value = month;
    fetchBrandDistribution();
  }

  void brandDisOnDateFilterTypeChanged(String type) {
    brandChartDateFilterType.value = type;

    // Clear custom dates when switching away from Custom
    if (type != 'Custom') {
      brandChartStartDateText.value = '';
      brandChartEndDateText.value = '';
    }
    fetchBrandDistribution();
  }

  // Custom date selection methods
  Future<void> brandDisSelectCustomStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final String formatDate = DateFormatterHelper.format(picked);
      log(name: 'start date log', '$formatDate');
      brandChartStartDateText.value = formatDate;
      fetchBrandDistribution();
    }
  }

  Future<void> brandDisSelectCustomEndDate(BuildContext context) async {
    DateTime? startDate = DateFormatterHelper.stringToDateTime(
      brandChartStartDateText.value,
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
      brandChartEndDateText.value = formatDate;
      fetchBrandDistribution();
    }
  }

  bool canClearBrandDistribution() {
    return selectedbrandDisMonth.value != DateTime.now().month ||
        selectedBrandDisYear.value != DateTime.now().year ||
        brandChartStartDateText.value.isNotEmpty ||
        brandChartEndDateText.value.isNotEmpty ||
        brandChartDateFilterType.value != 'Month' ||
        selectedItemCategory.value != null;
  }

  void clearBrandDistribution() {
    selectedbrandDisMonth.value = DateTime.now().month;
    selectedBrandDisYear.value = DateTime.now().year;
    brandChartStartDateText.value = '';
    brandChartEndDateText.value = '';
    brandChartDateFilterType.value = 'Month';
    selectedItemCategory.value = null;
    fetchBrandDistribution();
  }

  Future<void> fetchBrandDistribution() async {
    try {
      isBrandChartLoading.value = true;
      final query = <String, String>{};

      if (selectedItemCategory.value != null &&
          selectedItemCategory.value!.isNotEmpty) {
        query['itemCategory'] = selectedItemCategory.value!;
      }
      if (brandChartDateFilterType.value == 'Custom') {
        // Custom date range
        if (brandChartStartDateText.value.isNotEmpty) {
          query['startDate'] = DateFormatterHelper.toApi(
            brandChartStartDateText.value,
          );
        }
        if (brandChartEndDateText.value.isNotEmpty) {
          query['endDate'] = DateFormatterHelper.toApi(
            brandChartEndDateText.value,
          );
        }
      } else if (brandChartDateFilterType.value == 'Year') {
        // Year filter only
        query['year'] = selectedBrandDisYear.value.toString();
      } else {
        // Month filter (default)
        query['year'] = selectedBrandDisYear.value.toString();
        query['month'] = selectedbrandDisMonth.value.toString();
      }

      var response = await _apiService.requestGetForApi(
        url: brandDistributionUrl,
        authToken: true,
        dictParameter: query,
        featureKey: FeatureKeys.SALES.brandSales,
      );

      if (response != null && response.statusCode == 200) {
        final data = BrandSalesResponse.fromJson(response.data);
        brandSalesList.value = data.payload;
        print('Brand Distribution fetched: ${brandSalesList.length} items');
      }
    } catch (e) {
      isBrandChartLoading.value = false;
      print('Error fetching brand distribution: $e');
    } finally {
      isBrandChartLoading.value = false;
    }
  }

  // ==================== Top Selling Models ====================
  RxBool topModelsChartLoading = false.obs;
  var selectedTopModelsDisMonth = DateTime.now().month.obs;
  var selectedTopModelsYear = DateTime.now().year.obs;
  var topModelsChartStartDateText = ''.obs;
  var topModelsChartEndDateText = ''.obs;
  var topModelsChartDateFilterType = 'Month'.obs;
  var selectedModel = Rx<String?>(null);

  var topModelsList = <TopModelItem>[].obs;

  void updateTopModelsYear(String newYear) {
    selectedTopModelsYear.value = int.parse(newYear);
    fetchTopModels();
  }

  void updateTopModelsMonth(int month) {
    selectedTopModelsDisMonth.value = month;
    fetchTopModels();
  }

  bool canClearTopModels() {
    return selectedTopModelsDisMonth.value != DateTime.now().month ||
        selectedTopModelsYear.value != DateTime.now().year ||
        topModelsChartStartDateText.value.isNotEmpty ||
        topModelsChartEndDateText.value.isNotEmpty ||
        topModelsChartDateFilterType.value != 'Month';
  }

  void clearTopModels() {
    selectedTopModelsDisMonth.value = DateTime.now().month;
    selectedTopModelsYear.value = DateTime.now().year;
    topModelsChartStartDateText.value = '';
    topModelsChartEndDateText.value = '';
    topModelsChartDateFilterType.value = 'Month';
    fetchTopModels();
  }

  void topModelsOnDateFilterTypeChanged(String type) {
    topModelsChartDateFilterType.value = type;

    // Clear custom dates when switching away from Custom
    if (type != 'Custom') {
      topModelsChartStartDateText.value = '';
      topModelsChartEndDateText.value = '';
    }
    fetchTopModels();
  }

  // Custom date selection methods
  Future<void> topModelsSelectCustomStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final String formatDate = DateFormatterHelper.format(picked);
      log(name: 'start date log', '$formatDate');
      topModelsChartStartDateText.value = formatDate;
      fetchTopModels();
    }
  }

  Future<void> topModelsSelectCustomEndDate(BuildContext context) async {
    DateTime? startDate = DateFormatterHelper.stringToDateTime(
      topModelsChartStartDateText.value,
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
      topModelsChartEndDateText.value = formatDate;
      fetchTopModels();
    }
  }

  Future<void> fetchTopModels() async {
    try {
      topModelsChartLoading.value = true;
      final query = <String, String>{};
      if (selectedModel.value != null && selectedModel.value!.isNotEmpty) {
        query['model'] = selectedModel.value!;
      }
      if (topModelsChartDateFilterType.value == 'Custom') {
        // Custom date range
        if (topModelsChartStartDateText.value.isNotEmpty) {
          query['startDate'] = DateFormatterHelper.toApi(
            topModelsChartStartDateText.value,
          );
        }
        if (topModelsChartEndDateText.value.isNotEmpty) {
          query['endDate'] = DateFormatterHelper.toApi(
            topModelsChartEndDateText.value,
          );
        }
      } else if (topModelsChartDateFilterType.value == 'Year') {
        // Year filter only
        query['year'] = selectedTopModelsYear.value.toString();
      } else {
        // Month filter (default)
        query['year'] = selectedTopModelsYear.value.toString();
        query['month'] = selectedTopModelsDisMonth.value.toString();
      }

      var response = await _apiService.requestGetForApi(
        url: topSellingModelsUrl,
        authToken: true,
        dictParameter: query,
        featureKey: FeatureKeys.SALES.topModels,
      );

      if (response != null && response.statusCode == 200) {
        final data = TopSellingModelsResponse.fromJson(response.data);
        topModelsList.value = data.payload;
        print('Top Models fetched: ${topModelsList.length} items');
      }
    } catch (e) {
      topModelsChartLoading.value = false;

      print('Error fetching top models: $e');
    } finally {
      topModelsChartLoading.value = false;
    }
  }

  // ==================== PAYMENT METHOD DISTRIBUTION ====================
  RxBool isPaymentChartLoading = false.obs;
  var paymentDistributions = <PaymentDistribution>[].obs;
  Rx<PaymentDistributionResponse?> paymentData =
      Rx<PaymentDistributionResponse?>(null);
  RxInt totalPayments = 0.obs;
  RxDouble totalAmount = 0.0.obs;

  var paymentChartStartDateText = ''.obs;
  var paymentChartEndDateText = ''.obs;
  var paymentChartDateFilterType = 'Month'.obs;

  void updatePaymentDisYear(String newYear) {
    selectedPaymentYear.value = int.parse(newYear);
    fetchPaymentMethodDistribution();
  }

  void updatePaymentDisMonth(int month) {
    selectedPaymentrandDisMonth.value = month;
    fetchPaymentMethodDistribution();
  }

  void clearPaymentMethodDistribution() {
    selectedPaymentrandDisMonth.value = DateTime.now().month;
    selectedPaymentYear.value = DateTime.now().year;
    fetchPaymentMethodDistribution();
    paymentChartStartDateText.value = '';
    paymentChartEndDateText.value = '';
    paymentChartDateFilterType.value = 'Month';
  }

  bool canClearPaymentMethodDistribution() {
    return selectedPaymentrandDisMonth.value != DateTime.now().month ||
        selectedPaymentYear.value != DateTime.now().year ||
        paymentChartStartDateText.value.isNotEmpty ||
        paymentChartEndDateText.value.isNotEmpty ||
        paymentChartDateFilterType.value != 'Month';
  }

  void paymentOnDateFilterTypeChanged(String type) {
    paymentChartDateFilterType.value = type;

    // Clear custom dates when switching away from Custom
    if (type != 'Custom') {
      paymentChartStartDateText.value = '';
      paymentChartEndDateText.value = '';
    }
    fetchPaymentMethodDistribution();
  }

  // Custom date selection methods
  Future<void> paymentSelectCustomStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final String formatDate = DateFormatterHelper.format(picked);
      log(name: 'start date log', '$formatDate');
      paymentChartStartDateText.value = formatDate;
      fetchPaymentMethodDistribution();
    }
  }

  Future<void> paymentSelectCustomEndDate(BuildContext context) async {
    DateTime? startDate = DateFormatterHelper.stringToDateTime(
      paymentChartStartDateText.value,
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
      paymentChartEndDateText.value = formatDate;
      fetchPaymentMethodDistribution();
    }
  }

  Future<void> fetchPaymentMethodDistribution() async {
    try {
      isPaymentChartLoading.value = true;

      final query = <String, String>{};
      if (paymentChartDateFilterType.value == 'Custom') {
        // Custom date range
        if (paymentChartStartDateText.value.isNotEmpty) {
          query['startDate'] = DateFormatterHelper.toApi(
            paymentChartStartDateText.value,
          );
        }
        if (paymentChartEndDateText.value.isNotEmpty) {
          query['endDate'] = DateFormatterHelper.toApi(
            paymentChartEndDateText.value,
          );
        }
      } else if (paymentChartDateFilterType.value == 'Year') {
        // Year filter only
        query['year'] = selectedPaymentYear.value.toString();
      } else {
        // Month filter (default)
        query['year'] = selectedPaymentYear.value.toString();
        query['month'] = selectedPaymentrandDisMonth.value.toString();
      }

      var response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/sales/payment-distribution?',
        authToken: true,
        dictParameter: query,
        featureKey: FeatureKeys.SALES.paymentSalesDistribution,
      );

      if (response != null && response.statusCode == 200) {
        paymentData.value = PaymentDistributionResponse.fromJson(response.data);
        totalPayments.value = paymentData.value!.totalPayments.toInt();
        paymentDistributions.value = paymentData.value!.distributions;
        totalAmount.value = paymentDistributions.fold<double>(
          0,
          (sum, element) => sum + element.totalAmount,
        );

        print('Payment Data: ${paymentData.value}');
        print('Payment Data: ${totalPayments.value}');
      }
      print('Payment Data: ${paymentData.value}');
      print('Payment Data: ${totalPayments.value}');
    } catch (e) {
      isPaymentChartLoading.value = false;

      print('Error fetching payment method distribution: $e');
    } finally {
      isPaymentChartLoading.value = false;
    }
  }

  // ==================== MOBILE FILTERS CONTROLLER SECTION ====================
  // var selectedCompanies = <String>[].obs;
  //   var selectedModels = <String>[].obs;
  //   var selectedRams = <String>[].obs;
  //   var selectedRoms = <String>[].obs;
  //   var selectedColors = <String>[].obs;
  //   var selectedItemCategories = <String>[].obs;

  var companiesList = <String>[].obs;
  var modelsList = <String>[].obs;
  var ramsList = <String>[].obs;
  var romsList = <String>[].obs;
  var colorsList = <String>[].obs;
  var itemCategoriesList = <String>[].obs;
  RxBool isMobileFiltersLoading = false.obs;

  // ==================== FETCH MOBILE FILTERS ====================
  Future<void> fetchMobileFilters() async {
    try {
      isMobileFiltersLoading.value = true;

      var response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/mobiles/filters',
        authToken: true,
        // featureKey: FeatureKeys.SALES.mobileFilters, // Update with your feature key
      );

      if (response != null && response.statusCode == 200) {
        final data = MobileFiltersResponse.fromJson(response.data);
        colorsList.value = data.companies;
        modelsList.value = data.models;
        ramsList.value = data.rams;
        romsList.value = data.roms;
        colorsList.value = data.colors;
        itemCategoriesList.value = data.itemCategories;

        print('Mobile Filters loaded: ${data.companies.length} companies');
      }
    } catch (e) {
      isMobileFiltersLoading.value = false;
      print('Error fetching mobile filters: $e');
    } finally {
      isMobileFiltersLoading.value = false;
    }
  }
}

class MobileFiltersResponse {
  final List<String> companies;
  final List<String> models;
  final List<String> rams;
  final List<String> roms;
  final List<String> colors;
  final List<String> itemCategories;

  MobileFiltersResponse({
    required this.companies,
    required this.models,
    required this.rams,
    required this.roms,
    required this.colors,
    required this.itemCategories,
  });

  factory MobileFiltersResponse.fromJson(Map<String, dynamic> json) {
    return MobileFiltersResponse(
      companies: List<String>.from(json['companies'] ?? []),
      models: List<String>.from(json['models'] ?? []),
      rams: List<String>.from(json['rams'] ?? []),
      roms: List<String>.from(json['roms'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      itemCategories: List<String>.from(json['itemCategories'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companies': companies,
      'models': models,
      'rams': rams,
      'roms': roms,
      'colors': colors,
      'itemCategories': itemCategories,
    };
  }
}
