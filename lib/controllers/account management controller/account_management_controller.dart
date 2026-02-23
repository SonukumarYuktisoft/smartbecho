import 'dart:developer';

import 'package:get/get.dart';
import 'package:smartbecho/models/account%20management%20models/account_summay_dashboard_model.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

class AccountManagementController extends GetxController {
  // Utility methods
  bool get isSmallScreen => Get.width < 360;
  bool get isMediumScreen => Get.width >= 360 && Get.width < 400;
  double get screenWidth => Get.width;
  double get screenHeight => Get.height;

  // Observable variables
  var selectedTab = 'account-summary'.obs;
  var isLoading = false.obs;

  // 🆕 Date picker observable
  final Rx<DateTime> selectedDate = Rx<DateTime>(DateTime.now());

  void confirmChart() {
    haveChart.value = true;
  }

  final Rx<AccountSummaryDashboardModel?> accountDashboardData =
      Rx<AccountSummaryDashboardModel?>(null);

  // API service instance
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;

  // Loading states
  final RxBool isLoadingMore = false.obs;
  final RxBool isActiveAc = false.obs;
  final RxBool isStatsLoading = false.obs;
  final RxBool isLoadingFilters = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Animation states
  var isAnimating = false.obs;
  var navBarExpanded = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with today's date
    selectedDate.value = DateTime.now();
     activeAccountSummaryFilter();
    fetchAccountSummaryDashboard();
    fetchCompanies();
  }

  void onTabChanged(String tabId) {
    if (tabId != selectedTab.value) {
      isAnimating.value = true;
      selectedTab.value = tabId;

      // Simulate screen transition animation
      Future.delayed(Duration(milliseconds: 300), () {
        isAnimating.value = false;
      });
    }
  }

  void refreshData() {
    fetchAccountSummaryDashboard();
  }

  void toggleNavBar() {
    navBarExpanded.value = !navBarExpanded.value;
  }

  // 🆕 Update selected date and fetch data
  void updateSelectedDate(DateTime newDate) {
    selectedDate.value = newDate;
     activeAccountSummaryFilter();
    // isLoading.value = true;
    fetchAccountSummaryDashboard();
  }

  // 🆕 Clear all data
  void clearAllData() {
    accountDashboardData.value = null;
    errorMessage.value = '';
    hasError.value = false;
    log("✨ All data cleared");
  }
