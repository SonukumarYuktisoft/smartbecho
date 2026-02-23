import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/routes/app_routes.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/common/build_stats_card.dart';

class DuesSummarySection extends StatelessWidget {
  final CustomerDuesController controller;

  const DuesSummarySection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Obx(() {
        if (controller.isSummaryDataLoading.value) {
          return _buildShimmerCards();
        }

        if (controller.summaryData.value == null) {
          return const SizedBox.shrink();
        }

        final summary = controller.summaryData.value!;

        return ListView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            FeatureVisitor(
                featureKey: FeatureKeys.DUES.viewCurrentMonthDues,

              child: BuildStatsCard(
                label: 'Total Dues\nGiven',
                value: '${summary.totalGiven}',
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.primaryLight,
              ),
            ),
            FeatureVisitor(
                featureKey: FeatureKeys.DUES.viewCurrentMonthDues,
              child: BuildStatsCard(
                label: 'Collected\nby Partial',
                value: '${summary.totalCollected}',
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
            ),
            FeatureVisitor(
                featureKey: FeatureKeys.DUES.viewCurrentMonthDues,
              child: BuildStatsCard(
                label: 'Total\nRemaining',
                value: '${summary.totalRemaining}',
                icon: Icons.error_outline,
                color: Colors.red,
              ),
            ),
            FeatureVisitor(
                featureKey: FeatureKeys.DUES.viewCurrentMonthDues,
              child: BuildStatsCard(
                label: 'This Month\nCollected',
                value: '${summary.thisMonthCollection}',
                icon: Icons.calendar_today_outlined,
                color: Colors.blue,
              ),
            ),
            FeatureVisitor(
                featureKey: FeatureKeys.DUES.viewCurrentMonthDues,
              child: BuildStatsCard(
                label: "Today's\nRetrieval",
                value: controller.retrievalCustomer,
                icon: Icons.people_outline,
                color: Colors.orange,
                isAmount: false,
                onTap: () => Get.toNamed(AppRoutes.todaysRetrievalDues),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildShimmerCards() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          width: 140,
          margin: EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryLight,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}
