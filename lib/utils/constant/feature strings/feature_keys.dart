class FeatureKeys {
  // ========================================================================
  // INVENTORY SECTION
  // ========================================================================
  static const INVENTORY = _InventoryKeys();
  
  // ========================================================================
  // BILL HISTORY SECTION (PURCHASE BILLS)
  // ========================================================================
  static const PURCHASE_BILLS = _PurchaseBillKeys();
  
  // ========================================================================
  // DUES SECTION
  // ========================================================================
  static const DUES = _DuesKeys();
  
  // ========================================================================
  // CUSTOMER SECTION
  // ========================================================================
  static const CUSTOMER = _CustomerKeys();
  
  // ========================================================================
  // SALE SECTION
  // ========================================================================
  static const SALES = _SalesKeys();
  
  // ========================================================================
  // ACCOUNTS SECTION (PAY BILLS)
  // ========================================================================
  static const ACCOUNTS = _AccountsKeys();
  
  // ========================================================================
  // WITHDRAWAL SECTION
  // ========================================================================
  static const WITHDRAWAL = _WithdrawalKeys();
  
  // ========================================================================
  // COMMISSION SECTION
  // ========================================================================
  static const COMMISSION = _CommissionKeys();
  
  // ========================================================================
  // EMI SETTLEMENT SECTION
  // ========================================================================
  static const EMI = _EmiKeys();
  
  // ========================================================================
  // GST LEDGER SECTION
  // ========================================================================
  static const GST = _GstKeys();
  
  // ========================================================================
  // HSN CODE SECTION
  // ========================================================================
  static const HSN = _HsnKeys();
  
  // ========================================================================
  // PRODUCT SECTION
  // ========================================================================
  static const PRODUCT = _ProductKeys();
  
  // ========================================================================
  // USER SECTION
  // ========================================================================
  static const USER = _UserKeys();
  
  // ========================================================================
  // ROLE & PERMISSION SECTION
  // ========================================================================
  static const ROLE = _RoleKeys();
  
  // ========================================================================
  // SHOP SECTION
  // ========================================================================
  static const SHOP = _ShopKeys();
  
  // ========================================================================
  // AUTH SECTION
  // ========================================================================
  static const AUTH = _AuthKeys();
  
  // ========================================================================
  // REPORT GENERATION SECTION
  // ========================================================================
  static const REPORT = _ReportKeys();


}

// ============================================================================
// INVENTORY SECTION KEYS
// ============================================================================
class _InventoryKeys {
  const _InventoryKeys();
  
  String get getInventory => 'GET_INVENTORY';
  String get getInventoryById => 'GETBYID_INVENTORY';
  String get createInventory => 'CREATE_INVENTORY';
  String get updateInventory => 'UPDATE_INVENTORY';
  String get deleteInventory => 'DELETE_INVENTORY';
  String get getFilteredInventory => 'GET_FILTERED_INVENTORY';
  String get getInventorySummary => 'GET_INVENTORY_SUMMARY';
  String get getLowStock => 'GET_LOW_STOCK';
  String get getLowStockAlerts => 'GET_LOW_STOCK_ALTERTS';
  String get getModelsCompany => 'GET_MODELS_COMPANY';
  String get getBusinessSummary => 'GET_BUSINESS_SUMMARY';
  String get getItemTypes => 'GET_ITEM_TYPES';
  String get inventoryOverview => 'INVENTORY_OVERVIEW';
  String get getInventoryShop => 'GET_INVENTORY_SHOP';
  String get createProductReturn => 'CREATE_PRODUCT_RETURN';
  String get getProductReturns => 'GET_PRODUCT_RETURNS';
  String get getMobilesShopSummary => 'GET_MOBILES_SHOP_SUMMARY';
  String get getStockDetails => 'GET_STOCK_DETAILS';
  String get getMobilesFilters => 'GET_MOBILES_FILTERS';
  String get getStockItemsAll => 'GET_STOCK_ITEMS_ALL';
  String get getStockItemsStats => 'GET_STOCK_ITEMS_STATS';
  String get getStockSummary => 'GET_STOCK_SUMMARY';
}

// ============================================================================
// PURCHASE BILLS SECTION KEYS
// ============================================================================
class _PurchaseBillKeys {
  const _PurchaseBillKeys();
  
