import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/app_styles.dart';

class GenericBarChart extends StatelessWidget {
  final String title;
  final Map<String, double> payload;
  final double screenWidth;
  final bool isSmallScreen;
  final double barWidth;
  final double chartHeight;
  final ChartDataType dataType; // New parameter to specify data type

  const GenericBarChart({
    Key? key,
    required this.title,
    required this.payload,
    required this.screenWidth,
    required this.isSmallScreen,
    this.barWidth = 16.0,
    this.chartHeight = 260.0,
    this.dataType = ChartDataType.revenue, // Default to revenue
  }) : super(key: key);

  Color get primaryColor => AppColors.primaryLight;
  Color get primaryLight => AppColors.primaryLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, primaryLight.withValues(alpha:0.2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryLight.withValues(alpha:0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryLight.withValues(alpha:0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha:0.8),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: chartHeight,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: _buildBarTouchData(),
                titlesData: _buildTitlesData(),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(),
                gridData: const FlGridData(
                  show: false,
                  drawHorizontalLine: false,
                  drawVerticalLine: false,
                ),
              ),
              swapAnimationDuration: const Duration(milliseconds: 400),
              swapAnimationCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (group) => primaryColor,
        tooltipPadding: const EdgeInsets.all(8),
        tooltipMargin: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            _formatValue(rod.toY),
            AppStyles.custom(
              color: Colors.white,
              weight: FontWeight.bold,
              size: 14,
            ),
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData() {
    final keys = payload.keys.toList();
    return FlTitlesData(
      show: true,
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= 0 && value.toInt() < keys.length) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _formatBottomLabel(keys[value.toInt()]),
                  style: TextStyle(
                    color: Colors.grey.shade700,
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
          getTitlesWidget: (value, meta) {
            return Text(
              _formatValue(value),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            );
          },
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final keys = payload.keys.toList();
    return List.generate(
      keys.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: payload[keys[index]] ?? 0,
            color: primaryColor,
            width: barWidth,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY:
                  payload.values.isNotEmpty
                      ? payload.values.reduce((a, b) => a > b ? a : b) * 1.2
                      : 100,
              color: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBottomLabel(String label) {
    // Check if it's a date format (YYYY-MM)
    if (label.contains('-') && label.split('-').length == 2) {
      return formatMonthYear(label);
    }
    // For model names, truncate if too long
    return label.length > 8 ? '${label.substring(0, 8)}...' : label;
  }

  String formatMonthYear(String date) {
    final parts = date.split('-');
    if (parts.length == 2) {
      final year = parts[0];
      final month = parts[1];
      return "$month/${year.substring(2, 4)}";
    }
    return date;
  }

  String _formatValue(double value) {
    switch (dataType) {
      case ChartDataType.quantity:
        // For quantities, show whole numbers - no K/M formatting
        return value.toStringAsFixed(0);
      case ChartDataType.revenue:
        // For revenue, always use K/M formatting for large values
        return _formatCompact(value);
    }
  }

  String _formatCompact(double value) {
    if (value >= 1000000) return "${(value / 1000000).toStringAsFixed(1)}M";
    if (value >= 1000) return "${(value / 1000).toStringAsFixed(1)}K";
    return value.toStringAsFixed(0);
  }
}

// Enum to specify the type of data being displayed
enum ChartDataType { quantity, revenue }

// Helper class to convert API responses to chart data
class ChartDataConverter {
  // Convert top selling models API response to chart data
  static Map<String, double> fromTopSellingModels(
    List<dynamic> apiResponse, {
    bool useQuantity = true,
  }) {
    Map<String, double> chartData = {};

    for (var item in apiResponse) {
      String key = "${item['brand']} ${item['model']}";
      double value =
          useQuantity
              ? (item['quantity'] as num).toDouble()
              : (item['totalAmount'] as num).toDouble();
      chartData[key] = value;
    }

    return chartData;
  }

  // Convert monthly revenue API response to chart data
  static Map<String, double> fromMonthlyRevenue(
    Map<String, dynamic> apiResponse,
  ) {
    Map<String, double> chartData = {};

    apiResponse.forEach((key, value) {
      chartData[key] = (value as num).toDouble();
    });

    return chartData;
  }
}

//pie chart

// Model for Pie Chart Data
class PieChartDataModel {
  final String label;
  final double value;
  final Color color;

  PieChartDataModel({
    required this.label,
    required this.value,
    required this.color,
  });

  // Calculate percentage
  double getPercentage(double total) {
    return total > 0 ? (value / total) * 100 : 0;
  }
}

class GenericPieChart extends StatefulWidget {
  final String title;
  final Map<String, double> payload;
  final double screenWidth;
  final bool isSmallScreen;
  final double chartRadius;
  final List<Color>? customColors;
  final bool showLegend;
  final bool showPercentages;

  const GenericPieChart({
    Key? key,
    required this.title,
    required this.payload,
    required this.screenWidth,
    required this.isSmallScreen,
    this.chartRadius = 80.0,
    this.customColors,
    this.showLegend = true,
    this.showPercentages = true,
  }) : super(key: key);

  @override
  State<GenericPieChart> createState() => _GenericPieChartState();
}

class _GenericPieChartState extends State<GenericPieChart> {
  int touchedIndex = -1;

  // Default color palette
  final List<Color> _defaultColors = [
    const Color(0xFF2196F3), // Blue
    const Color(0xFFE91E63), // Pink
    const Color(0xFFFF9800), // Orange
    const Color(0xFF4CAF50), // Green
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFFF5722), // Deep Orange
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFFFFC107), // Amber
  ];

  Color get primaryColor => AppColors.primaryLight;
  Color get primaryLight => AppColors.primaryLight;

  @override
  Widget build(BuildContext context) {
    final pieData = _generatePieData();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: EdgeInsets.all(widget.screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, primaryLight.withValues(alpha:0.2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryLight.withValues(alpha:0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryLight.withValues(alpha:0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha:0.8),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(),
          const SizedBox(height: 20),
          _buildChart(pieData),
          if (widget.showLegend) ...[
           const SizedBox(height: 20),
           _buildLegend(pieData),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: widget.isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<PieChartDataModel> pieData) {
    return SizedBox(
      height: widget.chartRadius * 3 + 60,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 60,
          sections: _buildPieSections(pieData),
        ),
      ),
    );
  }

  Widget _buildLegend(List<PieChartDataModel> pieData) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          pieData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final total = widget.payload.values.fold(
              0.0,
              (sum, value) => sum + value,
            );

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: data.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    data.label,
                    style: TextStyle(
                      fontSize: widget.isSmallScreen ? 12 : 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  List<PieChartDataModel> _generatePieData() {
    final colors = widget.customColors ?? _defaultColors;
    final entries = widget.payload.entries.toList();

    return entries.asMap().entries.map((entry) {
      final index = entry.key;
      final mapEntry = entry.value;

      return PieChartDataModel(
        label: mapEntry.key,
        value: mapEntry.value,
        color: colors[index % colors.length],
      );
    }).toList();
  }

  List<PieChartSectionData> _buildPieSections(List<PieChartDataModel> pieData) {
    final total = widget.payload.values.fold(0.0, (sum, value) => sum + value);

    return pieData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;
      final radius = isTouched ? widget.chartRadius + 10 : widget.chartRadius;
      final percentage = data.getPercentage(total);

      return PieChartSectionData(
        color: data.color,
        value: data.value,
        title:
            widget.showPercentages ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: widget.isSmallScreen ? 12 : 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha:0.3),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        titlePositionPercentageOffset: 0.6,
      );
    }).toList();
  }

  String _formatCompact(double value) {
    if (value >= 1000000) return "${(value / 1000000).toStringAsFixed(1)}M";
    if (value >= 1000) return "${(value / 1000).toStringAsFixed(1)}K";
    return value.toStringAsFixed(0);
  }
}

enum ChartLineDataType { revenue, users, orders, calories, steps, temperature }

class GenericLineChart extends StatelessWidget {
  final String title;
  final RxMap<String, double> payload;
  final double screenWidth;
  final bool isSmallScreen;
  final double chartHeight;
  final ChartLineDataType dataType;

  const GenericLineChart({
    Key? key,
    required this.title,
    required this.payload,
    required this.screenWidth,
    required this.isSmallScreen,
    this.chartHeight = 260.0,
    this.dataType = ChartLineDataType.revenue,
  }) : super(key: key);

  Color get primaryColor => AppColors.primaryLight;
  Color get primaryLight => AppColors.primaryLight;
  Color get gradientStart => AppColors.primaryLight;
  Color get gradientEnd => AppColors.primaryLight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, primaryLight.withValues(alpha:0.2)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryLight.withValues(alpha:0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryLight.withValues(alpha:0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha:0.8),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: chartHeight,
            child: LineChart(
              LineChartData(
                lineTouchData: _buildLineTouchData(),
                gridData: _buildGridData(),
                titlesData: _buildTitlesData(),
                borderData: FlBorderData(show: false),
                lineBarsData: [_buildLineBarData()],
                minX: 0,
                maxX: (payload.length - 1).toDouble(),
                minY: 0,
                maxY: _getMaxY(),
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineBarData() {
    final spots =
        payload.entries
            .toList()
            .asMap()
            .entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
            .toList();

    return LineChartBarData(
      spots: spots,
      gradient: LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 6,
            color: gradientEnd,
            strokeWidth: 3,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            gradientStart.withValues(alpha:0.3),
            gradientEnd.withValues(alpha:0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      preventCurveOverShooting: true,
      isCurved: true,
    );
  }

  LineTouchData _buildLineTouchData() {
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => primaryColor.withValues(alpha:0.9),
        // tooltipRoundedRadius: 12,
        tooltipPadding: const EdgeInsets.all(12),
        tooltipMargin: 8,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final key = payload.keys.elementAt(spot.x.toInt());
            final value = spot.y;

            return LineTooltipItem(
              '$key\n${_formatValue(value)}',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            );
          }).toList();
        },
      ),
      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
        // Handle touch events if needed
      },
      handleBuiltInTouches: true,
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawHorizontalLine: true,
      drawVerticalLine: false,
      horizontalInterval: _getMaxY() / 5,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: primaryLight.withValues(alpha:0.2),
          strokeWidth: 1,
          dashArray: [5, 5],
        );
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          interval: 1,
          getTitlesWidget: (value, meta) {
            if (value.toInt() >= 0 && value.toInt() < payload.length) {
              final key = payload.keys.elementAt(value.toInt());
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _formatBottomTitle(key),
                  style: TextStyle(
                    color: primaryColor.withValues(alpha:0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          interval: _getMaxY() / 5,
          getTitlesWidget: (value, meta) {
            return Text(
              _formatValue(value),
              style: TextStyle(
                color: primaryColor.withValues(alpha:0.7),
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 10 : 11,
              ),
            );
          },
        ),
      ),
    );
  }

  double _getMaxY() {
    if (payload.isEmpty) return 10;
    final maxValue = payload.values.reduce((a, b) => a > b ? a : b);
    return (maxValue * 1.2).ceilToDouble();
  }

  String _formatBottomTitle(String key) {
    // Format based on the key pattern
    if (key.length <= 3) {
      return key.toUpperCase(); // For short keys like Mon, Tue, etc.
    } else if (key.contains('-')) {
      // For date formats like "2024-01-15"
      final parts = key.split('-');
      if (parts.length >= 2) {
        return '${parts[1]}/${parts[2] ?? ''}';
      }
    }
    return key.length > 6 ? key.substring(0, 6) : key;
  }

  String _formatValue(double value) {
    switch (dataType) {
      case ChartLineDataType.revenue:
        return '\$${value.toStringAsFixed(0)}';
      case ChartLineDataType.users:
        return '${value.toInt()}';
      case ChartLineDataType.orders:
        return '${value.toInt()}';
      case ChartLineDataType.calories:
        return '${value.toInt()} cal';
      case ChartLineDataType.steps:
        return '${value.toInt()}';
      case ChartLineDataType.temperature:
        return '${value.toStringAsFixed(1)}°';
      default:
        return value.toStringAsFixed(1);
    }
  }
}

//double bar chart
class GenericDoubleBarChart extends StatelessWidget {
  final String title;
  final Map<String, double> payload;
  final double screenWidth;
  final bool isSmallScreen;
  final double barWidth;
  final double chartHeight;
  final ChartDataType dataType;
  // New parameters for dual bar chart
  final Map<String, double>? secondaryPayload;
  final String? primaryLabel;
  final String? secondaryLabel;
  final Color? primaryBarColor;
  final Color? secondaryBarColor;
  final bool showTotals;

