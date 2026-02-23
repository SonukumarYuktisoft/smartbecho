import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/controllers/account%20management%20controller/account_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/utils/generic_charts.dart';
import 'package:smartbecho/views/account%20management/components/account%20summary/account%20summary%20sections/account_summary_refactored.dart';
import 'package:smartbecho/views/account%20management/components/account%20summary/account_summary.dart';
import 'package:smartbecho/views/account%20management/components/commision%20received/commision_recieved_analytics.dart';
import 'package:smartbecho/views/account%20management/components/commision%20received/commission_received.dart';
import 'package:smartbecho/views/account%20management/components/emi%20settlement/emi_settlement.dart';
import 'package:smartbecho/views/account%20management/components/emi%20settlement/emi_settlement_analytics.dart';
import 'package:smartbecho/views/account%20management/components/gst%20ledger/gst_ledger_analytics.dart';
import 'package:smartbecho/views/account%20management/components/gst%20ledger/gst_ledger_page.dart';
import 'package:smartbecho/views/account%20management/components/history/history.dart';
import 'package:smartbecho/views/account%20management/components/history/viwe_history_analytics.dart';
import 'package:smartbecho/views/account%20management/components/paybill/pay_bill_analytics.dart';
import 'package:smartbecho/views/account%20management/components/paybill/paybill.dart';
import 'package:smartbecho/views/account%20management/components/withdraw/withdraw.dart';
import 'package:smartbecho/views/account%20management/components/withdraw/withdrawal_analytics.dart';