  String get getPurchaseBill => 'GET_PURCHASE_BILL';
  String get getPurchaseBills => 'GET_PURCHASE_BILLS';
  String get getPurchaseBillById => 'GETBYID_PURCHASE_BILL';
  String get createPurchaseBill => 'CREATE_PURCHASE_BILL';
  String get updatePurchaseBill => 'UPDATE_PURCHASE_BILL';
  String get deletePurchaseBill => 'DELETE_PURCHASE_BILL';
  String get monthlyPurchaseBill => 'MONTHLY_PURCHASE_BILL';
  String get getPurchaseBillsMonthlySummary => 'GET_PURCHASE_BILLS_MONTHLY_SUMMARY';
  String get getPurchaseBillsCompanyWise => 'GET_PURCHASE_BILLS_COMPANY_WISE';
  String get getPurchaseBillsStats => 'GET_PURCHASE_BILLS_STATS';
  String get getPurchaseBillsCompanyDropdown => 'GET_PURCHASE_BILLS_COMPANY_DROPDOWN';
}

// ============================================================================
// DUES SECTION KEYS
// ============================================================================
class _DuesKeys {
  const _DuesKeys();
  
  String get viewAllDues => 'VIEW_ALL_DUES';
  String get viewCurrentMonthDues => 'VIEW_CURRENT_MONTH_DUES';
  String get createDues => 'CREATE_DUES';
  String get updateDues => 'UPDATE_DUES';
  String get deleteDues => 'DELETE_DUES';
  String get getDues => 'GET_DUES';
  String get viewDuesById => 'VIEW_DUES_BY_ID';
  String get viewDuesSummary => 'VIEW_DUES_SUMMARY';
  String get viewMonthlyDuesSummary => 'VIEW_MONTHLY_DUES_SUMMARY';
  String get viewOverallDuesSummary => 'VIEW_OVERALL_DUES_SUMMARY';
  String get viewDuesCustomers => 'VIEW_DUES_CUSTOMERS';
  String get viewCustomerDues => 'VIEW_CUSTOMER_DUES';
  String get createPartialPayment => 'CREATE_PARTIAL_PAYMENT';
  String get notifyCustomersDue => 'NOTIFY_CUSTOMERS_DUE';
  String get markDuesPaid => 'MARK_DUES_PAID';
  String get getCustomersRetriableToday => 'GET_CUSTOMERS_RETRIABLE_TODAY';
  String get getInRangeDues => 'GET_IN_RANGE_DUES';
  String get getMonthlyChartDues => 'GET_MONTHLY_CHART_DUES';
  String get getCompanyChartDues => 'GET_COMPANY_CHART_DUES';
  String get exportDuesReport => 'EXPORT_DUES_REPORT';
  String get exportDuesJson => 'EXPORT_DUES_JSON';
}

// ============================================================================
// CUSTOMER SECTION KEYS
// ============================================================================
class _CustomerKeys {
  const _CustomerKeys();
  
  String get getAllCustomer => 'GET_ALL_CUSTOMER';
  String get getCustomersCountMonthly => 'GET_CUSTOMERS_COUNT_MONTHLY';
  String get getByIdCustomer => 'GETBYID_CUSTOMER';
  String get getByPhoneCustomer => 'GETBYPHONE_CUSTOMER';
  String get getAllByShopIdCustomer => 'GETALLBYSHOPID_CUSTOMER';
  String get getCountByLocationCustomer => 'GET_COUNTBY_LOCATION_CUSTOMER';
  String get getMonthlyRepeatedCustomers => 'GET_MONTHLY_REPEATED_CUSTOMERS';
  String get getTopCustomers => 'GET_TOP_CUSTOMERS';
  String get getStatsCustomer => 'GET_STATS_CUSTOMER';
  String get getMonthlyCountCustomer => 'GET_MONTHLY_COUNT_CUSTOMER';
  String get getTodayPayingCustomer => 'GET_TODAY_PAYING_CUSTOMER';
  String get getTodayRetriableCustomer => 'GET_TODAY_RETRIABLE_CUSTOMER';
  String get createCustomer => 'CREATE_CUSTOMER';
  String get updateCustomer => 'UPDATE_CUSTOMER';
  String get deleteCustomer => 'DELETE_CUSTOMER';
  String get getSaleByInvoiceId => 'GET_SALE_BY_INVOICE_ID';
  String get exportAllCustomer => 'EXPORT_ALL_CUSTOMER';
}

