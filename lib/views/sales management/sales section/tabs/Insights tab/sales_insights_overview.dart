

// FILE: lib/views/sales_management/sections/sales_insights_overview.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/build_stats_card.dart';

class SalesInsightsOverview extends StatelessWidget {
  final SalesManagementController controller;

  const SalesInsightsOverview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          height: 150,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryLight,
            ),
          ),
        );
      }

      return Container(
        height: 150,
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: [
            BuildStatsCard(
             label:  'This Month\nTotal Revenue',
            value:   controller.formattedTotalSaleAmount,
             icon:  Icons.shopping_cart,
             color:  Color(0xFF10B981),
             hasGrowth: true,
             growthValue: controller.totalSaleAmountGrowth,
            ),
            BuildStatsCard(
           label:    'This Month\nUnits Sold',
           value:    controller.formattedTotalUnitsSold,
            icon:   Icons.phone_android,
            color:   Color(0xFFF59E0B),
             isAmount: false,
               hasGrowth: true,
             growthValue: controller.totalUnitsSoldGrowth,
            ),
            BuildStatsCard(
            label:   'This Month\nEMI Sales',
           value :   controller.formattedTotalEmiSalesAmount,
            icon:   Icons.credit_card,
            color:   Color(0xFF8B5CF6),
             hasGrowth: true,
             growthValue: controller.totalEmiSalesAmountGrowth,
            ),
            BuildStatsCard(
              label:  'This Month\nAvg. Sale Value',
             value:  controller.formattedAverageSaleAmount,
            icon:   Icons.money,
            color:   Color(0xFF00BAD1),
              hasGrowth: true,
             growthValue: controller.averageSaleAmountGrowth,
            ),
          ],
        ),
      );
    });
  }

}