  const GenericDoubleBarChart({
    Key? key,
    required this.title,
    required this.payload,
    required this.screenWidth,
    required this.isSmallScreen,
    this.barWidth = 18.0,
    this.chartHeight = 280.0,
    this.dataType = ChartDataType.revenue,
    this.secondaryPayload,
    this.primaryLabel,
    this.secondaryLabel,
    this.primaryBarColor,
    this.secondaryBarColor,
    this.showTotals = false,
  }) : super(key: key);

  Color get primaryColor => primaryBarColor ?? const Color(0xFFE74C3C);
  Color get primaryLight => primaryColor.withValues(alpha:0.3);
  Color get secondaryColor => secondaryBarColor ?? const Color(0xFF27AE60);
  Color get secondaryLight => secondaryColor.withValues(alpha:0.3);

  @override
  Widget build(BuildContext context) {
    // Calculate totals for tooltip if needed
    final totalPrimary = payload.values.fold(0.0, (sum, value) => sum + value);
    final totalSecondary =
        secondaryPayload?.values.fold(0.0, (sum, value) => sum + value) ?? 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (showTotals) _buildTotalsRow(totalPrimary, totalSecondary),
          _buildLegend(),
          const SizedBox(height: 8),
          SizedBox(height: chartHeight, child: _buildChart()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          dataType == ChartDataType.revenue
              ? Icons.attach_money
              : Icons.inventory,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsRow(double totalPrimary, double totalSecondary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTotalItem(
            primaryLabel ?? 'Primary',
            totalPrimary,
            primaryColor,
          ),
          if (secondaryPayload != null)
            _buildTotalItem(
              secondaryLabel ?? 'Secondary',
              totalSecondary,
              secondaryColor,
            ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatValue(value),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    if (secondaryPayload == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(primaryLabel ?? 'Primary', primaryColor),
          const SizedBox(width: 20),
          _buildLegendItem(secondaryLabel ?? 'Secondary', secondaryColor),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) {
              return Colors.grey.shade800.withValues(alpha:0.9);
            },
            tooltipBorderRadius: BorderRadius.all(Radius.circular(8)),
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final key = payload.keys.elementAt(groupIndex);
              final isSecondary = rodIndex == 1;
              final value =
                  isSecondary
                      ? (secondaryPayload?[key] ?? 0.0)
                      : payload[key] ?? 0.0;
              final label =
                  isSecondary
                      ? (secondaryLabel ?? 'Secondary')
                      : (primaryLabel ?? 'Primary');

              return BarTooltipItem(
                '$key\n$label: ${value}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => _buildBottomTitle(value),
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: isSmallScreen ? 50 : 60,
              getTitlesWidget: (value, meta) => _buildLeftTitle(value),
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            left: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          horizontalInterval: _getMaxY() / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
          },
        ),
        barGroups: _buildBarGroups(),
      ),
    );
  }

