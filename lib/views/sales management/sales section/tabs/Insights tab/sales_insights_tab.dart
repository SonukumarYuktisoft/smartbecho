
// FILE: lib/views/sales_management/sections/sales_insights_tab.dart
import 'package:flutter/material.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/app_refreshIndicator.dart';
import 'package:smartbecho/views/sales%20management/sales%20section/tabs/Insights%20tab/sales_insights_details.dart';
import 'package:smartbecho/views/sales%20management/sales%20section/tabs/Insights%20tab/sales_insights_overview.dart';

class SalesInsightsTab extends StatelessWidget {
  final SalesManagementController controller;

  const SalesInsightsTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: controller.refreshData,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SalesInsightsOverview(controller: controller),
            SizedBox(height: 16),
            SalesInsightsDetails(controller: controller),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