class AccountManagementScreen extends StatefulWidget {
  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

final AccountManagementController controller =
    Get.find<AccountManagementController>();

class _AccountManagementScreenState extends State<AccountManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<NavItemModel> navItems = [
    NavItemModel(
      id: 'account-summary',
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      color: Color(0xFF6C5CE7),
      hasAnalytics: false,
    ),
    NavItemModel(
      id: 'history',
      label: 'History',
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      color: Color(0xFFFF6B6B),
      hasAnalytics: true,
    ),
    NavItemModel(
      id: 'pay-bill',
      label: 'Pay Bill',
      icon: Icons.payment_outlined,
      activeIcon: Icons.payment,
      color: Color(0xFF51CF66),
      hasAnalytics: true,
    ),
    NavItemModel(
      id: 'withdraw',
      label: 'Withdraw',
      icon: Icons.arrow_downward_outlined,
      activeIcon: Icons.arrow_downward,
      color: Color(0xFFFF9500),
      hasAnalytics: true,
    ),
    NavItemModel(
      id: 'commission',
      label: 'Commission',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      color: Color(0xFF4ECDC4),
      hasAnalytics: true,
    ),
    NavItemModel(
      id: 'emi-settlement',
      label: 'EMI',
      icon: Icons.credit_card_outlined,
      activeIcon: Icons.credit_card,
      color: Color(0xFF9C27B0),
      hasAnalytics: true,
    ),
    NavItemModel(
      id: 'gst-ledger',
      label: 'GST',
      icon: Icons.file_copy,
      activeIcon: Icons.file_copy,
      color: Color.fromARGB(255, 231, 195, 154),
      hasAnalytics: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: navItems.length, vsync: this);

    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.onTabChanged(navItems[_tabController.index].id);
        controller.updateHaveChart(navItems[_tabController.index].id);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Method to show analytics based on current tab
  void _showAnalytics() {
    final currentTab = navItems[_tabController.index];
    
    switch (currentTab.id) {
       case 'history':
        ViweHistoryAnalytics.show(context);
        break;
      case 'pay-bill':
        PayBillAnalyticsBottomSheet.show(context);
        break;
      case 'withdraw':
        WithdrawalAnalyticsBottomSheet.show(context);
        break;
      case 'commission':
        CommissionReceivedAnalyticsBottomSheet.show(context);
        break;
      case 'emi-settlement':
        EmiSettlementAnalyticsBottomSheet.show(context);
        break;
      case 'gst-ledger':
        GstLedgerAnalyticsBottomSheet.show(context);
        break;
      default:
        // No analytics for this tab
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = navItems[_tabController.index];
    
    return Scaffold(
      appBar: CustomAppBar(
        title: "Account Management",
        onPressed: () {
          Get.find<BottomNavigationController>().setIndex(0);
        },
        actionItem: [
          // Show analytics button only for tabs that have analytics
          if (currentTab.hasAnalytics)
            IconButton(
              onPressed: _showAnalytics,
              icon: Icon(
                Icons.analytics_outlined,
                size: 20,
                color: AppColors.backgroundLight,
              ),
              tooltip: 'View Analytics',
            ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 40,
                child: TabBar(
                  isScrollable: true, 
                  dividerColor: Colors.transparent,
                  tabAlignment: TabAlignment.start,
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                  ),
                  labelPadding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 0,
                  ),
                  physics: const ClampingScrollPhysics(),
                  tabs: [
                    _buildTab(
                      icon: Icons.dashboard_outlined,
                      label: 'Dashboard',
                    ),
                    _buildTab(icon: Icons.history_outlined, label: 'History'),
                    _buildTab(
                      icon: Icons.receipt_long_outlined,
                      label: 'Pay Bill',
                    ),
                    _buildTab(icon: Icons.arrow_downward, label: 'Withdraw'),
                    _buildTab(
                      icon: Icons.trending_up_outlined,
                      label: 'Commission',
                    ),
                    _buildTab(
                      icon: Icons.calendar_month_outlined,
                      label: 'EMI',
                    ),
                    _buildTab(icon: Icons.receipt_outlined, label: 'GST'),
                  ],
                ),
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: BouncingScrollPhysics(),
                children: [
                  // _buildAccountSummaryContent(),
                  // AccountSummary(),
                  AccountSummaryRefactored(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: History(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: PayBillsPage(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: WithdrawHistoryPage(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: CommissionReceivedPage(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: EmiSettlementPage(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: GstLedgerHistoryPage(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Tab _buildTab({required IconData icon, required String label}) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

//   Widget _buildTabBar() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         physics: BouncingScrollPhysics(),
//         child: Row(
//           children: List.generate(
//             navItems.length,
//             (index) => _buildTab(navItems[index], index),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTab(NavItemModel item, int index) {
//     return AnimatedBuilder(
//       animation: _tabController,
//       builder: (context, child) {
//         final isActive = _tabController.index == index;

//         return GestureDetector(
//           onTap: () {
//             _tabController.animateTo(index);
//           },
//           child: AnimatedContainer(
//             duration: Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//             margin: EdgeInsets.only(right: 8),
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//             decoration: BoxDecoration(
//               color:
//                   isActive
//                       ? AppColors.primaryLight
//                       : AppColors.cardBackground(context),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color:
//                     isActive
//                         ? AppColors.primaryLight
//                         : AppColors.borderColor(context),
//                 width: 1,
//               ),
//               boxShadow:
//                   isActive
//                       ? [
//                         BoxShadow(
//                           color: AppColors.primaryLight.withValues(alpha: 0.2),
//                           blurRadius: 6,
//                           offset: Offset(0, 3),
//                         ),
//                       ]
//                       : [],
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   isActive ? item.activeIcon : item.icon,
//                   color:
//                       isActive
//                           ? Colors.white
//                           : AppColors.textSecondary(context),
//                   size: 16,
//                 ),
//                 SizedBox(width: 6),
//                 Text(
//                   item.label,
//                   style: TextStyle(
//                     color:
//                         isActive
//                             ? Colors.white
//                             : AppColors.textSecondary(context),
//                     fontSize: 12,
//                     fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

Widget _buildAccountSummaryContent() {
  return Obx(() {
    if (controller.isLoading.value &&
        controller.accountDashboardData.value == null) {
      return _buildFullPageLoader();
    }

    if (controller.hasError.value &&
        controller.accountDashboardData.value == null) {
      return _buildErrorState();
    }

    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),

          // Cash Balance Section
          _buildCashBalanceSection(),

          // SizedBox(height: 16),

          // // // Today's Activity Section
          // // _buildSectionHeader('Today\'s Activity', Icons.today_outlined),
          // // SizedBox(height: 8),
          // // _buildTodayActivityCards(),

          // SizedBox(height: 16),
          SizedBox(height: 12),
          // Sales Breakdown
          _buildSectionHeader('Today’s Sales', Icons.shopping_cart_outlined),
          SizedBox(height: 8),
          _buildSalesBreakdown(),

          // Transactions Section
          // _buildSectionHeader('Transactions', Icons.swap_horiz_outlined),
          // SizedBox(height: 8),
          // _buildTransactionsSection(),

          // SizedBox(height: 16),

          // Financial Overview
          // _buildSectionHeader('Financial Overview', Icons.pie_chart_outline),
          // SizedBox(height: 8),
          // _buildFinancialOverview(),
          SizedBox(height: 16),

          // GST Summary
          _buildSectionHeader('GST Summary', Icons.account_balance_outlined),
          SizedBox(height: 8),
          _buildGSTSummary(),

          SizedBox(height: 16),

          // Account Activity Chart
          _buildSectionHeader('Account Activity', Icons.trending_up_outlined),
          SizedBox(height: 8),
          _buildAccountActivityChart(),

          // SizedBox(height: 16),

          // // Sales Composition
          // _buildSectionHeader('Sales Composition', Icons.donut_small_outlined),
          // SizedBox(height: 8),
          // _buildSalesCompositionChart(),

          // SizedBox(height: 16),
        ],
      ),
    );
  });
}

Widget _buildSectionHeader(String title, IconData icon) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 18),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(Get.context!),
          ),
        ),
      ],
    ),
  );
}

Widget _buildCashBalanceSection() {
  final isDark = AppColors.isDarkMode(Get.context!);
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12),
    padding: EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: AppColors.getPrimaryGradient(isDark),
      borderRadius: BorderRadius.circular(16),
      boxShadow: AppColors.getElevatedShadow(isDark),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opening Balance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  controller.formattedOpeningBalance,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Divider(color: Colors.white.withValues(alpha: 0.3), height: 1),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBalanceItem(
              'Closing Balance',
              controller.formattedClosingBalance,
              Icons.account_balance,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildBalanceItem(String label, String value, IconData icon) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 14),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
            ),
          ),
        ],
      ),
      SizedBox(height: 5),
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

