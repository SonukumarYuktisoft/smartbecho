import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Statistics",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: FeatureVisitor(
                    featureKey: FeatureKeys.SALES.statsToday,
                    child: _buildQuickStat(
                      label: "Today's Revenue",
                      value: AppFormatterHelper.amountFormatter(
                        double.parse(controller.todaysSalesAmount),
                      ),
                      color: const Color(0xFF10B981),
                      icon: Icons.bar_chart_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FeatureVisitor(
                    featureKey: FeatureKeys.SALES.statsToday,
                    child: _buildQuickStat(
                      label: "Units Sold",
                      value: AppFormatterHelper.amountFormatter(
                        controller.todaysUnitsSold,
                      ),
                      color: const Color(0xFF6366F1),
                      icon: Icons.inventory,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FeatureVisitor(
                    featureKey: FeatureKeys.SALES.statsToday,
                    child: _buildQuickStat(
                      label: "Available Stock",
                      value: AppFormatterHelper.amountFormatter(
                        controller.availableStock,
                      ),
                      color: const Color(0xFFF59E0B),
                      icon: Icons.inbox,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
