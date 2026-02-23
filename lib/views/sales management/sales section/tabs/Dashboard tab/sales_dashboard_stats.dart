// FILE: lib/views/sales_management/sections/sales_dashboard_stats.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_history_comtroller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/build_stats_card.dart';

class SalesDashboardStats extends StatelessWidget {
  final SalesManagementController controller;

  const SalesDashboardStats({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          height: 140,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryLight,
            ),
          ),
        );
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        height: 140,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            FeatureVisitor(
                featureKey: FeatureKeys.SALES.statsToday,
              child: BuildStatsCard(
                label: 'Today\'s Sales',
                value: controller.formattedTotalSales,
                icon: Icons.shopping_cart,
                color: Color(0xFF10B981),
              ),
            ),
            FeatureVisitor(
                featureKey: FeatureKeys.SALES.statsToday,
              child: BuildStatsCard(
                label: "Today's EMI Payments",
                value: controller.formattedTotalEmi,
                icon: Icons.schedule,
                color: Color(0xFFEF4444),
              ),
            ),
            FeatureVisitor(
                featureKey: FeatureKeys.SALES.statsToday,
              child: BuildStatsCard(
                label: "Today's UPI Payments",
                value: controller.formattedUpiAmount,
                icon: Icons.qr_code,
                color: Color(0xFF3B82F6),
              ),
            ),
            FeatureVisitor(
                featureKey: FeatureKeys.SALES.statsToday,
              child: BuildStatsCard(
                label: "Today's Cash Payments",
                value: controller.formattedCashAmount,
                icon: Icons.money,
                color: Color(0xFF8B5CF6),
              ),
            ),
            FeatureVisitor(
                featureKey: FeatureKeys.SALES.statsToday,
              child: BuildStatsCard(
                label: "Today's Card Payments",
                value: controller.formattedCardAmount,
                icon: Icons.credit_card,
                color: Color(0xFF06B6D4),
              ),
            ),
            FeatureVisitor(
                featureKey: FeatureKeys.SALES.statsToday,
              child: BuildStatsCard(
                label: "Today's Phones Sold",
                value: controller.totalPhonesSold.toString(),
                icon: Icons.phone_android,
                color: Color(0xFFF59E0B),
                isAmount: false,
              ),
            ),
          ],
        ),
      );
    });
  }
}
