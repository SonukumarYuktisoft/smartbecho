import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_appbar.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_insights_controller.dart';
import 'package:smartbecho/views/sales%20management/components/Sales%20Insights/components/PaymentMethods.dart';
import 'package:smartbecho/views/sales%20management/components/Sales%20Insights/components/ProductAnalysis.dart';
import 'package:smartbecho/views/sales%20management/components/Sales%20Insights/components/RevenueTrends.dart';

class SalesInsights extends StatelessWidget {
  const SalesInsights({super.key});
  
  @override
  Widget build(BuildContext context) {
    final SalesInsightsController controller = Get.put(
      SalesInsightsController(),
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: CustomAppBar(title: 'Sales Insights'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ======== MODERN TAB BAR ========
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColors.primaryLight, // teal
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[700],
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                splashFactory: NoSplash.splashFactory,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                tabs: const [
                  Tab(
                    child: Text(
                      "Revenue Trends",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Product Analysis",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Payment Methods",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= TAB PAGES ===================
            const Expanded(
              child: TabBarView(
                children: [
                  RevenueTrends(),
                  ProductAnalysis(),
                  PaymentMethods(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrandPieChart extends StatelessWidget {
  final List<dynamic> apiData;

  const BrandPieChart({super.key, required this.apiData});

  @override
  Widget build(BuildContext context) {
    /// ---------- Grouping brand quantities ----------
    Map<String, double> brandTotals = {};

    for (var item in apiData) {
      String brand = item["brand"];
      double qty = (item["totalQuantity"] as int).toDouble();

      if (brandTotals.containsKey(brand)) {
        brandTotals[brand] = brandTotals[brand]! + qty;
      } else {
        brandTotals[brand] = qty;
      }
    }

    /// Convert to PieChartSectionData list
    List<PieChartSectionData> sections = [];
    int colorIndex = 0;

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.pink,
      Colors.yellow,
      Colors.cyan,
    ];

    brandTotals.forEach((brand, qty) {
      sections.add(
        PieChartSectionData(
          value: qty,
          title: "$brand\n$qty",
          radius: 60,
          color: colors[colorIndex % colors.length],
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
      colorIndex++;
    });

    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1.3,
        child: PieChart(
          PieChartData(
            sections: sections,
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }
}