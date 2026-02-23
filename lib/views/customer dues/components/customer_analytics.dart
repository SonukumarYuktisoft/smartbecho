import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/customer%20dues%20controllers/customer_dues_controller.dart';
import 'package:smartbecho/models/customer%20dues%20management/monthly_dues_analytics_model.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'dart:math' as math;

import 'package:smartbecho/utils/app_colors.dart';

class CustomerDuesAnalyticsModal extends StatelessWidget {
  const CustomerDuesAnalyticsModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CustomerDuesController controller =
        Get.find<CustomerDuesController>();
    final screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          _buildHeader(context, controller),
          // Year selector
          Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Obx(
                    () => GestureDetector(
                      onTap: () => _showYearPicker(context, controller),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySwatch,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.selectedAnalyticsYear.value.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.backgroundLight,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Refresh button
                  Obx(
                    () => IconButton(
                      onPressed:
                          controller.isAnalyticsLoading.value
                              ? null
                              : () => controller.fetchMonthlyAnalytics(),
                      icon:
                          controller.isAnalyticsLoading.value
                              ? const SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Icon(
                                Icons.refresh,
                                color: AppColors.primarySwatch,
                              ),
                      splashRadius: 15,
                    ),
                  ),
                ],
              ),

              // Content
              Expanded(
                child: Obx(() {
                if (controller.isAnalyticsLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading analytics...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
              
                // If no analytics data available, build a default zeroed dataset
                List<MonthlyDuesSummary> dataToDisplay =
                    controller.analyticsData.isNotEmpty
                        ? controller.analyticsData
                        : _createDefaultZeroData();
              
                return FeatureVisitor(
                        featureKey: FeatureKeys.DUES.viewMonthlyDuesSummary,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary cards with donut chart
                        _buildSummaryWithDonutChart(
                          controller,
                          context,
                          dataToDisplay,
                        ),
                                  
                        const SizedBox(height: 24),
                                  
                        // Month pills
                        _buildMonthPills(controller),
                                  
                        const SizedBox(height: 20),
                                  
                        // Monthly cards grid
                        _buildMonthlyCardsGrid(controller, dataToDisplay),
                      ],
                    ),
                  ),
                );
              }),
                          ),
          ],
        ),
    );
  }

  List<MonthlyDuesSummary> _createDefaultZeroData() {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames
        .map(
          (m) => MonthlyDuesSummary(
            month: m,
            remainingPercentage: 0.0,
            collected: 0.0,
            collectedPercentage: 0.0,
            remaining: 0.0,
          ),
        )
        .toList();
  }

  Widget _buildHeader(BuildContext context, CustomerDuesController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        // color: AppColors.primaryLight,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            splashRadius: 20,
          ),
          const SizedBox(width: 8),
          const Text(
            'Dues Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // const Spacer(),
          // // Year selector
          // Obx(() => GestureDetector(
          //   onTap: () => _showYearPicker(context, controller),
          //   child: Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          //     decoration: BoxDecoration(
          //       color: AppColors.primarySwatch,
          //       borderRadius: BorderRadius.circular(8),
          //     ),
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Text(
          //           controller.selectedAnalyticsYear.value.toString(),
          //           style: const TextStyle(
          //             fontSize: 16,
          //             fontWeight: FontWeight.w600,
          //             color: Colors.white,
          //           ),
          //         ),
          //         const SizedBox(width: 4),
          //         const Icon(
          //           Icons.arrow_drop_down,
          //           color: AppColors.backgroundLight,
          //           size: 20,
          //         ),
          //       ],
          //     ),
          //   ),
          // )),
          // const SizedBox(width: 8),
          // // Refresh button
          // Obx(() => IconButton(
          //   onPressed: controller.isAnalyticsLoading.value
          //       ? null
          //       : () => controller.fetchMonthlyAnalytics(),
          //   icon: controller.isAnalyticsLoading.value
          //       ? const SizedBox(
          //           width: 15,
          //           height: 15,
          //           child: CircularProgressIndicator(
          //             strokeWidth: 2,
          //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //           ),
          //         )
          //       : const Icon(Icons.refresh, color: AppColors.primarySwatch),
          //   splashRadius: 15,
          // )),
        ],
      ),
    );
  }

  void _showYearPicker(
    BuildContext context,
    CustomerDuesController controller,
  ) {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Year',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...years.map(
                  (year) => Obx(
                    () => ListTile(
                      title: Text(
                        year.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing:
                          controller.selectedAnalyticsYear.value == year
                              ? const Icon(
                                Icons.check,
                                color: AppColors.primaryLight,
                              )
                              : const SizedBox.shrink(),
                      onTap: () {
                        controller.onAnalyticsYearChanged(year);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildSummaryWithDonutChart(
    CustomerDuesController controller,
    BuildContext context,
    List<MonthlyDuesSummary> dataToDisplay,
  ) {
    return Obx(() {
      // Get filtered data based on selected month
      List<MonthlyDuesSummary> filteredData;

      if (controller.analyticsData.isEmpty) {
        // Use default zero data
        filteredData =
            controller.selectedAnalyticsMonth.value == null
                ? dataToDisplay
                : dataToDisplay.where((data) {
                  final monthIndex = _getMonthIndex(data.month);
                  return monthIndex ==
                      controller.selectedAnalyticsMonth.value! - 1;
                }).toList();
      } else {
        // Use actual data from controller
        filteredData = controller.getFilteredAnalyticsData();
      }

      double totalCollected = 0;
      double totalRemaining = 0;

      for (var data in filteredData) {
        totalCollected += data.collected;
        totalRemaining += data.remaining;
      }

      final totalGiven = totalCollected + totalRemaining;
      final collectedPercent =
          totalGiven > 0 ? (totalCollected / totalGiven * 100) : 0.0;
      final remainingPercent =
          totalGiven > 0 ? (totalRemaining / totalGiven * 100) : 0.0;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Donut chart with center text
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: _getPieChartSections(
                        totalCollected,
                        totalRemaining,
                        totalGiven,
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      startDegreeOffset: -90,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                  // Center text showing total
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '₹${_formatAmount(totalGiven)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total Due',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Summary items in row
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    '₹${_formatAmount(totalCollected)}',
                    '${collectedPercent.toStringAsFixed(1)}% Collected',
                    AppColors.primaryLight,
                    Icons.check_circle,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildSummaryItem(
                    '₹${_formatAmount(totalRemaining)}',
                    '${remainingPercent.toStringAsFixed(1)}% Remaining',
                    const Color(0xFFFF9800),
                    Icons.pending,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  List<PieChartSectionData> _getPieChartSections(
    double collected,
    double remaining,
    double total,
  ) {
    if (total == 0) {
      // Show empty state
      return [
        PieChartSectionData(
          color: Colors.grey.withOpacity(0.2),
          value: 1,
          title: '0%',
          radius: 35,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ];
    }

    final collectedPercent = (collected / total * 100);
    final remainingPercent = (remaining / total * 100);

    return [
      // Collected section (teal)
      PieChartSectionData(
        color: AppColors.primaryLight,
        value: collected,
        title: '${collectedPercent.toStringAsFixed(0)}%',
        radius: 35,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: collectedPercent >= 15 ? null : Container(),
        badgePositionPercentageOffset: 0.98,
      ),
      // Remaining section (orange)
      PieChartSectionData(
        color: const Color(0xFFFF9800),
        value: remaining,
        title: '${remainingPercent.toStringAsFixed(0)}%',
        radius: 35,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: remainingPercent >= 15 ? null : Container(),
        badgePositionPercentageOffset: 0.98,
      ),
    ];
  }

  Widget _buildSummaryItem(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  //   Widget _buildSummaryItem(String value, String label, Color color, IconData icon) {
  //   return Column(
  //     children: [
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(icon, color: color, size: 16),
  //           const SizedBox(width: 6),
  //           Text(
  //             value,
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: color,
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 6),
  //       Text(
  //         label,
  //         style: TextStyle(
  //           fontSize: 11,
  //           color: Colors.grey[600],
  //           fontWeight: FontWeight.w500,
  //         ),
  //         textAlign: TextAlign.center,
  //       ),
  //     ],
  //   );
  // }

  Widget _buildMonthPills(CustomerDuesController controller) {
    final months = [
      {'name': 'All', 'value': null},
      {'name': 'Jan', 'value': 1},
      {'name': 'Feb', 'value': 2},
      {'name': 'Mar', 'value': 3},
      {'name': 'Apr', 'value': 4},
      {'name': 'May', 'value': 5},
      {'name': 'Jun', 'value': 6},
      {'name': 'Jul', 'value': 7},
      {'name': 'Aug', 'value': 8},
      {'name': 'Sep', 'value': 9},
      {'name': 'Oct', 'value': 10},
      {'name': 'Nov', 'value': 11},
      {'name': 'Dec', 'value': 12},
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];

          return Obx(() {
            final isSelected =
                controller.selectedAnalyticsMonth.value == month['value'];

            return GestureDetector(
              onTap: () {
                controller.onAnalyticsMonthChanged(month['value'] as int?);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    month['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildMonthlyCardsGrid(
    CustomerDuesController controller,
    List<MonthlyDuesSummary> dataToDisplay,
  ) {
    return Obx(() {
      List<MonthlyDuesSummary> filteredData;

      if (controller.analyticsData.isEmpty) {
        // Use default zero data
        filteredData =
            controller.selectedAnalyticsMonth.value == null
                ? dataToDisplay
                : dataToDisplay.where((data) {
                  final monthIndex = _getMonthIndex(data.month);
                  return monthIndex ==
                      controller.selectedAnalyticsMonth.value! - 1;
                }).toList();
      } else {
        // Use actual data from controller
        filteredData = controller.getFilteredAnalyticsData();
      }

      final monthColors = [
        const Color(0xFF00BCD4), // January - Cyan
        const Color(0xFF9C27B0), // February - Purple
        const Color(0xFF7C4DFF), // March - Deep Purple
        const Color(0xFFFF7043), // April - Deep Orange
        AppColors.primaryLight, // May - Teal
        const Color(0xFF2196F3), // June - Blue
        const Color(0xFFEF5350), // July - Red
        const Color(0xFFFF9800), // August - Orange
        const Color(0xFF00BCD4), // September - Cyan
        const Color(0xFF2196F3), // October - Blue
        AppColors.primaryLight, // November - Teal
        const Color(0xFF00BCD4), // December - Cyan
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          final data = filteredData[index];
          final monthIndex = _getMonthIndex(data.month);
          final color = monthColors[monthIndex % monthColors.length];

          return _buildMonthlyCard(data, color);
        },
      );
    });
  }

  int _getMonthIndex(String month) {
    const months = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return months.indexOf(month.toUpperCase());
  }

  Widget _buildMonthlyCard(MonthlyDuesSummary data, Color color) {
    final totalDue = data.collected + data.remaining;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getMonthName(data.month),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardRow('Due Given', '₹${_formatAmount(totalDue)}'),
              const SizedBox(height: 4),
              _buildCardRow('Collected', '₹${_formatAmount(data.collected)}'),
              const SizedBox(height: 4),
              _buildCardRow('Remaining', '₹${_formatAmount(data.remaining)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getMonthName(String month) {
    return month.substring(0, 1).toUpperCase() +
        month.substring(1).toLowerCase();
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return "${(amount / 10000000).toStringAsFixed(2)}Cr";
    } else if (amount >= 100000) {
      return "${(amount / 100000).toStringAsFixed(2)}L";
    } else if (amount >= 1000) {
      return "${(amount / 1000).toStringAsFixed(1)}K";
    }
    return amount.toStringAsFixed(0);
  }
}