// ============================================================================
// SALES SECTION KEYS
// ============================================================================
class _SalesKeys {
  const _SalesKeys();
  
  String get createSale => 'CREATE_SALE';
  String get updateSale => 'UPDATE_SALE';
  String get deleteSale => 'DELETE_SALE';
  String get getByIdSale => 'GETBYID_SALE';
  String get historySale => 'HISTORY_SALE';
  String get getSalesShopHistory => 'GET_SALES_SHOP_HISTORY';
  String get statsToday => 'STATS_TODAY';
  String get saleStatsToday => 'SALE_STATS_TODAY';
  String get saleSummaryToday => 'SALE_SUMMARY_TODAY';
  String get monthlyRevenue => 'MONTHLY_REVENUE';
  String get brandSales => 'BRAND_SALES';
  String get topModels => 'TOP_MODELS';
  String get paymentSalesDistribution => 'PAYMENT_SALES_DISTRIBUTION';
  String get getByCustomerIdSale => 'GETBY_CUSTOMER_ID_SALE';
  String get getSalesState => 'GET_SALES_STATE';
  String get getPaymentAccountTypes => 'GET_PAYMENT_ACCOUNT_TYPES';
  String get getSalesToday => 'GET_SALES_TODAY';
  String get getSalesTodaySalesSummary => 'GET_SALES_TODAY_SALES_SUMMARY';
  String get getTopModels => 'GET_TOP_MODELS';
}

// ============================================================================
// ACCOUNTS SECTION KEYS
// ============================================================================
class _AccountsKeys {
  const _AccountsKeys();
  
  String get createBill => 'CREATE_BILL';
  String get createPayBill => 'CREATE_BILL';
  String get updateBill => 'UPDATE_BILL';
  String get updatePayBill => 'UPDATE_BILL';
  String get deleteBill => 'DELETE_BILL';
  String get deletePayBill => 'DELETE_BILL';
  String get getAllBill => 'GET_ALL_BILL';
  String get getPayBills => 'GET_ALL_BILL';
  String get getByIdBill => 'GETBYID_BILL';
  String get getPayBillById => 'GETBYID_BILL';
  String get getInRangeBill => 'GET_IN_RANGE_BILL';
  String get getPayBillsRange => 'GET_IN_RANGE_BILL';
  String get getMonthlyChartBill => 'GET_MONTHLY_CHART_BILL';
  String get getPayBillsMonthlyChart => 'GET_MONTHLY_CHART_BILL';
  String get getCompanyChartBill => 'GET_COMPANY_CHART_BILL';
  String get getPayBillsCompanyChart => 'GET_COMPANY_CHART_BILL';
  String get getPayBillsCompanies => 'GET_PAY_BILLS_COMPANIES';
  String get getLedgerAnalyticsDaily => 'GET_LEDGER_ANALYTICS_DAILY';
  String get getFinancialSummary => 'GET_FINANCIAL_SUMMARY';
  String get getLedgerFilter => 'GET_LEDGER_FILTER';
  String get getLedgerHistory => 'GET_LEDGER_HISTORY';
}

// ============================================================================
// WITHDRAWAL SECTION KEYS
// ============================================================================
class _WithdrawalKeys {
  const _WithdrawalKeys();
  
  String get createWithdrawal => 'CREATE_WITHDRAWAL';
  String get getWithdrawals => 'GET_WITHDRAWALS';
  String get getWithdrawalsMonthlySummary => 'GET_WITHDRAWALS_MONTHLY_SUMMARY';
  String get updateWithdrawal => 'UPDATE_WITHDRAWAL';
  String get deleteWithdrawal => 'DELETE_WITHDRAWAL';
}

// ============================================================================
// COMMISSION SECTION KEYS
// ============================================================================
class _CommissionKeys {
  const _CommissionKeys();
  
