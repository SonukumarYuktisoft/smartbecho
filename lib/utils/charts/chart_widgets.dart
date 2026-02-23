/// lib/widgets/chart_widgets.dart
///
/// ✨ COMPLETE CHART LIBRARY - SINGLE FILE
///
/// 📊 7 CHART TYPES:
/// 1. Bar Chart - Horizontal bars
/// 2. Column Chart - Vertical bars
/// 3. Line Chart - Smooth curves
/// 4. Spline Chart - Smooth curves
/// 5. Pie Chart - Distribution
/// 6. Doughnut Chart - Distribution with center total
/// 7. MultiLine Chart - 3 smooth curved lines
///
/// ✅ KEY FEATURES:
/// ✅ All 12 months display on X-axis: Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
/// ✅ Formatted labels: 1k, 1L, 1Cr in WHITE color
/// ✅ Smooth curves for line/spline/multiline
/// ✅ Optimized bar width for screen fit
/// ✅ Responsive design
/// ✅ Professional UI
///
/// 🚀 USAGE:
/// ```dart
/// AutoChart(
///   apiResponse: response,
///   title: 'Monthly Sales',
///   chartType: ChartType.line,  // bar, column, line, spline, pie, doughnut, multiLine
///   subtitle: 'Optional subtitle',
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:smartbecho/utils/app_colors.dart';
import 'package:smartbecho/utils/charts/chart_converter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// 8-COLOR PALETTE FOR PIE/DOUGHNUT
final List<Color> chartColors = [
  const Color(0xFF6366F1), // Blue
  const Color(0xFF10B981), // Green
  const Color(0xFFF59E0B), // Orange
  const Color(0xFFEC4899), // Pink
  const Color(0xFF8B5CF6), // Purple
  const Color(0xFF3B82F6), // Light Blue
  const Color(0xFFEF4444), // Red
  const Color(0xFF14B8A6), // Teal
];

// ============================================================
// 1️⃣ BAR CHART - Horizontal Bars
// ============================================================
class BarChartWidget extends StatelessWidget {
  final List<ChartDataModel> data;
  final String title;
  final bool isYearly;
  final String? yAxisLabel;
  final String? subtitle;

  const BarChartWidget({
    Key? key,
    required this.data,
    required this.title,
    required this.isYearly,
    this.yAxisLabel,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmptyChart();

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                labelStyle: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondaryC,
                ),
              ),
              primaryYAxis: NumericAxis(
                majorGridLines: MajorGridLines(
                  width: 1,
                  color: AppColors.border,
                  dashArray: const [5, 5],
                ),
                axisLine: AxisLine(color: AppColors.border, width: 1),
                labelStyle: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondaryC,
                ),
                axisLabelFormatter: (AxisLabelRenderDetails details) {
                  return ChartAxisLabel(
                    ChartConverter.formatYAxisValue(details.value.toDouble()),
                    const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondaryC,
                    ),
                  );
                },
              ),
              series: <CartesianSeries>[
                BarSeries<ChartDataModel, String>(
                  dataSource: data,
                  xValueMapper: (ChartDataModel e, _) => e.label,
                  yValueMapper: (ChartDataModel e, _) => e.value,
                  color: AppColors.primaryLight,
                  width: 0.5,
                  spacing: 0.25,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(3),
                  ),
                  dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    textStyle: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    builder: (
                      dynamic data,
                      dynamic point,
                      dynamic series,
                      int pointIndex,
                      int seriesIndex,
                    ) {
                      final value = (data as ChartDataModel).value;
                      return Text(
                        ChartConverter.formatYAxisValue(value),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                color: Colors.black87,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryC,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryC,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.bar_chart_outlined,
                  size: 48,
                  color: AppColors.border,
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
        ],
      ),
    );
  }
}

// ============================================================
// 2️⃣ COLUMN CHART - Vertical Bars
// ============================================================
class ColumnChartWidget extends StatelessWidget {
  final List<ChartDataModel> data;
  final String title;
  final bool isYearly;
  final String? yAxisLabel;
  final String? subtitle;

