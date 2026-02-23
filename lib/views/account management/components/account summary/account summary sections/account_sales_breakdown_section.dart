// lib/views/account_management/components/sections/account_sales_breakdown_simple_section.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/account_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app%20borders/app_dotted_line.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

// GetX Controller for managing selected tab
class SalesBreakdownController extends GetxController {
  var selectedTab = 'credits'.obs; // 'credits' or 'debits'

  void switchToCredits() => selectedTab.value = 'credits';
  void switchToDebits() => selectedTab.value = 'debits';
}

class AccountSalesBreakdownSection extends StatefulWidget {
  final AccountManagementController controller;
  final bool? showOpeningBalance;

  AccountSalesBreakdownSection({
    Key? key,
    required this.controller,
    this.showOpeningBalance = false,
  }) : super(key: key);

  @override
  State<AccountSalesBreakdownSection> createState() =>
      _AccountSalesBreakdownSectionState();
}

class _AccountSalesBreakdownSectionState
    extends State<AccountSalesBreakdownSection> {
  final SalesBreakdownController breakdownController = Get.put(
    SalesBreakdownController(),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor(context), width: 1),
        boxShadow: AppColors.getCardShadow(AppColors.isDarkMode(context)),
      ),
      child: Column(
        children: [
          // ===== Header =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: const Center(
              child: Text(
                "Today's Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ===== Toggle Buttons =====
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.borderColor(context),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Credits Button
                  Expanded(
                    child: GestureDetector(
                      onTap: breakdownController.switchToCredits,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              breakdownController.selectedTab.value == 'credits'
                                  ? AppColors.primaryLight
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          // border: Border.all(
                          //   color: AppColors.primaryLight,
                          //   width: 1.5,
                          // ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_circle_up,
                              size: 18,
                              color:
                                  breakdownController.selectedTab.value ==
                                          'credits'
                                      ? Colors.white
                                      : AppColors.primaryLight,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Credits',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    breakdownController.selectedTab.value ==
                                            'credits'
                                        ? Colors.white
                                        : AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Debits Button
                  Expanded(
                    child: GestureDetector(
                      onTap: breakdownController.switchToDebits,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              breakdownController.selectedTab.value == 'debits'
                                  ? AppColors.primaryLight
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          // border: Border.all(
                          //   color: AppColors.primaryLight,
                          //   width: 1.5,
                          // ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_circle_down,
                              size: 18,
                              color:
                                  breakdownController.selectedTab.value ==
                                          'debits'
                                      ? Colors.white
                                      : AppColors.primaryLight,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Debits',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    breakdownController.selectedTab.value ==
                                            'debits'
                                        ? Colors.white
                                        : AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== Content Based on Selected Tab =====
          Obx(
            () => SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child:
                  breakdownController.selectedTab.value == 'credits'
                      ? _buildCreditsContent()
                      : _buildDebitsContent(),
            ),
          ),

          const SizedBox(height: 16),

          // ===== Totals Row =====
          _buildTotalsCreditsAndDebitsRow(context),

          const SizedBox(height: 16),

          // ===== Closing Balance =====
          _buildClosingBalanceCard(),

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildCreditsContent() {
    return Column(
      children: [
        if (widget.showOpeningBalance == true) ...[
          _buildSalesItem(
            'Opening Balance',
            "+ ${widget.controller.formattedOpeningBalance}",
            Icons.account_balance_wallet,
            const Color(0xFF2196F3),
            amountColor: Colors.green,
          ),
          const SizedBox(height: 6),
        ],

        _buildSalesItem(
          'Today Dues Recovered',
          "+ ${widget.controller.formattedDuesRecovered}",
          Icons.restore,
          const Color(0xFF26A69A),
          amountColor: Colors.green,
        ),
        const SizedBox(height: 6),

        _buildSalesItem(
          'Today Emi Settled',
          "+ ${widget.controller.formattedEmiReceivedToday}",
          Icons.payments,
          const Color(0xFF66BB6A),
          amountColor: Colors.green,
        ),
        const SizedBox(height: 6),

        _buildSalesItem(
          'Today Commission Received',
          "+ ${widget.controller.formattedCommissionReceived}",
          Icons.card_giftcard,
          const Color(0xFF9C27B0),
          amountColor: Colors.green,
        ),
        const SizedBox(height: 12),

        // ===== Today Total Sale Breakdown =====
        _buildTodayTotalSaleBreakdown(),
      ],
    );
  }

  // New Widget for Sale Breakdown (matching your image)
  Widget _buildTodayTotalSaleBreakdown() {
    double totalSale = widget.controller.totalSale;
    double givenAsDues = widget.controller.saleRemainingGivenDues;
    double remainingEmi = widget.controller.salePendingEMI;
    double totalSaleCollection = widget.controller.todayTotalSaleCollection;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Sale
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today Total Sale',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                widget.controller.formattedTotalSale,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Given as Dues (indented)
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Given as Dues',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  widget.controller.formattedSaleRemainingGivenDues,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Remaining EMI (indented)
          Padding(
            padding: const EdgeInsets.only(left: 30),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Remaining EMI's",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  widget.controller.formattedSalePendingEMI,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Dotted Divider
          SizedBox(
            width: double.infinity,
            height: 1,
            child: CustomPaint(painter: AppDottedLine()),
          ),

          const SizedBox(height: 10),

          // Today Total Sale Collection (Final)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today Total Sale Collection',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                totalSaleCollection >= 0
                    ? '+${totalSaleCollection.toStringAsFixed(2)}'
                    : totalSaleCollection.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: totalSaleCollection >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //   .Today Dues Recovered
  // .Today Emi settled
  // .Today Commision recived
  // .Today total sale
  // - Given as Dues
  // - Remaining Emi's

  // Todays Total sales collections

  // duesRecovered
  // emiReceivedToday
  // commissionReceived
  // totalSale
  // sale RemainingGivenDues
  // salePendingEMI

  // ===== Debits Content =====
  Widget _buildDebitsContent() {
    return Column(
      children: [
        _buildSalesItem(
          'Today Paid Bill',
          "– ${widget.controller.formattedPayBills}",
          Icons.money_off,
          const Color(0xFFD84315),
          amountColor: Colors.redAccent,
        ),
        _buildSalesItem(
          'Today Total Withdrawals',
          "– ${widget.controller.formattedWithdrawals}",
          Icons.money_off,
          const Color(0xFFD84315),
          amountColor: Colors.redAccent,
        ),
        const SizedBox(height: 6),
        _buildSalesItem(
          'Today Direct Given Dues',
          "– ${widget.controller.formattedDirectGivenDues}",
          Icons.schedule,
          const Color(0xFFFFA726),
          amountColor: Colors.redAccent,
        ),
        // const SizedBox(height: 6),
        //  _buildSalesItem(
        //   'Pending EMI',
        //   "– ${widget.controller.formattedPendingEMI}",
        //   Icons.pending_outlined,
        //   const Color(0xFFFF7043),
        //   amountColor: Colors.redAccent,
        // ),
      ],
    );
  }

  // ===== Build Sales Item =====

  Widget _buildSalesItem(
    String label,
    String amount,
    IconData icon,
    Color color, {
    Color amountColor = Colors.black,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Container(
        //   padding: EdgeInsets.all(10),
        //   decoration: BoxDecoration(
        //     color: color.withValues(alpha: 0.1),
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Icon(icon, color: color, size: 20),
        // ),
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
        // Spacer(),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsCreditsAndDebitsRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFF6F00).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Total Credits : ${widget.controller.formattedTotalCredit}",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          Text(
            "Total Debits : ${widget.controller.formattedTotalDebit}",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingBalanceCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: AppColors.primaryLight,
       gradient: LinearGradient(colors: AppColors.primaryGradientLight,
      //  begin: AlignmentGeometry.bottomCenter,
      //  end: AlignmentGeometry.bottomRight,
      //  stops: [12.0,15.0],

      //  tileMode: TileMode.repeated
       ), 
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Opening Balance
          Text(
            'Opening Balance',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.controller.formattedOpeningBalance,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // Credits & Debits
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Credits',
                      style: TextStyle(
                        color: Colors.greenAccent.shade100,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.controller.formattedTotalCredit,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Debits',
                      style: TextStyle(
                        color: Colors.redAccent.shade100,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.controller.formattedTotalDebit,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Dotted Divider
          SizedBox(
            width: double.infinity,
            height: 1,
            child: CustomPaint(painter: AppDottedLine()),
          ),

          const SizedBox(height: 6),

          // Closing Balance
          Text(
            'Closing Balance',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.controller.formattedClosingBalance,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
