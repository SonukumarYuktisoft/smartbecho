import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:smartbecho/models/sales%20history%20models/sales_Insights_models/payment_distribution_model.dart';

class PaymentMethodPieChart extends StatelessWidget {
  final List<PaymentDistribution> data;

  const PaymentMethodPieChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<PieChartSectionData> sections = [];

    final colors = [
      Colors.orange,
      Colors.teal,
      Colors.blue,
      Colors.red,
      Colors.green,
    ];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];

      sections.add(
        PieChartSectionData(
          value: item.percentage,
          title: "${item.percentage.toStringAsFixed(0)}%",
          color: colors[i % colors.length],
          radius: 55,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 1,
      ),
    );
  }
}
