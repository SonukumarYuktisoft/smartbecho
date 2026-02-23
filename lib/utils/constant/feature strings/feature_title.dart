class FeatureTitles {
  // ========================================================================
  // INVENTORY SECTION TITLES
  // ========================================================================
  static const Map<String, String> _inventoryTitles = {
    'GET_INVENTORY':
      'Manage all your inventory in one place and avoid stock confusion.',

  'GETBYID_INVENTORY':
      'View complete item details to track stock accurately.',

  'CREATE_INVENTORY':
      'Add new stock easily and keep your inventory always updated.',

  'UPDATE_INVENTORY':
      'Update stock instantly to avoid mismatch and losses.',

  'DELETE_INVENTORY':
      'Remove incorrect or old stock entries and keep data clean.',

  'GET_FILTERED_INVENTORY':
      'Filter inventory smartly to find products faster and save time.',

  'GET_INVENTORY_SUMMARY':
      'Get clear stock analytics to plan purchases and sales better.',

  'GET_LOW_STOCK':
      'Never run out of stock by tracking low inventory in advance.',

  'GET_LOW_STOCK_ALTERTS':
      'Receive real-time alerts so you can restock before it’s too late.',

  'GET_MODELS_COMPANY':
      'Analyze company-wise models to focus on high-performing brands.',

  'GET_BUSINESS_SUMMARY':
      'See overall business performance and stock health in one view.',

  'GET_ITEM_TYPES':
      'Organize products by categories for faster management.',

  'INVENTORY_OVERVIEW':
      'Get a quick dashboard view of your entire inventory status.',

  'GET_INVENTORY_SHOP':
      'Manage shop-wise inventory efficiently without manual tracking.',

  'CREATE_PRODUCT_RETURN':
      'Handle product returns smoothly and keep stock records accurate.',

  'GET_PRODUCT_RETURNS':
      'Track return history to reduce losses and identify issues.',

  'GET_MOBILES_SHOP_SUMMARY':
      'Understand mobile stock position clearly for better planning.',

  'GET_STOCK_DETAILS':
      'Access detailed stock information to avoid errors and confusion.',

  'GET_MOBILES_FILTERS':
      'Search and filter mobile stock quickly to save valuable time.',

  'GET_STOCK_ITEMS_ALL':
      'View complete stock list and stay fully in control.',

  'GET_STOCK_ITEMS_STATS':
      'Analyze stock statistics to improve inventory decisions.',

  'GET_STOCK_SUMMARY':
      'Get a quick overview of stock levels without extra effort.',

  };

  // ========================================================================
  // PURCHASE BILLS SECTION TITLES
  // ========================================================================
  static const Map<String, String> _purchaseBillTitles = {
    'GET_PURCHASE_BILL': 'Purchase Bills',
    'GET_PURCHASE_BILLS': 'All Purchase Records',
    'GETBYID_PURCHASE_BILL': 'Bill Details',
    'CREATE_PURCHASE_BILL': 'Create Purchase Bill',
    'UPDATE_PURCHASE_BILL': 'Edit Purchase Bill',
    'DELETE_PURCHASE_BILL': 'Delete Purchase Bill',
    'MONTHLY_PURCHASE_BILL': 'Monthly Purchase Summary',
    'GET_PURCHASE_BILLS_MONTHLY_SUMMARY': 'Purchase Trends',
    'GET_PURCHASE_BILLS_COMPANY_WISE': 'Vendor-wise Analysis',
    'GET_PURCHASE_BILLS_STATS': 'Purchase Statistics',
    'GET_PURCHASE_BILLS_COMPANY_DROPDOWN': 'Vendor List',
  };

  // ========================================================================
  // DUES SECTION TITLES
  // ========================================================================
  static const Map<String, String> _duesTitles = {
    'VIEW_ALL_DUES': 'All Outstanding Dues',
    'VIEW_CURRENT_MONTH_DUES': 'This Month\'s Dues',
    'CREATE_DUES': 'Add New Due',
    'UPDATE_DUES': 'Update Due Record',
    'DELETE_DUES': 'Remove Due',
    'GET_DUES': 'Dues Management',
    'VIEW_DUES_BY_ID': 'Due Details',
    'VIEW_DUES_SUMMARY': 'Dues Overview',
    'VIEW_MONTHLY_DUES_SUMMARY': 'Monthly Dues Report',
    'VIEW_OVERALL_DUES_SUMMARY': 'Complete Dues Analytics',
    'VIEW_DUES_CUSTOMERS': 'Customers with Dues',
    'VIEW_CUSTOMER_DUES': 'Customer Due History',
    'CREATE_PARTIAL_PAYMENT': 'Partial Payment Collection',
    'NOTIFY_CUSTOMERS_DUE': 'Send Payment Reminders',
    'MARK_DUES_PAID': 'Mark as Paid',
    'GET_CUSTOMERS_RETRIABLE_TODAY': 'Today\'s Follow-ups',
    'GET_IN_RANGE_DUES': 'Dues by Date Range',
    'GET_MONTHLY_CHART_DUES': 'Monthly Dues Trends',
    'GET_COMPANY_CHART_DUES': 'Company-wise Dues',
    'EXPORT_DUES_REPORT': 'Export Dues Report',
    'EXPORT_DUES_JSON': 'Export Dues Data',
  };

  // ========================================================================
  // CUSTOMER SECTION TITLES
  // ========================================================================
  static const Map<String, String> _customerTitles = {
    'GET_ALL_CUSTOMER': 'All Customers',
    'GET_CUSTOMERS_COUNT_MONTHLY': 'Customer Growth Analytics',
    'GETBYID_CUSTOMER': 'Customer Profile',
    'GETBYPHONE_CUSTOMER': 'Search by Phone',
    'GETALLBYSHOPID_CUSTOMER': 'Shop Customers',
    'GET_COUNTBY_LOCATION_CUSTOMER': 'Location-based Analytics',
    'GET_MONTHLY_REPEATED_CUSTOMERS': 'Repeat Customer Analysis',
    'GET_TOP_CUSTOMERS': 'Top Customers List',
    'GET_STATS_CUSTOMER': 'Customer Statistics',
    'GET_MONTHLY_COUNT_CUSTOMER': 'Monthly Customer Count',
    'GET_TODAY_PAYING_CUSTOMER': 'Today\'s Payments',
    'GET_TODAY_RETRIABLE_CUSTOMER': 'Today\'s Retry List',
    'CREATE_CUSTOMER': 'Add New Customer',
    'UPDATE_CUSTOMER': 'Edit Customer Details',
    'DELETE_CUSTOMER': 'Remove Customer',
    'GET_SALE_BY_INVOICE_ID': 'Invoice Details',
    'EXPORT_ALL_CUSTOMER': 'Export Customer Data',
  };

  // ========================================================================
  // SALES SECTION TITLES
  // ========================================================================
  static const Map<String, String> _salesTitles = {
    'CREATE_SALE':
        'Create sales faster, reduce manual work, and serve customers smoothly.',

    'UPDATE_SALE':
        'Easily edit sales records to avoid mistakes and keep data accurate.',

    'DELETE_SALE':
        'Fix wrong entries instantly and maintain clean sales records.',

    'GETBYID_SALE':
        'View complete sale details anytime for better tracking and clarity.',

    'HISTORY_SALE':
        'Access full sales history to understand business trends over time.',

    'GET_SALES_SHOP_HISTORY':
        'Analyze all-time sales data to plan smarter business decisions.',

    'STATS_TODAY':
        'Track today’s performance in real time and stay in control.',

    'SALE_STATS_TODAY':
        'Understand today’s sales numbers clearly and act faster.',

    'SALE_SUMMARY_TODAY':
        'Get a quick snapshot of today’s sales without digging into data.',

    'MONTHLY_REVENUE':
        'See monthly revenue growth, identify profit patterns, and plan ahead.',

    'BRAND_SALES':
        'Know which brands perform best and focus on high-profit products.',

    'TOP_MODELS':
        'Identify best-selling products to boost sales and reduce dead stock.',

    'PAYMENT_SALES_DISTRIBUTION':
        'Understand customer payment preferences and manage cash flow better.',

    'GETBY_CUSTOMER_ID_SALE':
        'Track customer buying behavior to improve retention and loyalty.',

    'GET_SALES_STATE':
        'Get a clear overview of overall sales health in one place.',

    'GET_PAYMENT_ACCOUNT_TYPES':
        'Manage and organize all payment methods easily.',

    'GET_SALES_TODAY':
        'Monitor today’s sales live and avoid end-of-day surprises.',

    'GET_SALES_TODAY_SALES_SUMMARY':
        'Save time with an instant daily sales overview.',

    'GET_TOP_MODELS':
        'Discover trending products and sell what customers want most.',
  };

  // ========================================================================
  // ACCOUNTS SECTION TITLES
  // ========================================================================
  static const Map<String, String> _accountsTitles = {
    'CREATE_BILL': 'Create Payment Bill',
    'UPDATE_BILL': 'Update Payment Bill',
    'DELETE_BILL': 'Delete Payment Bill',
    'GET_ALL_BILL': 'All Payment Bills',
    'GETBYID_BILL': 'Bill Details',
    'GET_IN_RANGE_BILL': 'Bills by Date Range',
    'GET_MONTHLY_CHART_BILL': 'Monthly Payment Trends',
    'GET_COMPANY_CHART_BILL': 'Vendor Payment Analytics',
    'GET_PAY_BILLS_COMPANIES': 'Vendor Payment Summary',
    'GET_LEDGER_ANALYTICS_DAILY': 'Daily Financial Insights',
    'GET_FINANCIAL_SUMMARY': 'Complete Financial Overview',
    'GET_LEDGER_FILTER': 'Advanced Ledger Filters',
    'GET_LEDGER_HISTORY': 'Transaction History',
  };

  // ========================================================================
  // WITHDRAWAL SECTION TITLES
  // ========================================================================
  static const Map<String, String> _withdrawalTitles = {
    'CREATE_WITHDRAWAL': 'Record Withdrawal',
    'GET_WITHDRAWALS': 'All Withdrawals',
    'GET_WITHDRAWALS_MONTHLY_SUMMARY': 'Monthly Withdrawal Report',
    'UPDATE_WITHDRAWAL': 'Update Withdrawal',
    'DELETE_WITHDRAWAL': 'Delete Withdrawal',
  };

  // ========================================================================
  // COMMISSION SECTION TITLES
  // ========================================================================
  static const Map<String, String> _commissionTitles = {
    'CREATE_COMMISSION': 'Add Commission Record',
    'GET_ALL_COMMISSION': 'All Commissions',
    'GETBYID_COMMISSION': 'Commission Details',
    'UPDATE_COMMISSION': 'Update Commission',
    'DELETE_COMMISSION': 'Delete Commission',
    'GET_COMMISSIONS_MONTHLY_CHART': 'Monthly Commission Trends',
    'GET_COMMISSIONS_COMPANY_WISE_CHART': 'Company Commission Analytics',
    'GET_FINANCIAL_SUMMARY_COMMISSION': 'Commission Financial Summary',
    'GET_COMMISSIONS_COMPANIES': 'Commission by Vendor',
  };

  // ========================================================================
  // EMI SECTION TITLES
  // ========================================================================
  static const Map<String, String> _emiTitles = {
    'GET_EMI_SETTLEMENTS': 'EMI Settlements',
    'GET_EMI_SETTLEMENTS_MONTHLY_SUMMARY': 'Monthly EMI Summary',
    'CREATE_EMI_SETTLEMENT': 'Create EMI Settlement',
    'UPDATE_EMI_SETTLEMENT': 'Update EMI Record',
    'DELETE_EMI_SETTLEMENT': 'Delete EMI Settlement',
  };

  // ========================================================================
  // GST SECTION TITLES
  // ========================================================================
  static const Map<String, String> _gstTitles = {
    'GET_GST_LEDGER': 'GST Ledger',
    'GET_GST_LEDGER_DROPDOWNS': 'GST Filter Options',
    'GET_GST_LEDGER_MONTHLY_SUMMARY': 'Monthly GST Summary',
    'EXPORT_GST_LEDGER_GSTR1': 'Export GSTR-1 Report',
    'EXPORT_GST_LEDGER_GSTR2': 'Export GSTR-2 Report',
    'EXPORT_GST_LEDGER_JSON': 'Export GST as JSON',
    'EXPORT_GST_LEDGER_CSV': 'Export GST as CSV',
    'EXPORT_GST_LEDGER_EXCEL': 'Export GST as Excel',
    'EXPORT_GST_LEDGER_PDF': 'Export GST as PDF',
    'EXPORT_GST_LEDGER_JSON_SIMPLIFIED': 'Export Simplified GST',
  };

  // ========================================================================
  // HSN CODE SECTION TITLES
  // ========================================================================
  static const Map<String, String> _hsnTitles = {
    'CREATE_HSN_CODE': 'Add HSN Code',
    'UPDATE_HSN_CODE': 'Update HSN Code',
    'DELETE_HSN_CODE': 'Delete HSN Code',
    'GET_HSN_CODE': 'HSN Code Management',
    'GET_HSN_CODES_BY_CATEGORY': 'HSN by Category',
    'AUTO_GENERATE_HSN_CODE': 'Auto-generate HSN Codes',
  };

  // ========================================================================
  // PRODUCT SECTION TITLES
  // ========================================================================
  static const Map<String, String> _productTitles = {
    'GET_PRODUCTS': 'All Products',
    'GET_PRODUCTS_FILTERS': 'Advanced Product Search',
    'CREATE_PRODUCT': 'Add New Product',
    'UPDATE_PRODUCT': 'Edit Product',
    'DELETE_PRODUCT': 'Remove Product',
    'GET_PRODUCTS_STATS_THIS_MONTH': 'Monthly Product Stats',
  };

  // ========================================================================
  // USER SECTION TITLES
  // ========================================================================
  static const Map<String, String> _userTitles = {
    'CREATE_USER': 'Add New User',
    'UPDATE_USER': 'Update User Profile',
    'DELETE_USER': 'Remove User',
    'GET_USER': 'User Details',
    'USER_LIST': 'All Users',
    'CREATE_INTERNAL_USER': 'Add Staff Member',
    'UPDATE_INTERNAL_USER': 'Edit Staff Details',
    'DELETE_INTERNAL_USER': 'Remove Staff Member',
    'GET_INTERNAL_USERS': 'Staff Management',
    'GET_CURRENT_USER': 'My Profile',
    'UPDATE_PROFILE_PHOTO': 'Update Profile Picture',
    'GET_USER_PROFILE': 'View Profile',
  };

  // ========================================================================
  // ROLE & PERMISSION SECTION TITLES
  // ========================================================================
  static const Map<String, String> _roleTitles = {
    'CREATE_ROLE': 'Create New Role',
    'UPDATE_ROLE': 'Update Role Permissions',
    'DELETE_ROLE': 'Delete Role',
    'GET_ROLE': 'Role Management',
    'ASSIGN_ROLE': 'Assign Role to User',
    'GET_ALL_ROLES': 'All Roles',
    'GET_SHOP_ROLES': 'Shop Roles',
    'GET_ALL_PERMISSION': 'All Permissions',
    'GET_ALL_PERMISSIONS': 'Permission List',
    'GET_PERMISSIONS_BY_ROLE': 'Role Permissions',
    'ASSIGN_PERMISSION_BY_ROLE': 'Manage Permissions',
  };

  // ========================================================================
  // SHOP SECTION TITLES
  // ========================================================================
  static const Map<String, String> _shopTitles = {
    'CREATE_SHOP': 'Create New Shop',
    'UPDATE_SHOP': 'Edit Shop Details',
    'DELETE_SHOP': 'Remove Shop',
    'GET_SHOP': 'Shop Information',
    'GET_MY_SHOPS': 'My Shops',
    'SWITCH_SHOP': 'Switch Shop',
    'GET_CURRENT_SHOP': 'Current Shop Details',
    'GET_SHOP_SETTINGS': 'Shop Settings',
    'UPDATE_SHOP_SETTINGS': 'Update Shop Settings',
  };

  // ========================================================================
  // REPORT SECTION TITLES
  // ========================================================================
  static const Map<String, String> _reportTitles = {
    'GENERATE_REPORT': 'Generate Custom Report',
    'GENERATE_INVOICE': 'Generate Invoice',
    'GENERATE_BILL': 'Generate Bill',
  };

  // ========================================================================
  // MASTER TITLES MAP - Combine all sections
  // ========================================================================
  static final Map<String, String> _allTitles = {
    ..._inventoryTitles,
    ..._purchaseBillTitles,
    ..._duesTitles,
    ..._customerTitles,
    ..._salesTitles,
    ..._accountsTitles,
    ..._withdrawalTitles,
    ..._commissionTitles,
    ..._emiTitles,
    ..._gstTitles,
    ..._hsnTitles,
    ..._productTitles,
    ..._userTitles,
    ..._roleTitles,
    ..._shopTitles,
    ..._reportTitles,
  };

  // ========================================================================
  // PUBLIC METHOD - Get title by feature key
  // ========================================================================

  /// Returns the user-friendly title for a given feature key
  /// Returns empty string if key not found
  static String getTitle(String featureKey) {
    return _allTitles[featureKey] ?? '';
  }

  /// Check if a feature key has a title defined
  static bool hasTitle(String featureKey) {
    return _allTitles.containsKey(featureKey);
  }

  /// Get all available feature titles
  static Map<String, String> getAllTitles() {
    return Map.unmodifiable(_allTitles);
  }
}
