import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/charts/app_donut_chart.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

class DonutChartsSection extends StatelessWidget {
  const DonutChartsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Container(
      color: Colors.transparent,
      margin: EdgeInsets.only(bottom: 10),
      height: 400,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: [
          // Customers Card
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.76,
            child: _buildCustomersCard(controller, context),
          ),
          const SizedBox(width: 12),

          // Dues Summary Card
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.78,
            child: _buildDuesSummaryCard(controller, context),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _buildCustomersCard(
    DashboardController controller,
    BuildContext context,
  ) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Customers",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Customer distribution overview",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Obx(
                  () => SizedBox(
                    height: 200,
                    child: AppDonutChart(
                      value: [
                        controller.repeatedCustomers.toDouble(),
                        controller.newCustomersThisMonth.toDouble(),
                      ],
                      title: 'Total',
                      decimalPlaces: 0,
                      strokeWidth: 25,
                      animationDuration: const Duration(milliseconds: 1000),
                      colors: [
                        AppColors.primaryLight,
                        AppColors.primaryLight.withValues(alpha: 0.5),
                        // const Color(0xFF3B82F6),
                        // const Color(0xFFBFDBFE),
                      ],
                      radius: 55,
                      showTotal: true,
                    ),
                  ),
                ),
              ),
            ),
            // const SizedBox(height: 25),
            Spacer(),
            Obx(
              () => Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildLegendItem(
                    label: "Repeated: ${controller.repeatedCustomers}",
                    color: AppColors.primaryLight,
                  ),
                  _buildLegendItem(
                    label: "New: ${controller.newCustomersThisMonth}",
                    color: AppColors.primaryLight.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuesSummaryCard(
    DashboardController controller,
    BuildContext context,
  ) {
    return Card(
      color: Colors.white,
      // elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Dues Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Collection status overview",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Obx(
                  () => SizedBox(
                    height: 200,
                    child: AppDonutChart(
                      value: [
                        double.parse(controller.collectedDues),
                        double.parse(controller.remainingDues),
                      ],
                      title: 'Total',
                      decimalPlaces: 0,
                      strokeWidth: 25,
                      animationDuration: const Duration(milliseconds: 1000),
                      colors:  [
                        // Color(0xFF3B82F6),
                        //  Color(0xFFBFDBFE)
                     AppColors.primaryLight,
                     AppColors.primaryLight.withValues(alpha: 0.5),
                         
                         ],
                      radius: 55,
                      showTotal: true,
                    ),
                  ),
                ),
              ),
            ),
            Spacer(),

            Obx(
              () => Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildLegendItem(
                    label:
                        "Collected: ₹${AppFormatterHelper.amountFormatter(double.parse(controller.collectedDues))}",
                    color: AppColors.primaryLight,
                  ),
                  _buildLegendItem(
                    label:
                        "Remaining: ₹${AppFormatterHelper.amountFormatter(double.parse(controller.remainingDues))}",
                    color: AppColors.primaryLight.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required String label, required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}