Widget _buildTodayActivityCards() {
  final isDark = AppColors.isDarkMode(Get.context!);
  return Container(
    height: 140,
    child: ListView(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 12),
      children: [
        _buildActivityCard(
          'Total Sales',
          controller.formattedTotalSale,
          Icons.shopping_bag_outlined,
          AppColors.successLight,
          AppColors.statCardGradient(Get.context!, [
            AppColors.successLight,
            AppColors.successLight,
          ]),
          isDark,
        ),
        _buildActivityCard(
          'EMI Collected',
          controller.formattedEmiReceivedToday,
          Icons.payments_outlined,
          AppColors.secondaryLight,
          AppColors.statCardGradient(Get.context!, [
            AppColors.secondaryLight,
            AppColors.secondaryLight,
          ]),
          isDark,
        ),
        _buildActivityCard(
          'Dues Recovered',
          controller.formattedDuesRecovered,
          Icons.money_outlined,
          AppColors.errorLight,
          AppColors.statCardGradient(Get.context!, [
            AppColors.errorLight,
            AppColors.errorLight,
          ]),
          isDark,
        ),
        _buildActivityCard(
          'Commission',
          controller.formattedCommissionReceived,
          Icons.trending_up_outlined,
          AppColors.infoLight,
          AppColors.statCardGradient(Get.context!, [
            AppColors.infoLight,
            AppColors.infoLight,
          ]),
          isDark,
        ),
      ],
    ),
  );
}