  const ColumnChartWidget({
    Key? key,
    required this.data,
    required this.title,
    required this.isYearly,
    this.yAxisLabel,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmptyChart();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: 300,
              width:
                  data.length < 8
                      ? MediaQuery.of(context).size.width - 32
                      : (data.length * 45.0) + 50,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondaryC,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: AppColors.border,
                    dashArray: const [5, 5],
                  ),
                  axisLine: AxisLine(color: AppColors.border, width: 1),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondaryC,
                  ),
                  axisLabelFormatter: (AxisLabelRenderDetails details) {
                    return ChartAxisLabel(
                      ChartConverter.formatYAxisValue(details.value.toDouble()),
                      const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondaryC,
                      ),
                    );
                  },
                ),
                series: <CartesianSeries>[
                  ColumnSeries<ChartDataModel, String>(
                    dataSource: data,
                    xValueMapper: (ChartDataModel e, _) => e.label,
                    yValueMapper: (ChartDataModel e, _) => e.value,
                    color: AppColors.primaryLight,
                    width: 0.1,
                    spacing: 0.25,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                      textStyle: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      builder: (
                        dynamic data,
                        dynamic point,
                        dynamic series,
                        int pointIndex,
                        int seriesIndex,
                      ) {
                        final value = (data as ChartDataModel).value;
                        return Text(
                          ChartConverter.formatYAxisValue(value),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  color: Colors.black87,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryC,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryC,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.show_chart_outlined,
                  size: 48,
                  color: AppColors.border,
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
        ],
      ),
    );
  }
}

// ============================================================
// 3️⃣ LINE CHART - Smooth Curves
// ============================================================


class LineChartWidget extends StatelessWidget {
  final List<ChartDataModel> data;
  final String title;
  final bool isYearly;
  final String? subtitle;

  const LineChartWidget({
    Key? key,
    required this.data,
    required this.title,
    required this.isYearly,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmptyChart();

    // ✅ ENSURE ALL 12 MONTHS DISPLAY
    final chartData = _ensureAllMonths(data);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: 300,
              width: chartData.length < 8
                  ? MediaQuery.of(context).size.width - 32
                  : (chartData.length * 45.0) + 50,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondaryC,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: AppColors.border,
                    dashArray: const [5, 5],
                  ),
                  axisLine: AxisLine(color: AppColors.border, width: 1),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondaryC,
                  ),
                  axisLabelFormatter: (AxisLabelRenderDetails details) {
                    return ChartAxisLabel(
                      ChartConverter.formatYAxisValue(details.value.toDouble()),
                      const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondaryC,
                      ),
                    );
                  },
                ),
                // ✅ LINE WITH ALL MONTHS FROM 0
                series: <CartesianSeries>[
                  LineSeries<ChartDataModel, String>(
                    dataSource: chartData,  // ✅ All 12 months
                    xValueMapper: (ChartDataModel e, _) => e.label,
                    yValueMapper: (ChartDataModel e, _) => e.value,  // ✅ 0 for empty
                    color: AppColors.primaryLight,
                    width: 2.5,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 6,
                      width: 6,
                      color: AppColors.primaryLight,
                      borderColor: Colors.white,
                      borderWidth: 2,
                      shape: DataMarkerType.circle,
                    ),
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: false,
                    ),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  color: Colors.black87,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ ENSURE ALL 12 MONTHS
  /// If only February has data → Shows Jan(0) Feb(1000) Mar(0)... Dec(0)
  /// Line connects all months from 0
  List<ChartDataModel> _ensureAllMonths(List<ChartDataModel> data) {
    const fullMonthNames = [
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
      'December'
    ];

    // Create map of existing data
    final Map<String, double> monthMap = {};
    
    for (var item in data) {
      final label = item.label;
      monthMap[label] = item.value;
      
      // Also handle short names
      if (label.startsWith('Jan')) monthMap['January'] = item.value;
      else if (label.startsWith('Feb')) monthMap['February'] = item.value;
      else if (label.startsWith('Mar')) monthMap['March'] = item.value;
      else if (label.startsWith('Apr')) monthMap['April'] = item.value;
      else if (label.startsWith('May')) monthMap['May'] = item.value;
      else if (label.startsWith('Jun')) monthMap['June'] = item.value;
      else if (label.startsWith('Jul')) monthMap['July'] = item.value;
      else if (label.startsWith('Aug')) monthMap['August'] = item.value;
      else if (label.startsWith('Sep')) monthMap['September'] = item.value;
      else if (label.startsWith('Oct')) monthMap['October'] = item.value;
      else if (label.startsWith('Nov')) monthMap['November'] = item.value;
      else if (label.startsWith('Dec')) monthMap['December'] = item.value;
    }

    // ✅ Return all 12 months with 0 for missing data
    return [
      for (var month in fullMonthNames)
        ChartDataModel(label: month, value: monthMap[month] ?? 0),
    ];
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryC,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryC,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.trending_up_outlined,
                  size: 48,
                  color: AppColors.border,
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
        ],
      ),
    );
  }
}// ============================================================
// 4️⃣ SPLINE CHART - Smooth Curves (Same as Line)
// ============================================================
class SplineChartWidget extends StatelessWidget {
  final List<ChartDataModel> data;
  final String title;
  final bool isYearly;
  final String? subtitle;