  String get createCommission => 'CREATE_COMMISSION';
  String get getAllCommission => 'GET_ALL_COMMISSION';
  String get getCommissions => 'GET_ALL_COMMISSION';
  String get getByIdCommission => 'GETBYID_COMMISSION';
  String get updateCommission => 'UPDATE_COMMISSION';
  String get deleteCommission => 'DELETE_COMMISSION';
  String get chartMonthlyCommission => 'CHART_MONTHLY_COMMISSION';
  String get getCommissionsMonthlyChart => 'GET_COMMISSIONS_MONTHLY_CHART';
  String get chartCompanyWiseCommission => 'CHART_COMPANYWISE_COMMISSION';
  String get getCommissionsCompanyWiseChart => 'GET_COMMISSIONS_COMPANY_WISE_CHART';
  String get getFinancialSummaryCommission => 'GET_FINANCIAL_SUMMARY_COMMISSION';
  String get getCommissionsFinancialSummary => 'GET_FINANCIAL_SUMMARY_COMMISSION';
  String get getCommissionsCompanies => 'GET_COMMISSIONS_COMPANIES';
}

// ============================================================================
// EMI SECTION KEYS
// ============================================================================
class _EmiKeys {
  const _EmiKeys();
  
  String get getEmiSettlements => 'GET_EMI_SETTLEMENTS';
  String get getEmiSettlementsMonthlySummary => 'GET_EMI_SETTLEMENTS_MONTHLY_SUMMARY';
  String get createEmiSettlement => 'CREATE_EMI_SETTLEMENT';
  String get updateEmiSettlement => 'UPDATE_EMI_SETTLEMENT';
  String get deleteEmiSettlement => 'DELETE_EMI_SETTLEMENT';
}

// ============================================================================
// GST SECTION KEYS
// ============================================================================
class _GstKeys {
  const _GstKeys();
  
  String get getGstLedger => 'GET_GST_LEDGER';
  String get getGstLedgerDropdowns => 'GET_GST_LEDGER_DROPDOWNS';
  String get getGstLedgerMonthlySummary => 'GET_GST_LEDGER_MONTHLY_SUMMARY';
  String get exportGstLedgerGstr1 => 'EXPORT_GST_LEDGER_GSTR1';
  String get exportGstLedgerGstr2 => 'EXPORT_GST_LEDGER_GSTR2';
  String get exportGstLedgerJson => 'EXPORT_GST_LEDGER_JSON';
  String get exportGstLedgerCsv => 'EXPORT_GST_LEDGER_CSV';
  String get exportGstLedgerExcel => 'EXPORT_GST_LEDGER_EXCEL';
  String get exportGstLedgerPdf => 'EXPORT_GST_LEDGER_PDF';
  String get exportGstLedgerJsonSimplified => 'EXPORT_GST_LEDGER_JSON_SIMPLIFIED';
}

// ============================================================================
// HSN CODE SECTION KEYS
// ============================================================================
class _HsnKeys {
  const _HsnKeys();
  
  String get createHsnCode => 'CREATE_HSN_CODE';
  String get updateHsnCode => 'UPDATE_HSN_CODE';
  String get deleteHsnCode => 'DELETE_HSN_CODE';
  String get getHsnCode => 'GET_HSN_CODE';
  String get getHsnCodes => 'GET_HSN_CODE';
  String get getHsnCodesByCategory => 'GET_HSN_CODES_BY_CATEGORY';
  String get autoGenerateHsnCode => 'AUTO_GENERATE_HSN_CODE';
}

// ============================================================================
// PRODUCT SECTION KEYS
// ============================================================================
class _ProductKeys {
  const _ProductKeys();
  
  String get getProducts => 'GET_PRODUCTS';
  String get getProductsFilters => 'GET_PRODUCTS_FILTERS';
  String get createProduct => 'CREATE_PRODUCT';
  String get updateProduct => 'UPDATE_PRODUCT';
  String get deleteProduct => 'DELETE_PRODUCT';
  String get getProductsStatsThisMonth => 'GET_PRODUCTS_STATS_THIS_MONTH';
}

// ============================================================================
// USER SECTION KEYS
// ============================================================================
class _UserKeys {
  const _UserKeys();
  