Widget _buildActivityCard(
  String title,
  String value,
  IconData icon,
  Color color,
  List<Color> gradient,
  bool isDark,
) {
  return Container(
    width: 150,
    margin: EdgeInsets.only(right: 10),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: isDark ? 0.2 : 0.25),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
Widget _buildSalesBreakdown() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBackground(Get.context!),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.borderColor(Get.context!), width: 1),
      boxShadow: AppColors.getCardShadow(AppColors.isDarkMode(Get.context!)),
    ),
    child: Column(
      children: [
        // 1. Opening Balance
        _buildSalesItem(
          'Opening Balance',
          "+ ${controller.formattedOpeningBalance}",
          Icons.account_balance_wallet,
          Color(0xFF2196F3),
          amountColor: Colors.green,
        ),
        _buildRegularDivider(),

        // 2. EMI Received Today
        _buildSalesItem(
          'EMI Received Today',
          "+ ${controller.formattedEmiReceivedToday}",
          Icons.payments,
          Color(0xFF66BB6A),
          amountColor: Colors.green,
        ),
        _buildRegularDivider(),

        // 3. Dues Recovered
        _buildSalesItem(
          'Dues Recovered',
          "+ ${controller.formattedDuesRecovered}",
          Icons.restore,
          Color(0xFF26A69A),
          amountColor: Colors.green,
        ),
        _buildRegularDivider(),

        // 4. Pay Bills
        _buildSalesItem(
          'Pay Bills',
          "+ ${controller.formattedPayBills}",
          Icons.receipt_long,
          Color(0xFFFF6F00),
          amountColor: Colors.green,
        ),
        _buildRegularDivider(),

        // 5. Withdrawals
        _buildSalesItem(
          'Withdrawals',
          "+ ${controller.formattedWithdrawals}",
          Icons.money_off,
          Color(0xFFD84315),
          amountColor: Colors.green,
        ),
        _buildRegularDivider(),

        // 6. Commission Received
        _buildSalesItem(
          'Commission Received',
          "+ ${controller.formattedCommissionReceived}",
          Icons.card_giftcard,
          Color(0xFF9C27B0),
          amountColor: Colors.green,
        ),

        // Thick divider before Total Sales
        _buildThickDivider(),

        // 7. Total Sales (Sum of above)
        _buildSalesItem(
          'Total Sales',
          "+ ${controller.formattedTotalSale}",
          Icons.shopping_cart,
          Color(0xFF4CAF50),
          amountColor: Colors.green,
          isBold: true,
        ),

        // Thick divider after Total Sales
        _buildThickDivider(),

        // 8. Given as Dues (Deduction)
        _buildSalesItem(
          'Given as Dues',
          "– ${controller.formattedGivenAsDues}",
          Icons.schedule,
          Color(0xFFFFA726),
          amountColor: Colors.redAccent,
        ),
        _buildRegularDivider(),

        // 9. Pending EMI (Deduction)
        _buildSalesItem(
          'Pending EMI',
          "– ${controller.formattedPendingEMI}",
          Icons.pending_outlined,
          Color(0xFFFF7043),
          amountColor: Colors.redAccent,
        ),

        // Thick divider before Closing Balance
        _buildThickDivider(),

        // 10. Closing Balance (Total Sales - Given Dues - Pending EMI)
        _buildSalesItem(
          'Closing Balance',
          controller.closingBalance >= 0
              ? "+ ${controller.formattedClosingBalance}"
              : "– ${controller.formattedClosingBalance.replaceAll('-', '')}",
          Icons.account_balance_wallet_outlined,
          Color(0xFF6A1B9A),
          amountColor: controller.closingBalance >= 0 ? Colors.green : Colors.redAccent,
          isBold: true,
        ),
      ],
    ),
  );
}

Widget _buildSalesItem(
  String label,
  String amount,
  IconData icon,
  Color color, {
  Color amountColor = Colors.black,
  bool isBold = false,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 15 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: AppColors.textPrimary(Get.context!),
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    ),
  );
}