bool activeAccountSummaryFilter() {
  // Compare dates without time component
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final selectedDateOnly = DateTime(
    selectedDate.value.year,
    selectedDate.value.month,
    selectedDate.value.day,
  );
  
  if (selectedDateOnly != todayDate) {
    isActiveAc.value = true;
    return true;
  } else {
    isActiveAc.value = false;
    return false;
  }
}

  String formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  // 🆕 Helper method to format date as YYYY-MM-DD
  String _formatDateForAPI(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Fetch account summary dashboard data from API
  Future<void> fetchAccountSummaryDashboard() async {
    try {
      isLoading.value = true;
      String formattedDate = _formatDateForAPI(selectedDate.value);
      log("🔄 Fetching account summary dashboard for date: $formattedDate");

      dio.Response? response = await _apiService.requestGetForApi(
        url:
            "${_config.baseUrl}/api/ledger/analytics/daily?date=$formattedDate",
        authToken: true,
      );

      if (response != null) {
        final statsResponse = AccountSummaryDashboardModel.fromJson(
          response.data,
        );
        accountDashboardData.value = statsResponse;

        log("✅ Account summary dashboard data loaded successfully");
        log("📊 Date: $formattedDate");
        log(
          "💰 Opening Balance: ${accountDashboardData.value?.payload.openingBalance}",
        );

        if (statsResponse.status == "Success") {
          log(
            "✅ Account summary dashboard loaded successfully for $formattedDate",
          );
          hasError.value = false;
          errorMessage.value = '';
        } else {
          throw Exception(statsResponse.message);
        }
      } else {
        throw Exception('No stats data received from server');
      }
    } catch (error) {
      log("❌ Error in fetchAccountSummaryDashboard: $error");
      hasError.value = true;
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch account summary dashboard data from API
  RxList<String> listOfCompany = <String>[].obs;

  Future<void> fetchCompanies() async {
    try {
      isStatsLoading.value = true;
      log("🔄 Fetching companies...");

      dio.Response? response = await _apiService.requestGetForApi(
        url: "${_config.baseUrl}/api/pay-bills/companies",
        authToken: true,
      );

      if (response != null) {
        listOfCompany.value = List<String>.from(response.data);
        log("✅ Companies fetched: ${listOfCompany.length}");
      }
    } catch (error) {
      log("❌ Error in fetchCompanies: $error");
    } finally {
      isStatsLoading.value = false;
    }
  }

  // Getters for account dashboard summary data
  List get companyList => listOfCompany.toList();

  double get openingBalance =>
      accountDashboardData.value?.payload.openingBalance ?? 0.0;
  double get totalCredit =>
      accountDashboardData.value?.payload.totalCredit ?? 0.0;
  double get totalDebit =>
      accountDashboardData.value?.payload.totalDebit ?? 0.0;
  double get closingBalance =>
      accountDashboardData.value?.payload.closingBalance ?? 0.0;
  double get emiReceivedToday =>
      accountDashboardData.value?.payload.emiReceivedToday ?? 0.0;

  double get directGivenDues =>
      accountDashboardData.value?.payload.directGivenDues ?? 0.0;
  double get duesRecovered =>
      accountDashboardData.value?.payload.duesRecovered ?? 0.0;
  double get payBills => accountDashboardData.value?.payload.payBills ?? 0.0;
  double get withdrawals =>
      accountDashboardData.value?.payload.withdrawals ?? 0.0;
  double get commissionReceived =>
      accountDashboardData.value?.payload.commissionReceived ?? 0.0;
  double get gstOnSales =>
      accountDashboardData.value?.payload.gst.gstOnSales ?? 0.0;
  double get gstOnPurchases =>
      accountDashboardData.value?.payload.gst.gstOnPurchases ?? 0.0;
  double get netGst => accountDashboardData.value?.payload.gst.netGst ?? 0.0;
  String get shopId => accountDashboardData.value?.payload.shopId ?? '';
  DateTime? get date => accountDashboardData.value?.payload.date;

  // Updated Sale getters to match new JSON structure
  double get totalSale =>
      accountDashboardData.value?.payload.sale.totalSale ?? 0.0;
  double get duesSaleDownpayment =>
      accountDashboardData.value?.payload.sale.duesSaleDownpayment ?? 0.0;
  double get emiSaleDownpayment =>
      accountDashboardData.value?.payload.sale.emiSaleDownpayment ?? 0.0;
  double get cashSale =>
      accountDashboardData.value?.payload.sale.cashSale ?? 0.0;
  double get saleRemainingGivenDues =>
      accountDashboardData.value?.payload.sale.saleRemainingGivenDues ?? 0.0;
  double get salePendingEMI =>
      accountDashboardData.value?.payload.sale.salePendingEMI ?? 0.0;

  // Backward compatible getters (if other parts of code use these)
  double get downPayment => duesSaleDownpayment + emiSaleDownpayment;
  double get givenAsDues => saleRemainingGivenDues;
  double get pendingEMI => salePendingEMI;

  Map<String, double> get moneyInOut => {
    "Money Out": accountDashboardData.value?.payload.totalCredit ?? 0,
    "Money In": accountDashboardData.value?.payload.totalDebit ?? 0,
  };
  double get todayTotalSaleCollection {
    double totalSale = this.totalSale;
    double givenDues = saleRemainingGivenDues;
    double remainingEmi = salePendingEMI;
    return totalSale - (givenDues + remainingEmi);
  }

  String get formattedTodayTotalSaleCollection =>
      '₹${todayTotalSaleCollection.toStringAsFixed(2)}';
  // Format amount for display
  String get formattedOpeningBalance =>
      '₹${AppFormatterHelper.formatIndianNumber(openingBalance)}';
  String get formattedTotalCredit =>
      '₹${AppFormatterHelper.formatIndianNumber(totalCredit)}';
  String get formattedTotalDebit =>
      '₹${AppFormatterHelper.formatIndianNumber(totalDebit)}';
  String get formattedClosingBalance =>
      '₹ ${AppFormatterHelper.formatIndianNumber(closingBalance)}';
  String get formattedEmiReceivedToday =>
      '₹${emiReceivedToday.toStringAsFixed(2)}';
  String get formattedDirectGivenDues =>
      '₹${directGivenDues.toStringAsFixed(2)}';
  String get formattedDuesRecovered => '₹${duesRecovered.toStringAsFixed(2)}';
  String get formattedPayBills => '₹${payBills.toStringAsFixed(2)}';
  String get formattedWithdrawals => '₹${withdrawals.toStringAsFixed(2)}';
  String get formattedCommissionReceived =>
      '₹${commissionReceived.toStringAsFixed(2)}';
  String get formattedGstOnSales => '₹${gstOnSales.toStringAsFixed(2)}';
  String get formattedGstOnPurchases => '₹${gstOnPurchases.toStringAsFixed(2)}';
  String get formattedNetGst => '₹${netGst.toStringAsFixed(2)}';
  String get formattedTotalSale => '₹${totalSale.toStringAsFixed(2)}';
  String get formattedDuesSaleDownpayment =>
      '₹${duesSaleDownpayment.toStringAsFixed(2)}';
  String get formattedEmiSaleDownpayment =>
      '₹${emiSaleDownpayment.toStringAsFixed(2)}';
  String get formattedCashSale => '₹${cashSale.toStringAsFixed(2)}';
  String get formattedSaleRemainingGivenDues =>
      '₹${saleRemainingGivenDues.toStringAsFixed(2)}';
  String get formattedSalePendingEMI => '₹${salePendingEMI.toStringAsFixed(2)}';
  String get formattedDownPayment => '₹${downPayment.toStringAsFixed(2)}';
  String get formattedGivenAsDues => '₹${givenAsDues.toStringAsFixed(2)}';
  String get formattedPendingEMI => '₹${pendingEMI.toStringAsFixed(2)}';
  String get formattedShopId => shopId.isNotEmpty ? shopId : 'N/A';
  String get formattedDate =>
      date != null ? '${date!.day}/${date!.month}/${date!.year}' : 'N/A';

  // 🆕 Format selected date for display
  String get formattedSelectedDate {
    final date = selectedDate.value;
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  var haveChart = false.obs;

  void updateHaveChart(String tab) {
    switch (tab) {
      case 'account-summary':
        haveChart.value = false;
        break;
      case 'pay-bill':
        haveChart.value = true;
        break;
      case 'withdraw':
        haveChart.value = true;
        break;
      case 'commission':
        haveChart.value = true;
        break;
      case 'history':
        haveChart.value = true;
        break;
      case 'emi-settlement':
        haveChart.value = true;
        break;
      case 'gst-ledger':
        haveChart.value = true;
        break;
      default:
        haveChart.value = false;
    }
  }
}
