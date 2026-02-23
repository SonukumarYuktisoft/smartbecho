import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/utils/charts/chart_converter.dart';
import 'package:smartbecho/utils/charts/chart_widgets.dart';
import 'package:smartbecho/utils/constant/feature%20strings/feature_keys.dart';
import 'package:smartbecho/utils/common/feature%20visitor/feature_visitor.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/helper/app_formatter_helper.dart';

class RevenueChartSection extends StatelessWidget {
  const RevenueChartSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Obx(() {
      final monthlyData = controller.monthlyRevenueChartPayload;

      // Get date range from monthly data
      String dateRange = 'No Data';
      if (monthlyData.isNotEmpty) {
        try {
          final entries = monthlyData.entries.toList();
          if (entries.isNotEmpty) {
            final firstKey = entries.first.key;
            final lastKey = entries.last.key;
            dateRange = '$firstKey - $lastKey';
          }
        } catch (e) {
          dateRange = 'Date Error';
        }
      }

      // Calculate performance percentage from monthly data
      double performancePercent = 0.0;

      if (monthlyData.isNotEmpty) {
        try {
          final entries = monthlyData.entries.toList();
          if (entries.length >= 2) {
            final currentMonth =
                double.tryParse(entries.last.value.toString()) ?? 0.0;
            final previousMonth =
                double.tryParse(entries[entries.length - 2].value.toString()) ??
                0.0;

            if (previousMonth > 0) {
              performancePercent =
                  ((currentMonth - previousMonth) / previousMonth) * 100;
            } else {
              performancePercent = 0.0;
            }
          } else if (entries.length == 1) {
            performancePercent = 0.0;
          }
        } catch (e) {
          performancePercent = 0.0;
        }
      }

      final isPositive = performancePercent >= 0;

      return Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          // Fixed: Changed from height to constraints
          constraints: BoxConstraints(minHeight: 450),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Fixed: Added this
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradientLight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.trending_up_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Monthly Sales Performance",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateRange,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Chart Section - Fixed with proper sizing
              FeatureVisitor(
                featureKey: FeatureKeys.SALES.monthlyRevenue,
                child: Column(
                  children: [
                    AutoChart(
            apiResponse: controller.monthlyRevenueChartPayload,
            title: 'Monthly Sales',
            chartType: ChartType.column,
            // subtitle: 'Year ${controller.selectedMonthlyChartYear.value}',
          ),
                    // SizedBox(
                    //   height: 280, // Fixed height for chart
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(20),
                    //     child: _buildEnhancedRevenueChart(controller),
                    //   ),
                    // ),
                    // Footer Stats Section
                    _footerStatsSection(performancePercent, isPositive),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Container _footerStatsSection(double performancePercent, bool isPositive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${performancePercent.abs().toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Your sales performance is',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${performancePercent.abs().toStringAsFixed(0)}% ${isPositive ? 'better' : 'lower'} compare to last month',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isPositive
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPositive
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              color:
                  isPositive
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF6B6B),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedRevenueChart(DashboardController controller) {
    return Obx(() {
      try {
        final monthlyData = controller.monthlyRevenueChartPayload;

        // Handle empty data
        if (monthlyData == null || monthlyData.isEmpty) {
          return _buildEmptyState(
            icon: Icons.bar_chart_outlined,
            title: 'No Revenue Data',
            subtitle: 'Revenue data will appear here when available',
          );
        }

        final entries = monthlyData.entries.toList();
        List<String> monthLabels = [];
        List<double> values = [];

        // Parse data
        try {
          for (var entry in entries) {
            final parts = entry.key.split('-');
            if (parts.length == 2) {
              final monthNum = int.tryParse(parts[1]);
              if (monthNum != null && monthNum >= 1 && monthNum <= 12) {
                const months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec',
                ];
                monthLabels.add(months[monthNum - 1]);
                final value = double.tryParse(entry.value.toString()) ?? 0;
                values.add(value);
              }
            }
          }
        } catch (e) {
          return _buildEmptyState(
            icon: Icons.error_outline_rounded,
            title: 'Data Error',
            subtitle: 'Unable to parse revenue data',
          );
        }

        // Handle invalid parsed data
        if (values.isEmpty || monthLabels.isEmpty) {
          return _buildEmptyState(
            icon: Icons.info_outline_rounded,
            title: 'No Valid Data',
            subtitle: 'Unable to process the revenue data format',
          );
        }

        final maxY = values.reduce((a, b) => a > b ? a : b);

        // Handle zero data
        if (maxY == 0) {
          return _buildEmptyState(
            icon: Icons.trending_flat_rounded,
            title: 'No Sales',
            subtitle: 'No sales data available for the period',
          );
        }

        // Build line chart with proper constraints
        return LayoutBuilder(
          builder: (context, constraints) {
            // Fixed: Ensure we have proper constraints
            if (constraints.maxWidth <= 0 || constraints.maxHeight <= 0) {
              return const SizedBox.shrink();
            }

            final lineChartBarData = LineChartBarData(
              spots: List.generate(values.length, (index) {
                return FlSpot(index.toDouble(), values[index]);
              }),
              isCurved: true,
              gradient: const LinearGradient(
                colors: AppColors.primaryGradientLight,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: AppColors.primaryGradientLight.first,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGradientLight.first.withOpacity(0.2),
                    AppColors.primaryGradientLight.last.withOpacity(0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            );

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width:
                    monthLabels.length > 6
                        ? monthLabels.length * 80.0
                        : constraints.maxWidth,
                height: constraints.maxHeight,
                child: LineChart(
                  LineChartData(
                    maxY: maxY * 1.3,
                    minY: 0,
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipPadding: const EdgeInsets.all(12),
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots
                              .map((LineBarSpot touchedSpot) {
                                final index = touchedSpot.x.toInt();
                                if (index >= 0 && index < monthLabels.length) {
                                  return LineTooltipItem(
                                    '${monthLabels[index]}\n',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            '₹${AppFormatterHelper.amountFormatter(touchedSpot.y)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  );
                                }
                                return null;
                              })
                              .whereType<LineTooltipItem>()
                              .toList();
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < monthLabels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  monthLabels[index],
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: maxY > 0 ? (maxY / 4) : 1,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${(value / 1000).toStringAsFixed(0)}K',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY > 0 ? (maxY / 4) : 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.15),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [lineChartBarData],
                  ),
                ),
              ),
            );
          },
        );
      } catch (e) {
        return _buildEmptyState(
          icon: Icons.warning_amber_rounded,
          title: 'Error Loading Chart',
          subtitle: 'An unexpected error occurred',
        );
      }
    });
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 56, color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