Widget _buildRegularDivider() {
  return Divider(
    height: 20,
    thickness: 1,
    color: Color(0xFFE0E0E0),
  );
}

Widget _buildThickDivider() {
  return Container(
    height: 2,
    margin: EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFFE0E0E0),
          Color(0xFFBDBDBD),
          Color(0xFFE0E0E0),
        ],
      ),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

// Widget _buildSalesItem(
//   String label,
//   String value,
//   IconData icon,
//   Color color, {
//   Color? amountColor,
// }) {
//   return Row(
//     children: [
//       Container(
//         padding: EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Icon(icon, color: Colors.white, size: 18),
//       ),
//       SizedBox(width: 12),
//       Expanded(
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 13,
//             color: AppColors.textSecondary(Get.context!),
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//       Text(
//         value,
//         style: TextStyle(
//           fontSize: 15,
//           fontWeight: FontWeight.bold,
//           color: amountColor ?? Colors.teal,
//         ),
//       ),
//     ],
//   );
// }

Widget _buildTransactionsSection() {
  return GridView.count(
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    crossAxisCount: 2,
    crossAxisSpacing: 10,
    mainAxisSpacing: 10,
    childAspectRatio: 1.5,
    padding: EdgeInsets.symmetric(horizontal: 12),
    children: [
      _buildTransactionCard(
        'Bills Paid',
        controller.formattedPayBills,
        Icons.receipt_long_outlined,
        AppColors.successLight,
      ),
      _buildTransactionCard(
        'Withdrawals',
        controller.formattedWithdrawals,
        Icons.arrow_upward_outlined,
        AppColors.warningLight,
      ),
    ],
  );
}

Widget _buildTransactionCard(
  String title,
  String value,
  IconData icon,
  Color color,
) {
  return Container(
    padding: EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.cardBackground(Get.context!),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      boxShadow: AppColors.getCardShadow(AppColors.isDarkMode(Get.context!)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(Get.context!),
              ),
            ),
            SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary(Get.context!),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildFinancialOverview() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12),
    child: GenericPieChart(
      title: 'Money In vs Money Out',
      payload: controller.moneyInOut,
      showPercentages: true,
      showLegend: true,
      screenWidth: controller.screenWidth,
      isSmallScreen: controller.isSmallScreen,
      chartRadius: 55,
    ),
  );
}

Widget _buildGSTSummary() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBackground(Get.context!),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.borderColor(Get.context!), width: 1),
      boxShadow: AppColors.getCardShadow(AppColors.isDarkMode(Get.context!)),
    ),
    child: Column(
      children: [
        _buildGSTItem(
          'GST on Sales',
          "+ ${controller.formattedGstOnSales}",
          Icons.add_circle_outline,
          Color(0xFF1565C0),
          amountColor: Colors.green,
        ),
        Divider(height: 20, color: Color(0xFFE0E0E0)),

        _buildGSTItem(
          'GST on Purchases',
          "– ${controller.formattedGstOnPurchases}",
          Icons.remove_circle_outline,
          Color(0xFF0277BD),
          amountColor: Colors.redAccent,
        ),
        Divider(height: 20, color: Color(0xFFE0E0E0)),

        _buildGSTItem(
          'Net GST',
          controller.netGst >= 0
              ? "+ ${controller.formattedNetGst}"
              : "– ${controller.formattedNetGst.replaceAll('-', '')}",
          Icons.account_balance,
          Color(0xFF01579B),
          amountColor: controller.netGst >= 0 ? Colors.green : Colors.redAccent,
          isTotal: true,
        ),
      ],
    ),
  );
}

Widget _buildGSTItem(
  String label,
  String value,
  IconData icon,
  Color color, {
  bool isTotal = false,
  Color? amountColor,
}) {
  return Row(
    children: [
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            color:
                isTotal
                    ? AppColors.textPrimary(Get.context!)
                    : AppColors.textSecondary(Get.context!),
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: isTotal ? 17 : 15,
          fontWeight: FontWeight.bold,
          color: amountColor ?? Colors.teal,
        ),
      ),
    ],
  );
}

