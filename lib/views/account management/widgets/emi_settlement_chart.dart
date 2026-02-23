import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:smartbecho/models/account%20management%20models/emi%20settlement/emi_settlement_chart_model.dart';
import 'package:smartbecho/utils/app_colors.dart';

class EmiSettlementChartWidget extends StatefulWidget {
  final List<MonthlyEmiData> data;
  final String title;
  final double screenWidth;
  final double screenHeight;
  final bool isSmallScreen;
  final List<Color>? customColors;
  final String initialChartType;

  const EmiSettlementChartWidget({
    Key? key,
    required this.data,
    required this.title,
    required this.screenWidth,
    required this.screenHeight,
    required this.isSmallScreen,
    this.customColors,
    this.initialChartType = "barchart",
  }) : super(key: key);

  @override
  State<EmiSettlementChartWidget> createState() => _EmiSettlementChartWidgetState();
}

class _EmiSettlementChartWidgetState extends State<EmiSettlementChartWidget> {
  late String currentChartType;
  
  final List<Color> defaultColors = [
    AppColors.primaryLight, // Blue
    const Color(0xFF10B981), // Green
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFFF59E0B), // Yellow
    const Color(0xFFEF4444), // Red
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFFEC4899), // Pink
    const Color(0xFF84CC16), // Lime
    const Color(0xFFF97316), // Orange
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF14B8A6), // Teal
    const Color(0xFFA855F7), // Violet
  ];

  @override
  void initState() {
    super.initState();
    currentChartType = widget.initialChartType;
  }

  List<Color> get colors => widget.customColors ?? defaultColors;

  // Get month abbreviation for display
  String getMonthAbbr(String month) {
    const monthMap = {
      'January': 'Jan',
      'February': 'Feb',
      'March': 'Mar',
      'April': 'Apr',
      'May': 'May',
      'June': 'Jun',
      'July': 'Jul',
      'August': 'Aug',
      'September': 'Sep',
      'October': 'Oct',
      'November': 'Nov',
      'December': 'Dec',
    };
    return monthMap[month] ?? month.substring(0, 3);
  }

  // Format amount for display
  String formatAmount(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildBarChart() {
    final nonZeroData = widget.data.where((item) => item.amount > 0).toList();
    
    if (nonZeroData.isEmpty) {
      return _buildEmptyState();
    }

    final maxY = nonZeroData.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final interval = maxY / 5;

    return Container(
      height: widget.isSmallScreen ? 300 : 400,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.1,
          minY: 0,
          groupsSpace: widget.isSmallScreen ? 8 : 12,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor:(group) =>  Colors.black87,
              tooltipBorderRadius: BorderRadius.all(Radius.circular(8)),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final monthData = nonZeroData[group.x.toInt()];
                return BarTooltipItem(
                  '${monthData.month}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: '₹${formatAmount(monthData.amount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < nonZeroData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        getMonthAbbr(nonZeroData[value.toInt()].month),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                          fontSize: widget.isSmallScreen ? 10 : 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 32,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    formatAmount(value),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: widget.isSmallScreen ? 10 : 12,
                    ),
                  );
                },
                reservedSize: widget.isSmallScreen ? 40 : 50,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
              left: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[300]!,
                strokeWidth: 1,
              );
            },
          ),
          barGroups: nonZeroData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data.amount,
                  color: colors[index % colors.length],
                  width: widget.isSmallScreen ? 16 : 20,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    final nonZeroData = widget.data.where((item) => item.amount > 0).toList();
    
    if (nonZeroData.isEmpty) {
      return _buildEmptyState();
    }

    final totalAmount = nonZeroData.fold<double>(0, (sum, item) => sum + item.amount);

    return Container(
      height: widget.isSmallScreen ? 300 : 400,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sections: nonZeroData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final percentage = (data.amount / totalAmount) * 100;
                  
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: data.amount,
                    title: '${percentage.toStringAsFixed(1)}%',
                    radius: widget.isSmallScreen ? 80 : 100,
                    titleStyle: TextStyle(
                      fontSize: widget.isSmallScreen ? 10 : 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: widget.isSmallScreen ? 30 : 40,
                sectionsSpace: 2,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // Handle touch events if needed
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: nonZeroData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getMonthAbbr(data.month),
                              style: TextStyle(
                                fontSize: widget.isSmallScreen ? 11 : 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              '₹${formatAmount(data.amount)}',
                              style: TextStyle(
                                fontSize: widget.isSmallScreen ? 10 : 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.isSmallScreen ? 300 : 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Data Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No EMI settlement data found for this period',
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

  Widget _buildChart() {
    switch (currentChartType) {
      case "barchart":
        return _buildBarChart();
      case "piechart":
        return _buildPieChart();
      default:
        return _buildBarChart();
    }
  }

  Widget _buildToggleButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.grey.shade200,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption(
            icon: Icons.bar_chart,
            label: "Bar",
            isSelected: currentChartType == "barchart",
            onTap: () => setState(() => currentChartType = "barchart"),
          ),
          _buildToggleOption(
            icon: Icons.pie_chart,
            label: "Pie",
            isSelected: currentChartType == "piechart",
            onTap: () => setState(() => currentChartType = "piechart"),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: widget.isSmallScreen ? 12 : 16,
          vertical: widget.isSmallScreen ? 8 : 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: widget.isSmallScreen ? 16 : 20,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: widget.isSmallScreen ? 12 : 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and toggle button
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSmallScreen ? 12 : 16,
            vertical: 8,
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
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
                    fontSize: widget.isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              _buildToggleButton(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Chart content
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey(currentChartType),
            child: _buildChart(),
          ),
        ),
      ],
    );
  }
}