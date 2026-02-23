import 'package:flutter/material.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/views/sales%20management/sales%20section/tabs/Dashboard%20tab/sales_dashboard_stats.dart';
import 'package:smartbecho/views/sales%20management/sales%20section/tabs/Dashboard%20tab/sales_recent_sales_section.dart';

class SalesDashboardTab extends StatelessWidget {
  final SalesManagementController controller;

  const SalesDashboardTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: controller.refreshData,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Stats Cards
            SalesDashboardStats(controller: controller),
            SizedBox(height: 16),
            // Recent Sales
            SalesRecentSalesSection(controller: controller),
          ],
        ),
      ),
    );
  }
}