Widget _buildAccountActivityChart() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBackground(Get.context!),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.borderColor(Get.context!), width: 1),
      boxShadow: AppColors.getCardShadow(AppColors.isDarkMode(Get.context!)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Credit vs Debit',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(Get.context!),
          ),
        ),
        SizedBox(height: 16),
        _buildBarChart(),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildLegendItem('Credit', AppColors.errorLight),
            _buildLegendItem('Debit', AppColors.successLight),
          ],
        ),
      ],
    ),
  );
}

Widget _buildBarChart() {
  final credit = controller.totalCredit;
  final debit = controller.totalDebit;
  final maxValue = credit > debit ? credit : debit;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: _buildBar('Credit', credit, maxValue, AppColors.errorLight),
      ),
      SizedBox(width: 20),
      Expanded(
        child: _buildBar('Debit', debit, maxValue, AppColors.successLight),
      ),
    ],
  );
}

Widget _buildBar(String label, double value, double maxValue, Color color) {
  final percentage = maxValue > 0 ? (value / maxValue) : 0.0;
  final height = 150.0 * percentage;

  return Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        '₹${value.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary(Get.context!),
        ),
      ),
      SizedBox(height: 8),
      Container(
        width: double.infinity,
        height: height < 30 ? 30 : height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
      SizedBox(height: 8),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary(Get.context!),
        ),
      ),
    ],
  );
}

Widget _buildLegendItem(String label, Color color) {
  return Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary(Get.context!),
        ),
      ),
    ],
  );
}

Widget _buildSalesCompositionChart() {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12),
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardBackground(Get.context!),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.borderColor(Get.context!), width: 1),
      boxShadow: AppColors.getCardShadow(AppColors.isDarkMode(Get.context!)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales Payment Breakdown',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(Get.context!),
          ),
        ),
        SizedBox(height: 16),
        _buildProgressBar(
          'Down Payment',
          controller.downPayment,
          controller.totalSale,
          AppColors.successLight,
        ),
        SizedBox(height: 12),
        _buildProgressBar(
          'Given as Dues',
          controller.givenAsDues,
          controller.totalSale,
          AppColors.warningLight,
        ),
        SizedBox(height: 12),
        _buildProgressBar(
          'Pending EMI',
          controller.pendingEMI,
          controller.totalSale,
          AppColors.errorLight,
        ),
      ],
    ),
  );
}

Widget _buildProgressBar(
  String label,
  double value,
  double total,
  Color color,
) {
  final percentage = total > 0 ? (value / total * 100) : 0.0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(Get.context!),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(Get.context!),
            ),
          ),
        ],
      ),
      SizedBox(height: 6),
      Stack(
        children: [
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.borderColor(Get.context!).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          FractionallySizedBox(
            widthFactor: percentage / 100,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.7)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 4),
      Text(
        '₹${value.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary(Get.context!),
        ),
      ),
    ],
  );
}

Widget _buildFullPageLoader() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          color: AppColors.primaryLight,
          strokeWidth: 3,
        ),
        SizedBox(height: 16),
        Text(
          'Loading account data...',
          style: TextStyle(
            color: AppColors.textSecondary(Get.context!),
            fontSize: 14,
          ),
        ),
      ],
    ),
  );
}

Widget _buildErrorState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 56, color: AppColors.errorLight),
        SizedBox(height: 16),
        Text(
          'Failed to load account summary',
          style: TextStyle(
            color: AppColors.errorLight,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Please check your connection and try again',
          style: TextStyle(
            color: AppColors.textSecondary(Get.context!),
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: controller.refreshData,
          icon: Icon(Icons.refresh),
          label: Text('Retry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    ),
  );
}}

class NavItemModel {
  final String id;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Color color;
  final bool hasAnalytics;

  NavItemModel({
    required this.id,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.color,
    this.hasAnalytics = false,
  });
}