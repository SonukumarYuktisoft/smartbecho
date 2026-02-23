import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/current%20shop%20model/current_shop_model.dart';
import 'package:smartbecho/models/dashboard_models/charts/due_summary_model.dart';
import 'package:smartbecho/models/dashboard_models/charts/monthly_revenue_model.dart';
import 'package:smartbecho/models/dashboard_models/charts/top_selling_models.dart';
import 'package:smartbecho/models/dashboard_models/sales_summary_model.dart';
import 'package:smartbecho/models/dashboard_models/stock_summary_model.dart';
import 'package:smartbecho/models/dashboard_models/today_sales_header_model.dart';
import 'package:smartbecho/models/inventory%20management/inventory_item_model.dart';
import 'package:smartbecho/models/profile/user_profile_model.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/services/api_services.dart';
import 'package:dio/dio.dart' as dio;
import 'package:smartbecho/services/configs/app_config.dart';
import 'package:smartbecho/services/network/connectivity_mixin.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';
import 'package:smartbecho/services/user_profile_service.dart';
import 'package:smartbecho/utils/helper/toast_helper.dart';

// API Response Models with proper null safety
class TodayStatsModel {
  final int availableStock;
  final int todayUnitsSold;
  final double todaySaleAmount;

  TodayStatsModel({
    required this.availableStock,
    required this.todayUnitsSold,
    required this.todaySaleAmount,
  });

