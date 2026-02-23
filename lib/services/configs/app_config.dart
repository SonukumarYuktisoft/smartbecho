import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:smartbecho/services/shared_preferences_services.dart';

class AppConfig {
  // Private constructor
  AppConfig._();

  // Singleton instance
  static final AppConfig _instance = AppConfig._();
  static AppConfig get instance => _instance;

  // Environment variables getters
  String get baseUrl =>
      dotenv.env['BASE_URL'] ??
      'https://backend-production-91e4.up.railway.app';

  // String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://10.146.180.46:8080';

  // http://192.168.31.119:8080/users/register-with-shop
  bool get isDebugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  String get appName => dotenv.env['APP_NAME'] ?? 'Flutter App';
  String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0';

  // Specific endpoints
  String get loginEndpoint => '$baseUrl/login/jwt';
  String get resetPasswordUrl => '$baseUrl/users/forgot-password';
  String get resetPasswordOTPUrl => '$baseUrl/users/verify-otp-reset-password';
  String get profile => '$baseUrl/users/current-user';
  String get currentShop => '$baseUrl/shops/current?shopId=';
  String get updateProfilePhoto => '$baseUrl/users/profile';
  String get updateProfile => '$baseUrl/users/update';

  String get signupEndpoint => '$baseUrl/users/register-with-shop';
  // String get signupEndpoint => '$baseUrl/users/createUser';
  String get registerEndpoint => '$baseUrl/auth/register';
  String get profileEndpoint => '$baseUrl/user/profile';
  String get logoutEndpoint => '$baseUrl/auth/logout';
  String get todaysalessummary => '$baseUrl/api/sales/today-sales-summary';
  String get todaysalesCard => '$baseUrl/api/sales/today';
  String get stockSummary => '$baseUrl/api/mobiles/stock-details';
  String get monthlyRevenueChart => '$baseUrl/api/sales/revenue/monthly';
  String get topSellingModelsChart =>
      '$baseUrl/api/sales/top-models?month=3&year=2024';
  String get monthlyEmiDuesChart => '$baseUrl/api/dues/monthly-summary';
  String get duesCollectionStatusChart => '$baseUrl/api/dues/overall-summary';

  //inventory management endpoints
  String get getInventoryData => '$baseUrl/inventory/shop';
  String get getInventoryFilters => '$baseUrl/api/mobiles/filters';
  String get getFilteredInventoryData => '$baseUrl/inventory/shop';
  String get getInventorySummaryCards => '$baseUrl/api/mobiles/shop-summary';
  String get getLowStockAlerts => '$baseUrl/inventory/low-stock-alerts';
  String get getCompanyStocks => '$baseUrl/inventory/summary';
  String get addInventoryItem => '$baseUrl/inventory/add';
  String get createProductReturn => '$baseUrl/api/product-returns/create';
  String get getProductReturns => '$baseUrl/api/product-returns/shop';
  String get getProductDelete => '$baseUrl/inventory/delete/';

  //Bill History
  String get getAllBills => '$baseUrl/api/purchase-bills';

  //customer dues management
  String get getAllCustomerDues => '$baseUrl/api/dues/all';
  String get getCustomerDuesAnalytics => '$baseUrl/api/dues/monthly-summary';
  String get getTodaysDueRetrievalDetails =>
      '$baseUrl/api/customers/retriable-today';
  String get addPartialPayment => '$baseUrl/api/dues/partial-payment';
  String get addCustomerDue => '$baseUrl/api/dues/create';
  String get getCustomerData =>
      '$baseUrl/api/customers/shop?page=0&size=150&sort=id';
  String get getCustomerDataDropdown => '$baseUrl/api/customers/dropdown';

  String get getSummaryData => '$baseUrl/api/dues/summary/current-month';
  String get notifyDueCustomer => '$baseUrl/api/dues/notify';

  // sales managment
  String get saleDetail => '$baseUrl/api/sales';

  //customer management endpoints
  String get getMonthlyNewCustomerEndpoint =>
      '$baseUrl/api/customers/count/monthly';
  String get getVillageDistributionEndpoint =>
      '$baseUrl/api/customers/count/location';
  String get getMonthlyRepeatCustomerEndpoint =>
      '$baseUrl/api/sales/count/monthly/repeated';
  String get getTopCustomerOverviewEndpoint =>
      '$baseUrl/api/sales/top-customers';
  String get getTopStatsCardsDataEndpoint => '$baseUrl/api/customers/stats';
  String get addNewCustomer => '$baseUrl/api/customers/create';
  String get getInvoiceDetails => '$baseUrl/api/sales/';
  String get notifyCustomer => "$baseUrl/api/dues/notify";

  //shop management endpoints
  String get createAnotherShop => '$baseUrl/shops/create';
  String get getMyShops => '$baseUrl/shops/my-shops';
  String get switchShop => '$baseUrl/shops/switch';
  String get updateShop => '$baseUrl/shops/update';
  String get getCurrentShop => '$baseUrl/shops/current';

  //Roles
  String get getAllRoles => '$baseUrl/roles/all';
  String get getShopRoles => '$baseUrl/roles/shop';
  String get createRole => '$baseUrl/roles/create';
  String get updateRoles => '$baseUrl/api/roles';
  String get getAssignRole => '$baseUrl/api/roles';
  String get deleteRoles => '$baseUrl/api/roles';

  //Permission Management
  String get getAllPermissions => '$baseUrl/roles/permissions/role/sections';
  String get getPermissionsByRole => '$baseUrl/permissions';
  String get assignPermissionByRole => '$baseUrl/permissions';

  // Internal User Management

  // Add these to AppConfig class
  String get getInternalUsers => "$baseUrl/users/internal-users/shop";
  String get createInternalUser => "$baseUrl/users/create-internal-user";
  String get updateInternalUser => "$baseUrl/users/update";

  // permissionsEndpoint
  String get permissionsEndpoint => '${baseUrl}/features/permissions';
  // Utility methods
  static bool get isSmallScreen => Get.width < 360;
  static bool get isMediumScreen => Get.width >= 360 && Get.width < 400;
  static double get screenWidth => Get.width;
  static double get screenHeight => Get.height;

  //app base requirements
  static RxString shopName = RxString("");
  static RxString shopId = RxString("");

  static RxString userName = RxString("");
  static RxString userId = RxString("");
  static RxString userProfile = RxString("");
  getShopName() async {
    shopName.value = (await SharedPreferencesHelper.getShopStoreName())!;
  }

  getShopId() async {
    shopId.value = (await SharedPreferencesHelper.getShopId())!;
  }

  getUserName() async {
    userName.value = (await SharedPreferencesHelper.getUsername())!;
  }

  getUserId() async {
    userId.value = (await SharedPreferencesHelper.getUserId())!;
  }

  getUserProfile() async {
    userProfile.value = (await SharedPreferencesHelper.getProfilePhotoUrl())!;
  }

  // Debug print method
  void printConfig() {
    if (isDebugMode) {
      print('=== APP CONFIG ===');
      print('Base URL: $baseUrl');
      print('App Version: $appVersion');
      print('Debug Mode: $isDebugMode');
      print('App Name: $appName');
      print('==================');
    }
  }

  String get gstApiBaseUrl => dotenv.env['GST_URL'] ?? '';
  String get gstApiKey => dotenv.env['GST_KEY'] ?? '';

  String get gstValidationUrl => '$gstApiBaseUrl/$gstApiKey';
}