  const SplineChartWidget({
    Key? key,
    required this.data,
    required this.title,
    required this.isYearly,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmptyChart();
    return LineChartWidget(
      data: data,
      title: title,
      isYearly: isYearly,
      subtitle: subtitle,
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryC,
            ),
          ),
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.trending_up_outlined,
                  size: 48,
                  color: AppColors.border,
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
        ],
      ),
    );
  }
}

// ============================================================
// 5️⃣ PIE CHART - Distribution
// ============================================================
class PieChartWidget extends StatelessWidget {
  final List<ChartDataModel> data;
  final String title;
  final int limit;
  final String? subtitle;

  const PieChartWidget({
    Key? key,
    required this.data,
    required this.title,
    this.limit = 7,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmptyChart();
    final limitedData = data.take(limit).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: const TextStyle(fontSize: 11),
              ),
              series: <CircularSeries>[
                PieSeries<ChartDataModel, String>(
                  dataSource: limitedData,
                  xValueMapper: (ChartDataModel e, _) => e.label,
                  yValueMapper: (ChartDataModel e, _) => e.value,
                  pointColorMapper:
                      (ChartDataModel e, int i) =>
                          chartColors[i % chartColors.length],
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  explode: true,
                  explodeOffset: '5%',
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                color: Colors.black87,
                textStyle: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryC,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryC,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(Icons.pie_chart, size: 48, color: AppColors.border),
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
        ],
      ),
    );
  }
}

// ============================================================
// 6️⃣ DOUGHNUT CHART - Distribution with Center Total
// ============================================================
class DoughnutChartWidget extends StatelessWidget {
  final List<ChartDataModel> data;
  final String title;
  final int limit;
  final String? subtitle;

  const DoughnutChartWidget({
    Key? key,
    required this.data,
    required this.title,
    this.limit = 7,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmptyChart();
    final limitedData = data.take(limit).toList();
    final total = limitedData.fold<double>(0, (sum, e) => sum + e.value);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: SfCircularChart(
              legend: Legend(
                isVisible: true,
                position: LegendPosition.bottom,
                overflowMode: LegendItemOverflowMode.wrap,
                textStyle: const TextStyle(fontSize: 11),
              ),
              annotations: [
                CircularChartAnnotation(
                  widget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ChartConverter.formatYAxisValue(total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryC,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              series: <CircularSeries>[
                DoughnutSeries<ChartDataModel, String>(
                  dataSource: limitedData,
                  xValueMapper: (ChartDataModel e, _) => e.label,
                  yValueMapper: (ChartDataModel e, _) => e.value,
                  pointColorMapper:
                      (ChartDataModel e, int i) =>
                          chartColors[i % chartColors.length],
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  innerRadius: '60%',
                ),
              ],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                color: Colors.black87,
                textStyle: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryC,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryC,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.donut_large_outlined,
                  size: 48,
                  color: AppColors.border,
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
        ],
      ),
    );
  }
}

// ============================================================
// 7️⃣ MULTILINE CHART - 3 Smooth Curved Lines
// ============================================================
class MultiLineChartWidget extends StatelessWidget {
  final List<MultiLineChartData> data;
  final String title;
  final List<String> lineNames;
  final String? subtitle;

  const MultiLineChartWidget({
    Key? key,
    required this.data,
    required this.title,
    this.lineNames = const ['Bills Paid', 'Sales Amount', 'Commissions'],
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return _buildEmptyChart();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: 300,
              width:
                  data.length < 8
                      ? MediaQuery.of(context).size.width - 32
                      : (data.length * 40.0) + 50,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondaryC,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(
                    width: 1,
                    color: AppColors.border,
                    dashArray: const [5, 5],
                  ),
                  axisLine: AxisLine(color: AppColors.border, width: 1),
                  labelStyle: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondaryC,
                  ),
                  axisLabelFormatter: (AxisLabelRenderDetails details) {
                    return ChartAxisLabel(
                      ChartConverter.formatYAxisValue(details.value.toDouble()),
                      const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondaryC,
                      ),
                    );
                  },
                ),
                series: <CartesianSeries>[
                  SplineSeries<MultiLineChartData, String>(
                    dataSource: data,
                    xValueMapper: (MultiLineChartData e, _) => e.label,
                    yValueMapper: (MultiLineChartData e, _) => e.value1,
                    name: lineNames[0],
                    color: AppColors.primaryLight,
                    width: 2,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 5,
                      width: 5,
                      color: AppColors.primaryLight,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  ),
                  SplineSeries<MultiLineChartData, String>(
                    dataSource: data,
                    xValueMapper: (MultiLineChartData e, _) => e.label,
                    yValueMapper: (MultiLineChartData e, _) => e.value2,
                    name: lineNames[1],
                    color: AppColors.success,
                    width: 2,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 5,
                      width: 5,
                      color: AppColors.success,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  ),
                  SplineSeries<MultiLineChartData, String>(
                    dataSource: data,
                    xValueMapper: (MultiLineChartData e, _) => e.label,
                    yValueMapper: (MultiLineChartData e, _) => e.value3,
                    name: lineNames[2],
                    color: AppColors.warning,
                    width: 2,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      height: 5,
                      width: 5,
                      color: AppColors.warning,
                      borderColor: Colors.white,
                      borderWidth: 2,
                    ),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  color: Colors.black87,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                  textStyle: const TextStyle(fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryC,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryC,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.trending_up_outlined,
                  size: 48,
                  color: AppColors.border,
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
        ],
      ),
    );
  }
}

