// lib/views/account_management/pages/account_summary_refactored.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/account%20management%20controller/account_management_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/views/account%20management/components/account%20summary/account%20summary%20sections/account_analytics_section.dart';
import 'package:smartbecho/views/account%20management/components/account%20summary/account%20summary%20sections/account_cards_section.dart';
import 'package:smartbecho/views/account%20management/components/account%20summary/account%20summary%20sections/account_date_picker_section.dart';
import 'package:smartbecho/views/account%20management/components/account%20summary/account%20summary%20sections/account_loading_section.dart';
import 'package:smartbecho/views/account%20management/components/account%20summary/account%20summary%20sections/account_sales_breakdown_section.dart';
// Import reusable sections

class AccountSummaryRefactored extends StatefulWidget {
  const AccountSummaryRefactored({super.key});

  @override
  State<AccountSummaryRefactored> createState() => _AccountSummaryRefactoredState();
}

class _AccountSummaryRefactoredState extends State<AccountSummaryRefactored> {
  late AccountManagementController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AccountManagementController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show full page loader if loading and no data
      if (controller.isLoading.value) {
        return AccountFullPageLoader(
          selectedDate: controller.formattedSelectedDate,
        );
      }

      // Show error state if error and no data
      if (controller.hasError.value && controller.accountDashboardData.value == null) {
        return AccountErrorState(
          onRetry: controller.clearAllData,
        );
      }

      return AppRefreshIndicator(
        onRefresh: () => controller.fetchAccountSummaryDashboard(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // // 1. Date Picker Section
              // AccountDatePickerSection(
              //   controller: controller,
              //   // onDatePicked: _openDatePicker,
                
              // ),
              // const SizedBox(height: 12),

              // 2. Loading overlay for refresh
              // if (controller.isLoading.value && controller.accountDashboardData.value != null)
              //   const AccountRefreshingOverlay(),

              // 3. Top Cards Section (Opening Balance + Total Sales)
              AccountTopCardsSection(
                controller: controller,
              ),
              const SizedBox(height: 12),

              // 4. Sales Breakdown Section
              AccountSalesBreakdownSection(
                controller: controller,
              ),
              const SizedBox(height: 16),

              // 5. GST Summary Section Header
              AccountSectionHeader(
                title: 'GST Summary',
                icon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 8),

              // GST Summary Section
              AccountGSTSummarySection(
                controller: controller,
              ),
              const SizedBox(height: 16),

              // 6. Account Activity Chart Section Header
              AccountSectionHeader(
                title: 'Account Activity',
                icon: Icons.trending_up_outlined,
              ),
              const SizedBox(height: 8),

              // Account Activity Chart Section
              AccountActivityChartSection(
                controller: controller,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    });
  }
}