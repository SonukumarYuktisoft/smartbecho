import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartbecho/controllers/dashboard_controller.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/generic_charts.dart';
import 'package:smartbecho/views/dashboard/widgets/dashboard_shimmers.dart';
import 'package:smartbecho/views/dashboard/widgets/error_cards.dart';

class SwitchableChartWidget extends StatefulWidget {
  final dynamic payload;
  final String title;
  final double screenWidth;
  final double screenHeight;
  final bool isSmallScreen;
  final List<Color>? customColors;
  final String initialChartType; // "barchart" or "piechart"
  final ChartDataType chartDataType;

  const SwitchableChartWidget({
    Key? key,
    required this.payload,
    required this.title,
    required this.screenWidth,
    required this.screenHeight,
    required this.isSmallScreen,
    this.customColors,
    this.initialChartType = "barchart",
    required this.chartDataType,
  }) : super(key: key);

  @override
  State<SwitchableChartWidget> createState() => _SwitchableChartWidgetState();
}

class _SwitchableChartWidgetState extends State<SwitchableChartWidget> {
  late String currentChartType;

  @override
  void initState() {
    super.initState();
    currentChartType = widget.initialChartType;
  }

  Widget _buildChart() {
    switch (currentChartType) {
      case "barchart":
        return GenericBarChart(
          title: widget.title,
          payload: widget.payload,
          isSmallScreen: widget.isSmallScreen,
          screenWidth: widget.screenWidth,
          dataType: widget.chartDataType,
        );
      case "piechart":
        return GenericPieChart(
          title: widget.title,
          payload: widget.payload,
          screenWidth: widget.screenWidth,
          isSmallScreen: widget.isSmallScreen,
          customColors:
              widget.customColors ??
              [
                const Color(0xFF2196F3), // Blue
                const Color(0xFFE91E63), // Pink
                const Color(0xFFFF9800), // Orange
                const Color(0xFF4CAF50), // Green
                const Color(0xFF9C27B0), // Purple
                const Color(0xFFFF5722), // Deep Orange
              ],
        );
      default:
        return const SizedBox.shrink();
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
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
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
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradientLight,
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
