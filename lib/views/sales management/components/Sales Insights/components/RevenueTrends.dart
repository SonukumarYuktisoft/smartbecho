import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/custom_dropdown.dart';
import 'package:smartbecho/controllers/sales%20hisrory%20controllers/sales_insights_controller.dart';
import 'package:smartbecho/views/sales%20management/components/Sales%20Insights/charts/ReusableLineChart.dart';

class RevenueTrends extends StatelessWidget {
  const RevenueTrends({super.key});

  @override
  Widget build(BuildContext context) {
    final SalesInsightsController controller =
        Get.find<SalesInsightsController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Monthly Revenue",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Trend of monthly revenue performance",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // // Year Dropdown
                    // SizedBox(
                    //   width: 120,
                    //   child: buildStyledDropdown(
                    //     labelText: "Year",
                    //     hintText: "Select Year",
                    //     value: controller.selectedRevenueYear.value.toString(),
                    //     items: controller.years,
                    //     onChanged: (v) {
                    //       controller.updateSelectedYear(v!);
                    //     },
                    //   ),
                    // ),

                    // Padding(
                    //   padding: const EdgeInsets.only(top: 25.0),
                    //   child: Obx(() {
                    //     return controller.canClearRevenueTrends()
                    //         ? SizedBox(
                    //           //  width: 140,
                    //           height: 48,
                    //           child: OutlinedButton(
                    //             onPressed: () {
                    //               controller.clearRevenueTrends();
                    //             },
                    //             style: OutlinedButton.styleFrom(
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //             ),
                    //             child: const Text(
                    //               "Clear Filter",
                    //               style: TextStyle(fontSize: 12),
                    //             ),
                    //           ),
                    //         )
                    //         : const SizedBox();
                    //   }),
                    // ),
                  ],
                ),

                SizedBox(height: 20),

                // Chart Container
                FeatureVisitor(
                featureKey: FeatureKeys.SALES.monthlyRevenue,

                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 120,
                                child: buildStyledDropdown(
                                  labelText: "Year",
                                  hintText: "Select Year",
                                  value:
                                      controller.selectedRevenueYear.value
                                          .toString(),
                                  items: controller.years,
                                  onChanged: (v) {
                                    controller.updateSelectedYear(v!);
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 25.0),
                                child: Obx(() {
                                  return controller.canClearRevenueTrends()
                                      ? SizedBox(
                                        //  width: 140,
                                        height: 48,
                                        child: OutlinedButton(
                                          onPressed: () {
                                            controller.clearRevenueTrends();
                                          },
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                          ),
                                          child: const Text(
                                            "Clear Filter",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      )
                                      : const SizedBox();
                                }),
                              ),
                            ],
                          ),
                        ),
                        Obx(() {
                          if (controller.isRevenueChartLoading.value) {
                            return Container(
                              height: 450,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text(
                                      "Loading revenue data...",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                  
                          // Check if data is empty
                          if (controller.revenueData.isEmpty) {
                            return Container(
                              height: 450,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.analytics_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "No revenue data available",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "Try selecting a different year",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                  
                          // Chart with data
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Chart Legend
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Container(
                                    //   width: 40,
                                    //   height: 4,
                                    //   decoration: BoxDecoration(
                                    //     color: AppColors.primaryLight,
                                    //     borderRadius: BorderRadius.circular(2),
                                    //   ),
                                    // ),
                                    // SizedBox(width: 8),
                                    // Text(
                                    //   "Monthly Revenue",
                                    //   style: TextStyle(
                                    //     fontSize: 14,
                                    //     fontWeight: FontWeight.w600,
                                    //     color: Colors.grey[700],
                                    //   ),
                                    // ),
                                    // Spacer(),
                                    // _buildStatCard(),
                                  ],
                                ),
                  
                                SizedBox(height: 24),
                  
                                // Chart
                                SizedBox(
                                  height: 350,
                                  child: ReusableLineChart(
                                    apiData: controller.revenueData,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Summary Cards
                // Obx(() {
                //   if (!controller.isLoading.value && controller.revenueData.isNotEmpty) {
                //     return _buildSummaryCards(controller);
                //   }
                //   return SizedBox.shrink();
                // }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard() {
    final controller = Get.find<SalesInsightsController>();

    // Calculate total revenue
    double totalRevenue = controller.revenueData.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    // Calculate average
    double avgRevenue =
        controller.revenueData.isNotEmpty
            ? totalRevenue / controller.revenueData.length
            : 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, color: AppColors.primaryLight, size: 18),
          SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Avg Revenue",
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
              Text(
                "₹${_formatAmount(avgRevenue)}",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(SalesInsightsController controller) {
    double totalRevenue = controller.revenueData.values.fold(
      0.0,
      (sum, value) => sum + value,
    );

    // Find highest and lowest months
    MapEntry<String, double>? highest;
    MapEntry<String, double>? lowest;

    controller.revenueData.forEach((key, value) {
      if (value > 0) {
        if (highest == null || value > highest!.value) {
          highest = MapEntry(key, value);
        }
        if (lowest == null || value < lowest!.value) {
          lowest = MapEntry(key, value);
        }
      }
    });

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            "Total Revenue",
            "₹${_formatAmount(totalRevenue)}",
            Icons.account_balance_wallet,
            Colors.green,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            "Highest Month",
            highest != null
                ? "${_getMonthName(highest!.key)}: ₹${_formatAmount(highest!.value)}"
                : "N/A",
            Icons.arrow_upward,
            AppColors.primaryLight,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            "Lowest Month",
            lowest != null
                ? "${_getMonthName(lowest!.key)}: ₹${_formatAmount(lowest!.value)}"
                : "N/A",
            Icons.arrow_downward,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(2)}L";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(2)}K";
    }
    return amount.toStringAsFixed(0);
  }

  String _getMonthName(String key) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    int month = int.parse(key.split("-")[1]);
    return months[month];
  }
}
