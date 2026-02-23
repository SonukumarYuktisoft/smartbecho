import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/account_management_controller.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/views/account%20management/components/account%20summary/account%20summary%20sections/account_sales_breakdown_section.dart';

class AccountSummarySection extends StatelessWidget {
  const AccountSummarySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.find<DashboardController>();
    final AccountManagementController accountController =
        Get.find<AccountManagementController>();
    final isExpanded = dashboardController.isAccountSummaryExpanded.value.obs;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),

      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Obx(() {
        return Column(
          children: [
            // Header
            InkWell(
              onTap: () => isExpanded.value = !isExpanded.value,
              child: Container(
                // padding: const EdgeInsets.symmetric(
                //   horizontal: 16,
                //   vertical: 12,
                // ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Today's Account Summary",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),

            // Content
            if (isExpanded.value)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: // 4. Sales Breakdown Section
                    FeatureVisitor(
                  featureKey: FeatureKeys.ACCOUNTS.getLedgerAnalyticsDaily,

                  child: AccountSalesBreakdownSection(
                    controller: accountController,
                    showOpeningBalance: true,
                  ),
                ),
                // child: FeatureVisitor(
                //   featureKey: FeatureKeys.ACCOUNTS.getLedgerAnalyticsDaily,
                //   child: Padding(
                //     padding: const EdgeInsets.all(12),
                //     child: Column(
                //       children: [
                //         _buildTotalSalesPaymentBanner(accountController),
                //         const SizedBox(height: 8),
                //         // ===== Column Titles =====
                //         Row(
                //           children: const [
                //             Expanded(
                //               child: Center(
                //                 child: Text(
                //                   "Credits",
                //                   style: TextStyle(
                //                     fontWeight: FontWeight.bold,
                //                     fontSize: 16,
                //                     color: const Color(0xFF66BB6A),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             Expanded(
                //               child: Center(
                //                 child: Text(
                //                   "Debits",
                //                   textAlign: TextAlign.end,
                //                   style: TextStyle(
                //                     fontWeight: FontWeight.bold,
                //                     fontSize: 16,
                //                     color: Colors.redAccent,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),

                //         const SizedBox(height: 8),
                //         const Divider(),

                //         // ===== Two Column Content =====
                //         Row(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             // ===== Credits Column =====
                //             Expanded(
                //               child: Column(
                //                 children: [
                //                   _buildSalesItem(
                //                     'Opening Balance',
                //                     "+ ${accountController.formattedOpeningBalance}",
                //                     Icons.account_balance_wallet,
                //                     const Color(0xFF2196F3),
                //                     amountColor: Colors.green,
                //                   ),
                //                   _buildRegularDivider(),
                //                   _buildSalesItem(
                //                     'EMI Received Today',
                //                     "+ ${accountController.formattedEmiReceivedToday}",
                //                     Icons.payments,
                //                     const Color(0xFF66BB6A),
                //                     amountColor: Colors.green,
                //                   ),
                //                   _buildRegularDivider(),
                //                   _buildSalesItem(
                //                     'Dues Recovered',
                //                     "+ ${accountController.formattedDuesRecovered}",
                //                     Icons.restore,
                //                     const Color(0xFF26A69A),
                //                     amountColor: Colors.green,
                //                   ),
                //                   _buildRegularDivider(),
                //                   _buildSalesItem(
                //                     'Pay Bills',
                //                     "+ ${accountController.formattedPayBills}",
                //                     Icons.receipt_long,
                //                     const Color(0xFFFF6F00),
                //                     amountColor: Colors.green,
                //                   ),
                //                   _buildRegularDivider(),
                //                   _buildSalesItem(
                //                     'Commission Received',
                //                     "+ ${accountController.formattedCommissionReceived}",
                //                     Icons.card_giftcard,
                //                     const Color(0xFF9C27B0),
                //                     amountColor: Colors.green,
                //                   ),

                //                   _buildRegularDivider(),
                //                   _buildSalesItem(
                //                     'Dues Down Payment',
                //                     "+ ${accountController.formattedDownPayment}",
                //                     Icons.card_giftcard,
                //                     const Color(0xFF9C27B0),
                //                     amountColor: Colors.green,
                //                   ),

                //                   _buildRegularDivider(),
                //                   _buildSalesItem(
                //                     'EMI Down Payment',
                //                     "+ ${accountController.formattedEmiSaleDownpayment}",
                //                     Icons.card_giftcard,
                //                     const Color(0xFF9C27B0),
                //                     amountColor: Colors.green,
                //                   ),

                //                   _buildRegularDivider(),
                //                   _buildSalesItem(
                //                     'Cash Payment',
                //                     "+ ${accountController.formattedCashSale}",
                //                     Icons.card_giftcard,
                //                     const Color(0xFF9C27B0),
                //                     amountColor: Colors.green,
                //                   ),
                //                 ],
                //               ),
                //             ),

                //             const SizedBox(width: 12),

                //             // ===== Vertical Divider =====
                //             Divider(
                //               height: 20,
                //               thickness: 1,
                //               color: Color(0xFFE0E0E0),
                //             ),
                //             Container(
                //               width: 1,
                //               height: 500,
                //               color: Colors.grey.shade300,
                //             ),

                //             const SizedBox(width: 12),

                //             // ===== Debits Column =====
                //             Expanded(
                //               child: Column(
                //                 children: [
                //                   _buildSalesItem(
                //                     'Withdrawals',
                //                     "– ${accountController.formattedWithdrawals}",
                //                     Icons.money_off,
                //                     const Color(0xFFD84315),
                //                     amountColor: Colors.redAccent,
                //                   ),
                //                   _buildRegularDivider(),
                //                   _buildSalesItem(
                //                     'Given as Dues',
                //                     "– ${accountController.formattedGivenAsDues}",
                //                     Icons.schedule,
                //                     const Color(0xFFFFA726),
                //                     amountColor: Colors.redAccent,
                //                   ),
                //                   _buildRegularDivider(),
                //                   _buildSalesItem(
                //                     'Pending EMI',
                //                     "– ${accountController.formattedPendingEMI}",
                //                     Icons.pending_outlined,
                //                     const Color(0xFFFF7043),
                //                     amountColor: Colors.redAccent,
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ],
                //         ),
                //         const SizedBox(height: 16),
                //         _buildTotalsCreditsAndDebitsRow(accountController),

                //         const SizedBox(height: 16),

                //         _buildClosingBalanceCard(accountController),
                //       ],
                //     ),
                //   ),
                // ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildRegularDivider() {
    return Divider(height: 20, thickness: 1, color: Color(0xFFE0E0E0));
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // Container(
          //   padding: EdgeInsets.all(10),
          //   decoration: BoxDecoration(
          //     color: color.withValues(alpha: 0.1),
          //     borderRadius: BorderRadius.circular(10),
          //   ),
          //   child: Icon(icon, color: color, size: 20),
          // ),
          Row(
            children: [
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
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
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
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 12,
      endIndent: 12,
    );
  }

  Widget _buildThickDivider() {
    return Container(
      height: 8,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[100]!, Colors.grey[200]!, Colors.grey[100]!],
        ),
      ),
    );
  }

  Widget _buildTotalSalesPaymentBanner(
    AccountManagementController accountController,
  ) {
    // Calculate total sales payment (cash received)
    final totalPayment =
        accountController.totalSale -
        accountController.givenAsDues -
        accountController.pendingEMI;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFFF6F00).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total Sales Payment: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5D4037),
            ),
          ),
          Text(
            accountController.formattedTotalSale,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6F00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCreditsAndDebitsRow(
    AccountManagementController accountController,
  ) {
    // Calculate totals
    final totalSalesPayment =
        accountController.totalSale -
        accountController.givenAsDues -
        accountController.pendingEMI;

    final totalCredits =
        totalSalesPayment +
        totalSalesPayment + // counted twice as shown in image
        accountController.commissionReceived +
        accountController.duesRecovered;

    final totalDebits =
        accountController.withdrawals +
        accountController.payBills +
        accountController.givenAsDues;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xFFFF6F00).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total Credits : ${accountController.formattedTotalCredit}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          Text(
            "Total Debits : ${accountController.formattedTotalDebit}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingBalanceCard(
    AccountManagementController accountController,
  ) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Closing Balance:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                accountController.formattedClosingBalance,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