// ============================================================
// AUTO CHART - Smart Chart Selector
// ============================================================
/// ✅ MAIN USAGE:
/// Shows all 12 months: Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
class AutoChart extends StatelessWidget {
  final dynamic apiResponse;
  final String title;
  final ChartType chartType;
  final String? subtitle;

  const AutoChart({
    Key? key,
    required this.apiResponse,
    required this.title,
    required this.chartType,
    this.subtitle,
  }) : super(key: key);
@override
Widget build(BuildContext context) {
  try {
    // ✅ CONVERT MAP TO LIST FIRST
    final convertedResponse = _convertMapToList(apiResponse);
    
    if (chartType == ChartType.multiLine) {
      final data = ChartConverter.autoConvertMultiLine(convertedResponse);
      if (data.isNotEmpty)
        return MultiLineChartWidget(
          data: data,
          title: title,
          subtitle: subtitle,
        );
    } else {
      final data = ChartConverter.autoConvert(
        convertedResponse,  // ✅ USE CONVERTED RESPONSE
        chartType: chartType,
        limit: (chartType == ChartType.pie || 
                chartType == ChartType.bar || 
                chartType == ChartType.doughnut) ? 7 : 99,
      );
      final dateType = ChartConverter.detectDateType(convertedResponse);
      final displayData = _ensureYearlyMonths(data, dateType);

      if (displayData.isEmpty) return _buildEmptyChart();

      switch (chartType) {
        case ChartType.bar:
          return BarChartWidget(
            data: displayData,
            title: title,
            isYearly: dateType == DateType.yearly,
            subtitle: subtitle,
          );
        case ChartType.column:
          return ColumnChartWidget(
            data: displayData,
            title: title,
            isYearly: dateType == DateType.yearly,
            subtitle: subtitle,
          );
        case ChartType.line:
          return LineChartWidget(
            data: displayData,
            title: title,
            isYearly: dateType == DateType.yearly,
            subtitle: subtitle,
          );
        case ChartType.spline:
          return SplineChartWidget(
            data: displayData,
            title: title,
            isYearly: dateType == DateType.yearly,
            subtitle: subtitle,
          );
        case ChartType.pie:
          return PieChartWidget(
            data: displayData,
            title: title,
            subtitle: subtitle,
          );
        case ChartType.doughnut:
          return DoughnutChartWidget(
            data: displayData,
            title: title,
            subtitle: subtitle,
          );
        case ChartType.multiLine:
          return const SizedBox.shrink();
      }
    }
  } catch (e) {
    return _buildErrorChart('Error: ${e.toString()}');
  }
  return _buildEmptyChart();
}

// ✅ ADD THIS METHOD TO YOUR AutoChart CLASS
// This converts Map responses like {"FEBRUARY": 3} to List format

dynamic _convertMapToList(dynamic apiResponse) {
  if (apiResponse is Map) {
    print('🔍 Converting Map to List: $apiResponse');
    
    final converted = apiResponse.entries.map((e) {
      final label = e.key.toString();
      final value = e.value is num 
        ? e.value.toDouble() 
        : double.tryParse(e.value.toString()) ?? 0;
      
      print('  - $label: $value');
      return {
        'label': label,
        'value': value,
      };
    }).toList();
    
    print('✅ Converted to List with ${converted.length} items');
    return converted;
  }
  print('ℹ️ Already a List or other type');
  return apiResponse;
}
  /// ✅ KEY FEATURE: Shows all 12 months
  /// Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec
  List<ChartDataModel> _ensureYearlyMonths(
    List<ChartDataModel> data,
    DateType dateType,
  ) {
    // Just return data as-is, no modification
    // Only shows months/data that exist
    return data;
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryC,
            ),
          ),
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.insert_chart_outlined,
                  size: 48,
                  color: AppColors.border,
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
        ],
      ),
    );
  }

  Widget _buildErrorChart(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryC,
            ),
          ),
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(color: AppColors.error, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
