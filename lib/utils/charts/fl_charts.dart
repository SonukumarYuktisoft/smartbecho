import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReusableBarChart extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final Color barColor;
  final Color? backgroundColor;
  final double chartHeight;
  final bool showGrid;
  final bool showValues;
  final String valuePrefix;
  final String valueSuffix;

  const ReusableBarChart({
    Key? key,
    required this.data,
    required this.title,
    this.barColor = const Color(0xFF6366F1),
    this.backgroundColor,
    this.chartHeight = 300,
    this.showGrid = true,
    this.showValues = true,
    this.valuePrefix = '',
    this.valueSuffix = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.values.every((v) => v == 0)) {
      return _buildEmptyChart();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: chartHeight,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(),
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.black87,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = data.keys.elementAt(group.x.toInt());
                      return BarTooltipItem(
                        '$label\n$valuePrefix${rod.toY.toStringAsFixed(2)}$valueSuffix',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= data.length) return const SizedBox();
                        final label = _getBottomLabel(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatValue(value),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: showGrid,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxY() / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                barGroups: _getBarGroups(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(data.length, (index) {
      final value = data.values.elementAt(index);
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: barColor,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: Colors.grey[200],
            ),
          ),
        ],
      );
    });
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2; // Add 20% padding
  }

  String _getBottomLabel(int index) {
    final key = data.keys.elementAt(index);
    // For monthly data (e.g., "2024-01"), show just month
    if (key.contains('-')) {
      final parts = key.split('-');
      if (parts.length == 2) {
        final month = int.tryParse(parts[1]);
        if (month != null) {
          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          return months[month - 1];
        }
      }
    }
    // For company names or other labels, truncate if needed
    return key.length > 10 ? '${key.substring(0, 8)}..' : key;
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildEmptyChart() {
    return Container(
      height: chartHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class ReusableLineChart extends StatelessWidget {
  final Map<String, double> data;
  final String title;
  final Color lineColor;
  final Color? backgroundColor;
  final double chartHeight;
  final bool showGrid;
  final bool showDots;
  final bool showArea;
  final String valuePrefix;
  final String valueSuffix;

  const ReusableLineChart({
    Key? key,
    required this.data,
    required this.title,
    this.lineColor = const Color(0xFF6366F1),
    this.backgroundColor,
    this.chartHeight = 300,
    this.showGrid = true,
    this.showDots = true,
    this.showArea = true,
    this.valuePrefix = '',
    this.valueSuffix = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.values.every((v) => v == 0)) {
      return _buildEmptyChart();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: chartHeight,
            child: LineChart(
              LineChartData(
                
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: _getMaxY(),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => Colors.black87,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final label = data.keys.elementAt(spot.x.toInt());
                        return LineTooltipItem(
                          '$label\n$valuePrefix${spot.y.toStringAsFixed(2)}$valueSuffix',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= data.length || value < 0) {
                          return const SizedBox();
                        }
                        final label = _getBottomLabel(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        );
                      },
                      reservedSize: 32,
                      interval: _getBottomInterval(),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatValue(value),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: showGrid,
                  drawVerticalLine: false,
                  horizontalInterval: _getMaxY() / 5,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    left: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
              preventCurveOverShooting: true,

                    spots: _getSpots(),
                    isCurved: true,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: showDots,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: lineColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                          
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: showArea,
                      color: lineColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return List.generate(data.length, (index) {
      return FlSpot(
        index.toDouble(),
        data.values.elementAt(index),
      );
    });
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2;
  }

  double _getBottomInterval() {
    if (data.length <= 6) return 1;
    if (data.length <= 12) return 2;
    return 3;
  }

  String _getBottomLabel(int index) {
    final key = data.keys.elementAt(index);
    if (key.contains('-')) {
      final parts = key.split('-');
      if (parts.length == 2) {
        final month = int.tryParse(parts[1]);
        if (month != null) {
          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
          return months[month - 1];
        }
      }
    }
    return key.length > 10 ? '${key.substring(0, 8)}..' : key;
  }

  String _formatValue(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  Widget _buildEmptyChart() {
    return Container(
      height: chartHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No data available',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}