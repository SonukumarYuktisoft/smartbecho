import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smartbecho/utils/app_colors.dart';

class ReusableLineChart extends StatelessWidget {
  final Map<String, double> apiData;

  const ReusableLineChart({super.key, required this.apiData});

  List<FlSpot> _convert() {
    List<FlSpot> spots = [];

    // Create spots for all 12 months (even if data is missing)
    for (int month = 1; month <= 12; month++) {
      double value = 0.0;
      
      // Check if data exists for this month
      apiData.forEach((key, val) {
        final monthFromKey = int.parse(key.split("-")[1]);
        if (monthFromKey == month) {
          value = val;
        }
      });
      
      spots.add(FlSpot(month.toDouble(), value));
    }

    return spots;
  }

  double _getMaxY() {
    if (apiData.isEmpty) return 100;
    
    double max = apiData.values.reduce((a, b) => a > b ? a : b);
    // Add 20% padding to max value
    return max * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _convert();
    final maxY = _getMaxY();

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: 12,
          minY: 0,
          maxY: maxY,
          
          // Grid styling
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: maxY / 5,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),

          // Border styling
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey.shade300, width: 1),
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),

          // Line styling
          lineBarsData: [
            LineChartBarData(
              preventCurveOverShooting: true,
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.primaryLight,
              barWidth: 3,
              isStrokeCapRound: true,
              
              // Dot styling
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  // Only show dots for non-zero values
                  if (spot.y > 0) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.primaryLight,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 0,
                    color: Colors.transparent,
                  );
                },
              ),

              // Area under line
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryLight.withOpacity(0.3),
                    AppColors.primaryLight.withOpacity(0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],

          // Bottom titles (months)
          titlesData: FlTitlesData(
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            
            // Y-axis (left)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: maxY / 5,
                getTitlesWidget: (value, meta) {
                  if (value == 0) {
                    return Text(
                      '0',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    );
                  }
                  
                  String label;
                  if (value >= 100000) {
                    label = '${(value / 100000).toStringAsFixed(1)}L';
                  } else if (value >= 1000) {
                    label = '${(value / 1000).toStringAsFixed(1)}K';
                  } else {
                    label = value.toStringAsFixed(0);
                  }
                  
                  return Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
            
            // X-axis (bottom) - All 12 months
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1, // Show every month
                getTitlesWidget: (value, meta) {
                  const months = [
                    "", // Index 0 (not used)
                    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                  ];
                  
                  int monthIndex = value.toInt();
                  if (monthIndex < 1 || monthIndex > 12) {
                    return const SizedBox.shrink();
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      months[monthIndex],
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
   
          // Touch interaction
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppColors.primaryLight,
              tooltipBorderRadius:  BorderRadius.circular(8),
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((spot) {
                  const months = [
                    "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
                    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
                  ];
                  
                  String month = months[spot.x.toInt()];
                  String value = '₹${_formatAmount(spot.y)}';
                  
                  return LineTooltipItem(
                    '$month\n$value',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((index) {
                return TouchedSpotIndicatorData(
                
                  FlLine(
                    color: AppColors.primaryLight.withOpacity(0.5),
                    strokeWidth: 2,
                    dashArray: [5, 5],
                  ),
                  FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: AppColors.primaryLight,
                        strokeWidth: 3,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                );
              }).toList();
            },
          ),
        ),
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
}