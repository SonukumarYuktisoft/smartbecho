// FILE: lib/views/sales_management/sales_management_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/bottom_navigation_screen.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/views/sales%20management/components/Sales%20Insights/sales_insights.dart';
import 'package:smartbecho/views/sales%20management/sales%20section/sales_tabs_section.dart';
import 'package:smartbecho/views/sales%20management/sales%20section/tabs/Dashboard%20tab/sales_dashboard_tab.dart';
import 'package:smartbecho/views/sales%20management/sales%20section/tabs/History%20tab/sales_history_tab.dart';
import 'package:smartbecho/views/sales%20management/sales%20section/tabs/Insights%20tab/sales_insights_tab.dart';

class SalesManagementScreen extends GetView<SalesManagementController> {
  const SalesManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Sales Management",
        onPressed: () {
          Get.find<BottomNavigationController>().setIndex(0);
        },
        actionItem: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              onPressed: () => controller.refreshData(),
              icon: Icon(Icons.refresh),
            ),
          ),
         IconButton(
            onPressed: () {
              Get.to(SalesInsights());
            },
            icon: const Icon(Icons.analytics_outlined),
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Tabs Section
            SalesTabsSection(controller: controller),

            // Tab Content
            Expanded(
              child: Obx(() {
                switch (controller.selectedTab.value) {
                  case 'dashboard':
                    return SalesDashboardTab(controller: controller);
                  case 'history':
                    return SalesHistoryTab(controller: controller);
                  case 'insights':
                    return SalesInsightsTab(controller: controller);
                  default:
                    return SalesDashboardTab(controller: controller);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}