  factory TodayStatsModel.fromJson(Map<String, dynamic> json) {
    return TodayStatsModel(
      availableStock: (json['availableStock'] as num?)?.toInt() ?? 0,
      todayUnitsSold: (json['todayUnitsSold'] as num?)?.toInt() ?? 0,
      todaySaleAmount: (json['todaySaleAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DuesOverallSummaryModel {
  final double remainingPercentage;
  final double collected;
  final double collectedPercentage;
  final double remaining;

  DuesOverallSummaryModel({
    required this.remainingPercentage,
    required this.collected,
    required this.collectedPercentage,
    required this.remaining,
  });

  factory DuesOverallSummaryModel.fromJson(Map<String, dynamic> json) {
    return DuesOverallSummaryModel(
      remainingPercentage:
          (json['remainingPercentage'] as num?)?.toDouble() ?? 0.0,
      collected: (json['collected'] as num?)?.toDouble() ?? 0.0,
      collectedPercentage:
          (json['collectedPercentage'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CustomerStatsModel {
  final int totalCustomers;
  final int repeatedCustomers;
  final int newCustomersThisMonth;
  final List<CustomerInfo> repeatedCustomerList;

  CustomerStatsModel({
    required this.totalCustomers,
    required this.repeatedCustomers,
    required this.newCustomersThisMonth,
    required this.repeatedCustomerList,
  });

  factory CustomerStatsModel.fromJson(Map<String, dynamic> json) {
    return CustomerStatsModel(
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? 0,
      repeatedCustomers: (json['repeatedCustomers'] as num?)?.toInt() ?? 0,
      newCustomersThisMonth:
          (json['newCustomersThisMonth'] as num?)?.toInt() ?? 0,
      repeatedCustomerList:
          (json['repeatedCustomerList'] as List<dynamic>?)
              ?.map((x) => CustomerInfo.fromJson(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CustomerInfo {
  final int id;
  final String name;
  final String primaryPhone;
  final String? email;
  final String location;

  CustomerInfo({
    required this.id,
    required this.name,
    required this.primaryPhone,
    this.email,
    required this.location,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      primaryPhone: json['primaryPhone']?.toString() ?? '',
      email: json['email']?.toString(),
      location: json['location']?.toString() ?? '',
    );
  }
}

class LedgerAnalyticsModel {
  final String shopId;
  final String date;
  final double openingBalance;
  final double totalCredit;
  final double totalDebit;
  final double closingBalance;
  final SaleDetails sale;
  final double emiReceivedToday;
  final double duesRecovered;
  final double payBills;
  final double withdrawals;
  final double commissionReceived;
  final GstDetails gst;

  LedgerAnalyticsModel({
    required this.shopId,
    required this.date,
    required this.openingBalance,
    required this.totalCredit,
    required this.totalDebit,
    required this.closingBalance,
    required this.sale,
    required this.emiReceivedToday,
    required this.duesRecovered,
    required this.payBills,
    required this.withdrawals,
    required this.commissionReceived,
    required this.gst,
  });

  factory LedgerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return LedgerAnalyticsModel(
      shopId: json['shopId']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      totalCredit: (json['totalCredit'] as num?)?.toDouble() ?? 0.0,
      totalDebit: (json['totalDebit'] as num?)?.toDouble() ?? 0.0,
      closingBalance: (json['closingBalance'] as num?)?.toDouble() ?? 0.0,
      sale: SaleDetails.fromJson(json['sale'] as Map<String, dynamic>? ?? {}),
      emiReceivedToday: (json['emiReceivedToday'] as num?)?.toDouble() ?? 0.0,
      duesRecovered: (json['duesRecovered'] as num?)?.toDouble() ?? 0.0,
      payBills: (json['payBills'] as num?)?.toDouble() ?? 0.0,
      withdrawals: (json['withdrawals'] as num?)?.toDouble() ?? 0.0,
      commissionReceived:
          (json['commissionReceived'] as num?)?.toDouble() ?? 0.0,
      gst: GstDetails.fromJson(json['gst'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class SaleDetails {
  final double totalSale;
  final double duesSaleDownpayment;
  final double emiSaleDownpayment;
  final double cashSale;
  final double saleRemainingGivenDues;
  final double salePendingEMI;

  SaleDetails({
    required this.totalSale,
    required this.duesSaleDownpayment,
    required this.emiSaleDownpayment,
    required this.cashSale,
    required this.saleRemainingGivenDues,
    required this.salePendingEMI,
  });

  factory SaleDetails.fromJson(Map<String, dynamic> json) {
    return SaleDetails(
      totalSale: (json['totalSale'] as num?)?.toDouble() ?? 0.0,
      duesSaleDownpayment:
          (json['duesSaleDownpayment'] as num?)?.toDouble() ?? 0.0,
      emiSaleDownpayment:
          (json['emiSaleDownpayment'] as num?)?.toDouble() ?? 0.0,
      cashSale: (json['cashSale'] as num?)?.toDouble() ?? 0.0,
      saleRemainingGivenDues:
          (json['saleRemainingGivenDues'] as num?)?.toDouble() ?? 0.0,
      salePendingEMI: (json['salePendingEMI'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class GstDetails {
  final double gstOnSales;
  final double gstOnPurchases;
  final double netGst;

  GstDetails({
    required this.gstOnSales,
    required this.gstOnPurchases,
    required this.netGst,
  });

  factory GstDetails.fromJson(Map<String, dynamic> json) {
    return GstDetails(
      gstOnSales: (json['gstOnSales'] as num?)?.toDouble() ?? 0.0,
      gstOnPurchases: (json['gstOnPurchases'] as num?)?.toDouble() ?? 0.0,
      netGst: (json['netGst'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DashboardController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Animation Controller
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  // Reactive variables
  var selectedIndex = 0.obs;
  var searchQuery = ''.obs;
  var isLoading = false.obs;

  // Profile photo URL stored locally (from SharedPreferences)
  var profilePhotoUrl = ''.obs;
  final RxString userName = ''.obs;
  final RxString userId = ''.obs;
  final RxString shopId = ''.obs;
  final RxString shopGSTNumber = ''.obs;
  final RxBool hasGst = false.obs;
  final RxString shopStoreName = ''.obs;
  final Rx<CurrentShopModel?> currentShop = Rx<CurrentShopModel?>(null);

  final RxBool isAccountSummaryExpanded = true.obs;
  // New reactive variables for API data with proper null safety
  Rxn<TodayStatsModel> todayStats = Rxn<TodayStatsModel>();
  Rxn<DuesOverallSummaryModel> duesOverallSummary =
      Rxn<DuesOverallSummaryModel>();
  Rxn<CustomerStatsModel> customerStats = Rxn<CustomerStatsModel>();
  Rxn<LedgerAnalyticsModel> ledgerAnalytics = Rxn<LedgerAnalyticsModel>();

  // Dashboard data (existing)
  Rxn<SalesSummary> salesSummary = Rxn<SalesSummary>();
  Rxn<StockSummary> stockSummary = Rxn<StockSummary>();
  Rxn<EMISummary> emiSummary = Rxn<EMISummary>();
  RxList<StatItem> topStats = <StatItem>[].obs;
  RxList<QuickActionButton> quickActions = <QuickActionButton>[].obs;

  // API service instance
  final ApiServices _apiService = ApiServices();
  final AppConfig _config = AppConfig.instance;
  RxBool isGridView = true.obs;
  final UserProfileService _userProfileService = Get.put<UserProfileService>(
    UserProfileService(),
  );

  // Global loading states
  RxBool isAllDataLoading = true.obs;
  RxString globalErrorMessage = ''.obs;
  RxBool hasGlobalError = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _initializeData();
    _startAnimations();
    // Fetch from API and save to SharedPreferences, then load locally
    _userProfileService.fetchAndSaveUserProfile().then(
      (_) => loadLocalProfilePhoto(),
    );
    // Load all dashboard data using Future.wait
    fetchAllDashboardData();
  }

  // Load profile photo url from SharedPreferences into reactive var
  Future<void> loadLocalProfilePhoto() async {
    try {
      final url = await SharedPreferencesHelper.getProfilePhotoUrl();

      profilePhotoUrl.value = url ?? '';
    } catch (e) {
      log('Error loading local profile photo: $e');
    }
  }

  void updateProfilePhoto({
    required String url,
    String? shopId,
    String? userId,
  }) {
    profilePhotoUrl.value = url;
    SharedPreferencesHelper.setProfilePhotoUrl(url);
    if (shopId != null && shopId.isNotEmpty) {
      SharedPreferencesHelper.setShopId(shopId);
    }

    if (userId != null && userId.isNotEmpty) {
      SharedPreferencesHelper.setUserId(userId);
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );
  }

  void _startAnimations() {
    animationController.forward();
  }

  void _initializeData() {
    // Initialize quick actions with modern mobile shop actions
    quickActions.value = [
      QuickActionButton(
        title: 'Sell Phone',
        icon: Icons.smartphone_rounded,
        colors: const [Color(0xFF10B981), Color(0xFF34D399)],
        route: AppRoutes.mobileSalesForm,
      ),
      QuickActionButton(
        title: 'Add Stock',
        icon: Icons.add_box_rounded,
        colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        route: AppRoutes.addNewStock,
      ),
      QuickActionButton(
        title: 'EMI Records',
        icon: Icons.receipt_long_rounded,
        colors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        route: '/emi-records',
      ),
      QuickActionButton(
        title: 'Customer Due',
        icon: Icons.schedule_rounded,
        colors: const [Color(0xFFEF4444), Color(0xFFF87171)],
        route: AppRoutes.customerDuesManagement,
      ),
      QuickActionButton(
        title: 'Reports',
        icon: Icons.analytics_rounded,
        colors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
        route: '/reports',
      ),
      QuickActionButton(
        title: 'Sales History',
        icon: Icons.sell,
        colors: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
        route: AppRoutes.salesManagement,
      ),
    ];

    // Initialize EMI summary with default values
    emiSummary.value = EMISummary(
      totalEMIDue: '₹0',
      phonesSoldOnEMI: 0,
      pendingPayments: '₹0',
      emiPhones: {},
    );

    // Initialize top stats with default values
    topStats.value = [
      StatItem(
        title: "Today's Sale (₹)",
        value: "₹0",
        icon: Icons.currency_rupee_rounded,
        colors: const [Color(0xFF10B981), Color(0xFF34D399)],
      ),
      StatItem(
        title: 'Units Sold Today',
        value: "0",
        icon: Icons.inventory_2_rounded,
        colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      ),
      StatItem(
        title: 'Available Stock',
        value: "0",
        icon: Icons.inventory_sharp,
        colors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      ),
    ];
  }

  // Optimized API calls using Future.wait
  Future<void> fetchAllDashboardData() async {
    try {
      isAllDataLoading.value = true;
      hasGlobalError.value = false;
      globalErrorMessage.value = '';

      // Use Future.wait to execute all API calls concurrently
      final results = await Future.wait([
        _fetchTodayStatsAPI(),
        _fetchDuesOverallSummaryAPI(),
        _fetchCustomerStatsAPI(),
        _fetchMonthlyRevenueAPI(),
        _fetchLedgerAnalyticsAPI(),
        _fetchSalesSummaryAPI(),
        _fetchTodaysSalesCardAPI(),
        _fetchStockSummaryAPI(),
        _fetchMonthlyRevenueChartAPI(),
        _fetchTopSellingModelChartAPI(),
        _fetchMonthlyEmiDuesChartAPI(),
        _loadProfileFromAPI(),
        loadCurrentShopFromAPI(),
      ], eagerError: false);

      // Check if any API call failed
      final hasAnyError = results.any((result) => result == false);

      if (hasAnyError) {
        log('Some API calls failed, but continuing with available data');
      }

      // Update UI with loaded data
      _updateTopStatsWithRealData();

      log('All dashboard data loaded successfully');
    } catch (e) {
      hasGlobalError.value = true;
      globalErrorMessage.value = 'Failed to load dashboard data: $e';
      log('Error in fetchAllDashboardData: $e');
    } finally {
      isAllDataLoading.value = false;
    }
  }

  void _updateTopStatsWithRealData() {
    final stats = todayStats.value;
    if (stats != null) {
      topStats.value = [
        StatItem(
          title: "Today's Sale (₹)",
          value: "₹${stats.todaySaleAmount.toStringAsFixed(2)}",
          icon: Icons.currency_rupee_rounded,
          colors: const [Color(0xFF10B981), Color(0xFF34D399)],
        ),
        StatItem(
          title: 'Units Sold Today',
          value: "${stats.todayUnitsSold}",
          icon: Icons.inventory_2_rounded,
          colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        StatItem(
          title: 'Available Stock',
          value: "${stats.availableStock}",
          icon: Icons.inventory_sharp,
          colors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        ),
      ];
    }
  }

  // Individual API methods that return success/failure status
  Future<bool> _fetchTodayStatsAPI() async {
    try {
      final dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/sales/today',
        authToken: true,
      );

      if (response?.statusCode == 200) {
        final responseData = response!.data as Map<String, dynamic>;
        if (responseData['status'] == 'Success') {
          final payload = responseData['payload'] as Map<String, dynamic>?;
          if (payload != null) {
            todayStats.value = TodayStatsModel.fromJson(payload);
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      log('Today Stats API Error: $e');
      return false;
    }
  }

  Future<bool> _fetchDuesOverallSummaryAPI() async {
    try {
      final dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/dues/overall-summary',
        authToken: true,
      );

      if (response?.statusCode == 200) {
        final responseData = response!.data as Map<String, dynamic>;
        if (responseData['status'] == 'Success') {
          final payload = responseData['payload'] as Map<String, dynamic>?;
          if (payload != null) {
            duesOverallSummary.value = DuesOverallSummaryModel.fromJson(
              payload,
            );
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      log('Dues Overall Summary API Error: $e');
      return false;
    }
  }

  Future<bool> _fetchCustomerStatsAPI() async {
    try {
      final dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/customers/stats',
        authToken: true,
      );

      if (response?.statusCode == 200) {
        final responseData = response!.data as Map<String, dynamic>;
        if (responseData['status'] == 'Success') {
          final payload = responseData['payload'] as Map<String, dynamic>?;
          if (payload != null) {
            customerStats.value = CustomerStatsModel.fromJson(payload);
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      log('Customer Stats API Error: $e');
      return false;
    }
  }

  Future<bool> _fetchMonthlyRevenueAPI() async {
    try {
      final dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/sales/revenue/monthly',
        authToken: true,
      );

      if (response?.statusCode == 200) {
        final responseData = response!.data as Map<String, dynamic>;
        if (responseData['status'] == 'Success') {
          final payload = responseData['payload'] as Map<String, dynamic>?;
          if (payload != null && payload.isNotEmpty) {
            monthlyRevenue.value =
                (payload.values.first as num?)?.toDouble() ?? 0.0;
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      log('Monthly Revenue API Error: $e');
      return false;
    }
  }

  Future<bool> _fetchLedgerAnalyticsAPI() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/api/ledger/analytics/daily?date=$today',
        authToken: true,
      );

      if (response?.statusCode == 200) {
        final responseData = response!.data as Map<String, dynamic>;
        if (responseData['status'] == 'Success') {
          final payload = responseData['payload'] as Map<String, dynamic>?;
          if (payload != null) {
            ledgerAnalytics.value = LedgerAnalyticsModel.fromJson(payload);
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      log('Ledger Analytics API Error: $e');
      return false;
    }
  }

  // Additional API methods (keeping existing functionality)
  Future<bool> _fetchSalesSummaryAPI() async {
    try {
      final dio.Response? response = await _apiService.requestGetForApi(
        url: _config.todaysalessummary,
        authToken: true,
      );

      if (response?.statusCode == 200) {
        final responseData = SalesApiResponse.fromJson(response!.data);
        if (responseData.payload != null) {
          salesSummary.value = SalesSummary(
            totalSales: responseData.payload!.totalSaleAmountToday.toString(),
            smartphonesSold: responseData.payload!.totalItemsSoldToday,
            totalTransactions: responseData.payload!.totalTransactionsToday,
            paymentBreakdown: {
              'UPI': PaymentDetail('₹7,20,000', 30),
              'Cash': PaymentDetail('₹7,15,000', 20),
              'EMI': PaymentDetail('₹1,10,000', 15),
              'Card': PaymentDetail('₹15,000', 10),
            },
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      log('Sales Summary API Error: $e');
      return false;
    }
  }

  Future<bool> _fetchTodaysSalesCardAPI() async {
    try {
      final dio.Response? response = await _apiService.requestGetForApi(
        url: _config.todaysalesCard,
        authToken: true,
      );

      if (response?.statusCode == 200) {
        final responseData = TodaysSaleCardModel.fromJson(response!.data);
        // Update with API data if needed
        return true;
      }
      return false;
    } catch (e) {
      log('Todays Sales Card API Error: $e');
      return false;
    }
  }

  Future<bool> _fetchStockSummaryAPI() async {
    try {
      final dio.Response? response = await _apiService.requestGetForApi(
        url: _config.stockSummary,
        authToken: true,
      );

      if (response?.statusCode == 200) {
        final responseData = StockSummaryModel.fromJson(response!.data);
        final companyStockMap = responseData.payload.companyWiseStock.map(
          (key, value) => MapEntry(key, value),
        );

        final lowStockList =
            responseData.payload.lowStockDetails
                .map((e) => '${e.company} - ${e.model} (${e.qty})')
                .toList();

        stockSummary.value = StockSummary(
          totalStock: responseData.payload.totalStock.toString(),
          companyStock: companyStockMap,
          lowStockAlerts: lowStockList,
        );
        return true;
      }
      return false;
    } catch (e) {
      log('Stock Summary API Error: $e');
      return false;
    }
  }

  // Chart API methods
  RxMap<String, double> monthlyRevenueChartPayload = RxMap<String, double>({});
  RxDouble monthlyRevenue = 0.0.obs;

  Future<bool> _fetchMonthlyRevenueChartAPI() async {
    try {
      final dio.Response? response = await _apiService.requestGetForApi(
        url: _config.monthlyRevenueChart,
        authToken: true,
      );

      if (response?.statusCode == 200) {
        final responseData = MonthlyRevenueChartModel.fromJson(response!.data);
        monthlyRevenueChartPayload.value = Map<String, double>.from(
          responseData.payload,
        );
        return true;
      }
      return false;
    } catch (e) {
      log('Monthly Revenue Chart API Error: $e');
      return false;
    }
  }

  RxMap<String, double> topSellingModelChartPayload = RxMap<String, double>({});

  Future<bool> _fetchTopSellingModelChartAPI() async {
    try {
      final dio.Response? response = await _apiService.requestGetForApi(
        url: _config.topSellingModelsChart,
        authToken: true,
      );

      if (response?.statusCode == 200) {
        final responseData = TopSellingModelsResponse.fromJson(response!.data);
        topSellingModelChartPayload.value = Map<String, double>.from(
          responseData.chartData,
        );
        return true;
      }
      return false;
    } catch (e) {
      log('Top Selling Model Chart API Error: $e');
      return false;
    }
  }

  RxMap<String, double> duesCollectionStatusChartPayload =
      RxMap<String, double>({});

  Future<bool> _fetchMonthlyEmiDuesChartAPI() async {
    try {
      final dio.Response? response = await _apiService.requestGetForApi(
        url: _config.duesCollectionStatusChart,
        authToken: true,
      );

      if (response?.statusCode == 200) {
        final responseData = DuesSummaryResponse.fromJson(response!.data);
        duesCollectionStatusChartPayload.value = {
          'collected': responseData.payload.collected,
          'remaining': responseData.payload.remaining,
        };
        return true;
      }
      return false;
    } catch (e) {
      log('Monthly EMI Dues Chart API Error: $e');
      return false;
    }
  }
Future<bool> _loadProfileFromAPI() async {
  try {
    final dio.Response? response = await _apiService.requestGetForApi(
      url: _config.profile,
      authToken: true,
    );

    if (response != null && response.statusCode == 200) {
      final profileResponse = ProfileResponse.fromJson(response.data);
      
      if (profileResponse.payload.userShops.isNotEmpty) {
        final primaryShop = profileResponse.payload.userShops.first.shop;
        
        // Update local storage
        await SharedPreferencesHelper.setShopStoreName(
          primaryShop.shopStoreName,
        );
        await SharedPreferencesHelper.setShopId(
          primaryShop.id.toString(),
        );
        await SharedPreferencesHelper.setUserId(
          profileResponse.payload.id.toString(),
        );
        
        // Update reactive values
        shopId.value = primaryShop.id.toString();
        userId.value = profileResponse.payload.id.toString();
        
        debugPrint('Profile loaded successfully');
      }
       
      return true;
    }
    
    debugPrint('Failed to load profile: Invalid response');
    return false;
  } catch (e) {
    debugPrint('Profile API Error: $e');
    return false;
  }
}
  // ✅ FIXED: Load current shop from API
  Future<bool> loadCurrentShopFromAPI() async {
    try {
      isLoading.value = true;

      final dio.Response? response = await _apiService.requestGetForApi(
        url: '${_config.baseUrl}/shops/current',
        authToken: true,
      );

      if (response != null && response.statusCode == 200) {
        final shopResponse = CurrentShopModel.fromJson(response.data);

        // ✅ Check if payload exists and status is SUCCESS
        if (shopResponse.payload != null &&
            shopResponse.status.toUpperCase() == 'SUCCESS') {
          final payload = shopResponse.payload!;

          // Save to SharedPreferences
          await SharedPreferencesHelper.setShopStoreName(payload.shopStoreName);
          await SharedPreferencesHelper.setShopId(payload.id.toString());
          await SharedPreferencesHelper.setGstNumber(
            payload.hasGstNumber, // ✅ Using the getter that handles null
          );

          // Update observables
          shopId.value = payload.id.toString();
          shopStoreName.value = payload.shopStoreName;
          shopGSTNumber.value = payload.hasGstNumber; // ✅ Never null
          currentShop.value = shopResponse;

          // ✅ Check if GST exists
          hasGst.value = payload.hasGst; // ✅ Using the boolean getter

          log('✅ Shop loaded: ${payload.shopStoreName}');
          log('✅ Shop ID: ${payload.id}');
          log('✅ GST Number: ${payload.hasGstNumber}');
          log('✅ Has GST: ${payload.hasGst}');

          // ✅ Show success toast (no context needed)

          getShopName();
          return true;
        } else {
          log('❌ Shop load failed: ${shopResponse.message}');

          return false;
        }
      } else {
        log('❌ Invalid response or null');

        return false;
      }
    } catch (e) {
      log('❌ Profile API Error: $e');

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Utility methods
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  void updateSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  void handleQuickAction(QuickActionButton quickActions) {
    Color actionColor;
    switch (quickActions.title) {
      case 'Sell Phone':
        actionColor = const Color(0xFF10B981);
        log(quickActions.route);
        Get.toNamed(
          quickActions.route,
          arguments: {
            'inventoryItem': InventoryItem(
              id: 0,
              itemCategory: '',
              logo: '',
              model: '',
              ram: '',
              rom: '',
              color: '',
              sellingPrice: 0.0,
              quantity: 0,
              company: '',
            ),
          },
        );
        // _showSuccessSnackbar('Opening Sell Phone', actionColor);
        break;
      case 'Add Stock':
        actionColor = const Color(0xFF6366F1);
        Get.toNamed(quickActions.route);
        break;
      case 'EMI Records':
        actionColor = const Color(0xFFF59E0B);
        _showSuccessSnackbar('Opening EMI Records', actionColor);
        break;
      case 'Customer Due':
        actionColor = const Color(0xFFEF4444);
        Get.toNamed(quickActions.route);

        break;
      case 'Reports':
        actionColor = const Color(0xFF8B5CF6);
        _showSuccessSnackbar('Opening Reports', actionColor);
        break;
      case 'Sales History':
        actionColor = const Color(0xFF06B6D4);
        Get.toNamed(quickActions.route);

        break;
      case 'Add Product':
        actionColor = const Color(0xFF6366F1);
        _showSuccessSnackbar('Opening Add Product', actionColor);
        break;
      default:
        actionColor = const Color(0xFF6366F1);
        _showSuccessSnackbar('Action: ${quickActions.title}', actionColor);
        break;
    }
  }

  void _showSuccessSnackbar(String message, Color color) {
    ToastHelper.success(message: message)   ;
  }

  Future<void> refreshDashboardData() async {
    await fetchAllDashboardData();
    await loadLocalProfilePhoto();
    if (!hasGlobalError.value) {
      _showSuccessSnackbar(
        'Dashboard refreshed successfully!',
        const Color(0xFF10B981),
      );
    }
  }

  Future<void> getShopName() async {
    final shopName = await SharedPreferencesHelper.getShopStoreName();
    AppConfig.shopName.value = shopName ?? "Smart Becho";
  }

  // Utility getters
  bool get isSmallScreen => Get.width < 360;
  bool get isMediumScreen => Get.width >= 360 && Get.width < 400;
  double get screenWidth => Get.width;
  double get screenHeight => Get.height;

  // Safe getters for accessing API data with null safety
  String get todaysSalesAmount =>
      todayStats.value?.todaySaleAmount.toStringAsFixed(2) ?? "0.00";
  int get todaysUnitsSold => todayStats.value?.todayUnitsSold ?? 0;
  int get availableStock => todayStats.value?.availableStock ?? 0;

  String get collectedDues =>
      duesOverallSummary.value?.collected.toStringAsFixed(2) ?? "0.00";
  String get remainingDues =>
      duesOverallSummary.value?.remaining.toStringAsFixed(2) ?? "0.00";
  double get collectedPercentage =>
      duesOverallSummary.value?.collectedPercentage ?? 0.0;
  double get remainingPercentage =>
      duesOverallSummary.value?.remainingPercentage ?? 0.0;

  int get totalCustomers => customerStats.value?.totalCustomers ?? 0;
  int get repeatedCustomers => customerStats.value?.repeatedCustomers ?? 0;
  int get newCustomersThisMonth =>
      customerStats.value?.newCustomersThisMonth ?? 0;

  String get monthlyRevenueAmount => monthlyRevenue.value.toStringAsFixed(2);
  String get currentBalance =>
      ledgerAnalytics.value?.closingBalance.toStringAsFixed(2) ?? "0.00";

  // Helper method to check if data is available
  bool get hasDataLoaded =>
      todayStats.value != null &&
      duesOverallSummary.value != null &&
      customerStats.value != null;

  // Helper method to check if critical data is missing
  bool get hasCriticalData => todayStats.value != null;
}
