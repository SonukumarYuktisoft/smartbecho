import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AppDonutChart extends StatelessWidget {
  final List<Color> byColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellowAccent,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.grey,
    Colors.indigo,
    Colors.cyan,
  ];

  final List<double> value;
  final List<Color>? colors;
  final String title;
  final double? radius;
  final bool? showText;
  final TextStyle? textStyle;
  final int? decimalPlaces;
  final Color? backgroundColor;
  final double? strokeWidth;
  final Duration? animationDuration;
  final bool? showTotal;

  AppDonutChart({
    super.key,
    required this.value,
    this.colors,
    required this.title,
    this.radius = 10,
    this.showText = false,
    this.textStyle,
    required this.decimalPlaces,
    this.backgroundColor,
    required this.strokeWidth,
    required this.animationDuration,
    this.showTotal = false,
  });

  int get sum => value.fold(0, (a, b) => a + b.toInt());

  List<PieChartSectionData> get sections {
    if (value.isEmpty || value.every((v) => v == 0)) {
      return [
        PieChartSectionData(
          value: 1,
          color: Colors.grey[300],
          title: '',
          radius: radius,
        ),
      ];
    }

    return value.asMap().entries.map((entry) {
      int index = entry.key;
      double val = entry.value;
      return PieChartSectionData(
        value: val,
        color: (val == 0)
            ? backgroundColor ?? Colors.grey
            : (colors?[index % colors!.length] ??
                byColors[index % byColors.length]),
        title: showText == false ? '' : val.toStringAsFixed(decimalPlaces ?? 0),
        radius: radius,
        titleStyle: textStyle ?? const TextStyle(fontSize: 14, color: Colors.white),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        
        // Responsive center space and font sizes
        final centerSpaceRadius = size * 0.35;
        final titleFontSize = size * 0.06;
        final valueFontSize = size * 0.12;
        
        return AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            margin: const EdgeInsets.all(5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: centerSpaceRadius,
                    sectionsSpace: 2,
                    titleSunbeamLayout: true,
                    pieTouchData: PieTouchData(enabled: true),
                    borderData: FlBorderData(show: false),
                    sections: sections,
                  ),
                ),
                if (showTotal == true)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: titleFontSize.clamp(10.0, 14.0),
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: size * 0.02),
                      Text(
                        sum.toString(),
                        style: TextStyle(
                          fontSize: valueFontSize.clamp(18.0, 32.0),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}