  Widget _buildBottomTitle(double value) {
    final index = value.toInt();
    if (index < 0 || index >= payload.length) return const SizedBox.shrink();

    final key = payload.keys.elementAt(index);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        _formatLabel(key),
        style: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
          fontSize: isSmallScreen ? 10 : 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLeftTitle(double value) {
    return Text(
      _formatAxisValue(value),
      style: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
        fontSize: isSmallScreen ? 10 : 11,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return payload.entries.map((entry) {
      final index = payload.keys.toList().indexOf(entry.key);
      final secondaryValue = secondaryPayload?[entry.key] ?? 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: primaryColor,
            width: barWidth,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [primaryLight, primaryColor],
            ),
          ),
          if (secondaryPayload != null)
            BarChartRodData(
              toY: secondaryValue,
              color: secondaryColor,
              width: barWidth,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [secondaryLight, secondaryColor],
              ),
            ),
        ],
      );
    }).toList();
  }

  double _getMaxY() {
    final maxPrimary =
        payload.values.isEmpty ? 0.0 : payload.values.reduce(max);
    final maxSecondary =
        secondaryPayload?.values.isEmpty ?? true
            ? 0.0
            : secondaryPayload!.values.reduce(max);
    final maxValue = max(maxPrimary, maxSecondary);
    return maxValue * 1.2; // Add 20% padding
  }

  String _formatValue(double value) {
    if (dataType == ChartDataType.revenue) {
      if (value >= 1000000) {
        return value.toString();
      } else if (value >= 1000) {
        return value.toString();
      } else {
        return value.toString();
      }
    } else {
      if (value >= 1000) {
        return value.toString();
      } else {
        return value.toStringAsFixed(0);
      }
    }
  }

  String _formatAxisValue(double value) {
    if (dataType == ChartDataType.revenue) {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(0)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(0)}K';
      } else {
        return value.toStringAsFixed(0);
      }
    } else {
      if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(0)}K';
      } else {
        return value.toStringAsFixed(0);
      }
    }
  }

  String _formatLabel(String label) {
    if (isSmallScreen && label.length > 8) {
      return '${label.substring(0, 6)}..';
    }
    return label;
  }
}
