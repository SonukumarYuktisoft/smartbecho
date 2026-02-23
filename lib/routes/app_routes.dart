class AppRoutes {
  // Authentication Routes
  static const String splash = '/splash';
  static const String welcome = '/welcome';
  static const String onboardingScreen ='/onboarding-screen';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String resetPassword = '/reset-password';
  static const String forgotPasswordOtp = '/forgot-password-OTP';

  static const String verifyEmail = '/verify-email';

  // Main App Routes
  static const String dashboard = '/dashboard';

  //bottom_navigation
  static const String bottomNavigation = '/bottom-navigation';
  
  //inventory managemnet
  static const String inventory_management = '/inventory-management';
  static const String salesStockDashboard = '/sales-stock-dashboard';
  static const String companyStockDetails = '/company-stock-details';
  static const String addNewItem = '/add-new-item';
  static const String productReturns = '/product-returns';

  //customer management
  static const String customerManagement = '/customer-management';
  static const String customerAnalytics = '/customer-analytics';
  static const String customerCardView = '/customer-card-view';
  static const String customerDetails= '/customer-details';
  static const String invoiceDetails= '/invoice-details';


  static const String addCustomer = '/add-customer';




  //bill managemanet
  static const String billHistory = '/bill-history';
  static const String billDetails = '/bill-details';
  static const String addNewStock = '/add-bill';
  static const String stockList = '/stock-list';
  static const String thisMonthAddedStock = '/this-month-added-stock';

  static const String billAnalytics = '/bill-Analytics';
  static const String onlineAddedProducts = '/online-added-products';



  //customer dues management
  static const String customerDuesManagement = '/customer-dues-management';
  static const String todaysRetrievalDues = '/todays-Retrieval-Dues';
  static const String addCustomerDue = '/add-customer-due';


  //account management\
  static const String accountManagement = '/account-management';

  //hsn code management
  static const String hsnCodeManagement = '/hsn-code-management';

  //sales management
  static const String salesManagement = '/sales-management';
  static const String salesDetails = '/sales-detail';
  static const String mobileSalesForm = '/mobiles-sales-form';

  //poster generation
  static const String posterGeneration = '/poster-generation';


  //generate inventory
  static const String generateInventory = '/generate-inventory';


  static const String profile = '/profile';
  static const String settings = '/settings';

  //barcode scanner
  static const String barcodeScanner = '/barcode-scanner';

  //users_management

  static const String usersManagement = '/users-management';

  // pricing_screen
  static const String pricingScreen = '/pricing-screen';
  static const String subscriptionPlanScreen = '/subscription-plan-screen';
  // Error Routes
  static const String notFound = '/404';
  static const String error = '/error';

  // Get all routes as a list for easy reference
  static List<String> get allRoutes => [
    splash,
    welcome,
    login,
    signup,
    resetPassword,
    verifyEmail,
    dashboard,
    profile,
    settings,
    notFound,
    error,
    inventory_management,
    customerManagement,
  ];
}