  String get createUser => 'CREATE_USER';
  String get updateUser => 'UPDATE_USER';
  String get deleteUser => 'DELETE_USER';
  String get getUser => 'GET_USER';
  String get userList => 'USER_LIST';
  String get createInternalUser => 'CREATE_INTERNAL_USER';
  String get updateInternalUser => 'UPDATE_INTERNAL_USER';
  String get deleteInternalUser => 'DELETE_INTERNAL_USER';
  String get getInternalUsers => 'GET_INTERNAL_USERS';
  String get getCurrentUser => 'GET_CURRENT_USER';
  String get updateProfilePhoto => 'UPDATE_PROFILE_PHOTO';
  String get getUserProfile => 'GET_USER_PROFILE';
}

// ============================================================================
// ROLE SECTION KEYS
// ============================================================================
class _RoleKeys {
  const _RoleKeys();
  
  String get createRole => 'CREATE_ROLE';
  String get updateRole => 'UPDATE_ROLE';
  String get deleteRole => 'DELETE_ROLE';
  String get getRole => 'GET_ROLE';
  String get assignRole => 'ASSIGN_ROLE';
  String get getAllRoles => 'GET_ALL_ROLES';
  String get getShopRoles => 'GET_SHOP_ROLES';
  String get getAllPermission => 'GET_ALL_PERMISSION';
  String get getAllPermissions => 'GET_ALL_PERMISSIONS';
  String get getPermissionsByRole => 'GET_PERMISSIONS_BY_ROLE';
  String get assignPermissionByRole => 'ASSIGN_PERMISSION_BY_ROLE';
}

// ============================================================================
// SHOP SECTION KEYS
// ============================================================================
class _ShopKeys {
  const _ShopKeys();
  
  String get createShop => 'CREATE_SHOP';
  String get updateShop => 'UPDATE_SHOP';
  String get deleteShop => 'DELETE_SHOP';
  String get getShop => 'GET_SHOP';
  String get getMyShops => 'GET_MY_SHOPS';
  String get switchShop => 'SWITCH_SHOP';
  String get getCurrentShop => 'GET_CURRENT_SHOP';
  String get getShopSettings => 'GET_SHOP_SETTINGS';
  String get updateShopSettings => 'UPDATE_SHOP_SETTINGS';
}

// ============================================================================
// AUTH SECTION KEYS
// ============================================================================
class _AuthKeys {
  const _AuthKeys();
  
  String get login => 'LOGIN';
  String get resetPassword => 'RESET_PASSWORD';
  String get verifyOtpResetPassword => 'VERIFY_OTP_RESET_PASSWORD';
  String get logout => 'LOGOUT';
}

// ============================================================================
// REPORT SECTION KEYS
// ============================================================================
class _ReportKeys {
  const _ReportKeys();
  
  String get generateReport => 'GENERATE_REPORT';
  String get generateInvoice => 'GENERATE_INVOICE';
  String get generateBill => 'GENERATE_BILL';
}

// ============================================================================
// SECTION KEYS - Organized by category
// ============================================================================
class SectionKeys {
  
  static const String inventorySection = 'INVENTORY_SECTION';
  static const String billHistorySection = 'BILL_HISTORY_SECTION';
  static const String duesSection = 'DUES_SECTION';
  static const String customerSection = 'CUSTOMER_SECTION';
  static const String saleSection = 'SALE_SECTION';
  static const String accountsSection = 'ACCOUNTS_SECTION';
  static const String withdrawalSection = 'WITHDRAWAL_SECTION';
  static const String commissionSection = 'COMMISSION_SECTION';
  static const String emiSection = 'EMI_SECTION';
  static const String gstSection = 'GST_SECTION';
  static const String hsnCodeSection = 'HSN_CODE_SECTION';
  static const String productSection = 'PRODUCT_SECTION';
  static const String userSection = 'USER_SECTION';
  static const String roleSection = 'ROLE_SECTION';
  static const String shopSection = 'SHOP_SECTION';
  static const String authSection = 'AUTH_SECTION';
  static const String reportSection = 'REPORT_SECTION';

  static const List<String> allSections = [
    inventorySection,
    billHistorySection,
    duesSection,
    customerSection,
    saleSection,
    accountsSection,
    withdrawalSection,
    commissionSection,
    emiSection,
    gstSection,
    hsnCodeSection,
    productSection,
    userSection,
    roleSection,
    shopSection,
    authSection,
    reportSection,
  ];
}