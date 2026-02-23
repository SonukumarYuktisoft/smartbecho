import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/account_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

class AccountSummary extends StatefulWidget {
  const AccountSummary({super.key});

  @override
  State<AccountSummary> createState() => _AccountSummaryState();
}

class _AccountSummaryState extends State<AccountSummary> {
  late AccountManagementController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AccountManagementController>();
  }

  void _openDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryLight,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      controller.updateSelectedDate(pickedDate);
    }
  }

  void _clearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Data'),
        content: Text('Are you sure you want to clear all data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.clearAllData();
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _resetToToday() {
    controller.updateSelectedDate(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 🆕 Show full page loader if loading and no data
      if (controller.isLoading.value &&
          controller.accountDashboardData.value == null) {
        return _buildFullPageLoader();
      }

      // Show error state if error and no data
      if (controller.hasError.value &&
          controller.accountDashboardData.value == null) {
        return _buildErrorState();
      }

      return AppRefreshIndicator(
        onRefresh: () => controller.fetchAccountSummaryDashboard(),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Picker Section with Clear Button
              _buildDatePickerSection(),
              SizedBox(height: 12),

              // Loading overlay for refresh (show only if already has data)
              if (controller.isLoading.value &&
                  controller.accountDashboardData.value != null)
                _buildRefreshingOverlay(),

              _buildTopCards(),
              SizedBox(height: 12),
              _buildTotalSalesPaymentBanner(),
              SizedBox(height: 8),
              _buildSalesBreakdown(),
              SizedBox(height: 16),

              // GST Summary
              _buildSectionHeader(
                'GST Summary',
                Icons.account_balance_outlined,
              ),
              SizedBox(height: 8),
              _buildGSTSummary(),

              SizedBox(height: 16),

              // Account Activity Chart
              _buildSectionHeader(
                'Account Activity',
                Icons.trending_up_outlined,
              ),
              SizedBox(height: 8),
              _buildAccountActivityChart(),

              SizedBox(height: 16),
            ],
          ),
        ),
      );
    });
  }

  // 🆕 Full Page Loader
  Widget _buildFullPageLoader() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated circular progress indicator
            SizedBox(
              width: 70,
              height: 70,
              child: CircularProgressIndicator(
                color: AppColors.primaryLight,
                strokeWidth: 4,
                backgroundColor: AppColors.primaryLight.withOpacity(0.2),
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Loading Account Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(Get.context!),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Fetching your financial data...',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(Get.context!),
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 24),
            // Show selected date during loading
            Obx(() {
              return Text(
                'Date: ${controller.formattedSelectedDate}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // 🆕 Date Picker Section with Clear Button
  Widget _buildDatePickerSection() {
    return Obx(() {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryLight.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // Date and Edit Row
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryLight,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Date',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        controller.formattedSelectedDate,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit Button
                GestureDetector(
                  onTap: _openDatePicker,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppColors.primaryLight,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),
            Divider(color: AppColors.primaryLight.withOpacity(0.2), height: 1),
            SizedBox(height: 12),

            // Clear and Reset Buttons
            Row(
              children: [
                // Reset to Today Button
                Expanded(
                  child: GestureDetector(
                    onTap: _resetToToday,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.today,
                            color: Colors.blue,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Today',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),

                // Clear Data Button
                Expanded(
                  child: GestureDetector(
                    onTap: _clearData,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Clear',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  // 🆕 Refreshing Overlay (Mini loader)
  Widget _buildRefreshingOverlay() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Updating data...',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCards() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Opening Balance Card
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opening Balance',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    controller.formattedOpeningBalance,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildSalesBreakdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(Get.context!),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor(Get.context!),
          width: 1,
        ),
        boxShadow: AppColors.getCardShadow(AppColors.isDarkMode(Get.context!)),
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
                "Today's Sales",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // ===== Column Titles =====
                Row(
                  children: const [
                    Expanded(
                      child: Center(
                        child: Text(
                          "Credits",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF66BB6A),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Debits",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Divider(),

                // ===== Two Column Content =====
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== Credits Column =====
                    Expanded(
                      child: Column(
                        children: [
                          _buildSalesItem(
                            'Opening Balance',
                            "+ ${controller.formattedOpeningBalance}",
                            Icons.account_balance_wallet,
                            const Color(0xFF2196F3),
                            amountColor: Colors.green,
                          ),
                          _buildRegularDivider(),
                          _buildSalesItem(
                            'EMI Received Today',
                            "+ ${controller.formattedEmiReceivedToday}",
                            Icons.payments,
                            const Color(0xFF66BB6A),
                            amountColor: Colors.green,
                          ),
                          _buildRegularDivider(),
                          _buildSalesItem(
                            'Dues Recovered',
                            "+ ${controller.formattedDuesRecovered}",
                            Icons.restore,
                            const Color(0xFF26A69A),
                            amountColor: Colors.green,
                          ),
                          _buildRegularDivider(),
                          _buildSalesItem(
                            'Pay Bills',
                            "+ ${controller.formattedPayBills}",
                            Icons.receipt_long,
                            const Color(0xFFFF6F00),
                            amountColor: Colors.green,
                          ),
                          _buildRegularDivider(),
                          _buildSalesItem(
                            'Commission Received',
                            "+ ${controller.formattedCommissionReceived}",
                            Icons.card_giftcard,
                            const Color(0xFF9C27B0),
                            amountColor: Colors.green,
                          ),

                          _buildRegularDivider(),
                          _buildSalesItem(
                            'Dues Down Payment',
                            "+ ${controller.formattedDownPayment}",
                            Icons.card_giftcard,
                            const Color(0xFF9C27B0),
                            amountColor: Colors.green,
                          ),

                          _buildRegularDivider(),
                          _buildSalesItem(
                            'EMI Down Payment',
                            "+ ${controller.formattedEmiSaleDownpayment}",
                            Icons.card_giftcard,
                            const Color(0xFF9C27B0),
                            amountColor: Colors.green,
                          ),

                          _buildRegularDivider(),
                          _buildSalesItem(
                            'Cash Payment',
                            "+ ${controller.formattedCashSale}",
                            Icons.card_giftcard,
                            const Color(0xFF9C27B0),
                            amountColor: Colors.green,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ===== Vertical Divider =====
                    Container(
                      width: 1,
                      height: 500,
                      color: Colors.grey.shade300,
                    ),

                    const SizedBox(width: 12),

                    // ===== Debits Column =====
                    Expanded(
                      child: Column(
                        children: [
                          _buildSalesItem(
                            'Withdrawals',
                            "– ${controller.formattedWithdrawals}",
                            Icons.money_off,
                            const Color(0xFFD84315),
                            amountColor: Colors.redAccent,
                          ),
                          _buildRegularDivider(),
                          _buildSalesItem(
                            'Given as Dues',
                            "– ${controller.formattedGivenAsDues}",
                            Icons.schedule,
                            const Color(0xFFFFA726),
                            amountColor: Colors.redAccent,
                          ),
                          _buildRegularDivider(),
                          _buildSalesItem(
                            'Pending EMI',
                            "– ${controller.formattedPendingEMI}",
                            Icons.pending_outlined,
                            const Color(0xFFFF7043),
                            amountColor: Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTotalsCreditsAndDebitsRow(),

                const SizedBox(height: 16),

                _buildClosingBalanceCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSalesPaymentBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
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
            controller.formattedTotalSale,
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

  Widget _buildTotalsCreditsAndDebitsRow() {
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
            "Total Credits : ${controller.formattedTotalCredit}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          Text(
            "Total Debits : ${controller.formattedTotalDebit}",
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

  Widget _buildClosingBalanceCard() {
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
                controller.formattedClosingBalance,
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

  Widget _buildRegularDivider() {
    return Divider(height: 20, thickness: 1, color: Color(0xFFE0E0E0));
  }

  Widget _buildGSTSummary() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(Get.context!),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderColor(Get.context!),
          width: 1,
        ),
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
            amountColor:
                controller.netGst >= 0 ? Colors.green : Colors.redAccent,
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
        border: Border.all(
          color: AppColors.borderColor(Get.context!),
          width: 1,
        ),
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
  }
}