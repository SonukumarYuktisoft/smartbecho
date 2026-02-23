// lib/utils/chart_converter.dart
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';

class ChartDataModel {
  final String label;
  final double value;
  final String? category;

  ChartDataModel({
    required this.label,
    required this.value,
    this.category,
  });
}

class MultiLineChartData {
  final String label;
  final double? value1;
  final double? value2;
  final double? value3;

  MultiLineChartData({
    required this.label,
    this.value1,
    this.value2,
    this.value3,
  });
}

enum ChartType { line, bar, pie, multiLine, doughnut, column, spline }

enum DateType { yearly, nonYearly, noDate }

class ChartConverter {
  static const List<String> monthNames = [
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

  static const List<String> monthShortNames = [
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
    'Dec'
  ];

  // Detect date type from response
  static DateType detectDateType(dynamic payload) {
    if (payload is Map) {
      // Check for yearly date (2026-02 format)
      if (payload.keys.any((key) =>
          key.toString().contains('-') &&
          RegExp(r'^\d{4}-\d{2}').hasMatch(key.toString()))) {
        return DateType.yearly;
      }

      // Check for month field (1-12)
      if (payload.containsKey('month') &&
          payload['month'] is int &&
          payload['month'] >= 1 &&
          payload['month'] <= 12) {
        return DateType.yearly;
      }

      // Check for month name
      if (payload.containsKey('month') && payload['month'] is String) {
        if (monthNames.contains(payload['month']) ||
            monthShortNames.contains(payload['month'])) {
          return DateType.yearly;
        }
      }

      return DateType.noDate;
    }

    if (payload is List) {
      if (payload.isEmpty) return DateType.noDate;

      var firstItem = payload[0];
      if (firstItem is Map) {
        if (firstItem.containsKey('month')) {
          if (firstItem['month'] is int ||
              firstItem['month'] is String && monthNames.contains(firstItem['month'])) {
            return DateType.yearly;
          }
        }
      }
    }

    return DateType.noDate;
  }

  // Format Y-axis values (1k, 1L for Indian format)
  static String formatYAxisValue(double value) {
    if (value == 0) return '0';

    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}Cr';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }

    return value.toStringAsFixed(0);
  }

  // Convert Format 1: {date: value}
  static List<ChartDataModel> convertFormat1(dynamic payload) {
    List<ChartDataModel> data = [];

    if (payload is! Map) return data;

    payload.forEach((key, value) {
      String label = key.toString();
      if (label.contains('-')) {
        // 2026-02 format -> February
        var parts = label.split('-');
        if (parts.length == 2) {
          int monthNum = int.tryParse(parts[1]) ?? 0;
          if (monthNum > 0 && monthNum <= 12) {
            label = monthShortNames[monthNum - 1];
          }
        }
      }

      data.add(ChartDataModel(
        label: label,
        value: (value as num).toDouble(),
      ));
    });

    return data;
  }

  // Convert Format 2: List with brand/model (with limit)
  static List<ChartDataModel> convertFormat2(
    List<dynamic> payload, {
    required String valueKey,
    required String labelKey,
    int limit = 7,
  }) {
    List<ChartDataModel> data = [];

    for (int i = 0; i < payload.length && i < limit; i++) {
      var item = payload[i];
      if (item is Map) {
        data.add(ChartDataModel(
          label: item[labelKey]?.toString() ?? 'N/A',
          value: (item[valueKey] as num).toDouble(),
        ));
      }
    }

    return data;
  }

  // Convert Format 3: [{label, value}] simple
  static List<ChartDataModel> convertFormat3(
    List<dynamic> payload, {
    int limit = 7,
  }) {
    List<ChartDataModel> data = [];

    for (int i = 0; i < payload.length && i < limit; i++) {
      var item = payload[i];
      if (item is Map) {
        data.add(ChartDataModel(
          label: item['label']?.toString() ?? 'N/A',
          value: (item['value'] ?? item['totalAmount'] as num).toDouble(),
        ));
      }
    }

    return data;
  }

  // Convert Format 4: Monthly data with month field (yearly)
  static List<ChartDataModel> convertFormat4(List<dynamic> payload) {
    List<ChartDataModel> data = [];

    for (var item in payload) {
      if (item is Map) {
        String label = 'N/A';
        double value = 0;

        // Get label
        if (item.containsKey('month')) {
          var month = item['month'];
          if (month is int && month >= 1 && month <= 12) {
            label = monthShortNames[month - 1];
          } else if (month is String) {
            label = month.length > 3 ? month.substring(0, 3) : month;
          }
        }

        // Get value
        if (item.containsKey('totalSalesAmount')) {
          value = (item['totalSalesAmount'] as num).toDouble();
        } else if (item.containsKey('amount')) {
          value = (item['amount'] as num).toDouble();
        } else if (item.containsKey('totalBillsPaid')) {
          value = (item['totalBillsPaid'] as num).toDouble();
        } else if (item.containsKey('totalCommissions')) {
          value = (item['totalCommissions'] as num).toDouble();
        }

        // Only add if value > 0
        if (value > 0 || true) {
          // Change true to value > 0 to exclude zero values
          data.add(ChartDataModel(label: label, value: value));
        }
      }
    }

    return data;
  }

  // Convert multi-line chart (monthly with multiple values)
  static List<MultiLineChartData> convertMultiLine(List<dynamic> payload) {
    List<MultiLineChartData> data = [];

    for (var item in payload) {
      if (item is Map) {
        String label = 'N/A';

        if (item.containsKey('month')) {
          var month = item['month'];
          if (month is int && month >= 1 && month <= 12) {
            label = monthShortNames[month - 1];
          } else if (month is String) {
            label = month.length > 3 ? month.substring(0, 3) : month;
          }
        }

        data.add(MultiLineChartData(
          label: label,
          value1: (item['totalBillsPaid'] as num?)?.toDouble(),
          value2: (item['totalSalesAmount'] as num?)?.toDouble(),
          value3: (item['totalCommissions'] as num?)?.toDouble(),
        ));
      }
    }

    return data;
  }

  // Main auto-converter based on response format
  static List<ChartDataModel> autoConvert(
    dynamic payload, {
    ChartType chartType = ChartType.bar,
    int limit = 7,
  }) {
    // Handle payload wrapper
    if (payload is Map && payload.containsKey('payload')) {
      return autoConvert(payload['payload'],
          chartType: chartType, limit: limit);
    }

    // Format 1: Simple key-value map
    if (payload is Map && payload.isNotEmpty) {
      var firstKey = payload.keys.first;
      var firstValue = payload[firstKey];
      if (firstValue is num) {
        return convertFormat1(payload);
      }
    }

    // Format 2-3: List of objects
    if (payload is List && payload.isNotEmpty) {
      var firstItem = payload[0];

      if (firstItem is Map) {
        // Has brand/model/category with value key
        if (firstItem.containsKey('brand') || firstItem.containsKey('model')) {
          String labelKey =
              firstItem.containsKey('brand') ? 'brand' : 'model';
          String valueKey = firstItem.containsKey('totalAmount')
              ? 'totalAmount'
              : 'totalQuantity';
          return convertFormat2(payload,
              labelKey: labelKey, valueKey: valueKey, limit: limit);
        }

        // Simple label-value format
        if (firstItem.containsKey('label') &&
            (firstItem.containsKey('value') ||
                firstItem.containsKey('totalAmount'))) {
          return convertFormat3(payload, limit: limit);
        }

        // Monthly format with numeric month
        if (firstItem.containsKey('month')) {
          return convertFormat4(payload);
        }

        // Distribution/payment format
        if (firstItem.containsKey('paymentMethod') ||
            firstItem.containsKey('paymentType')) {
          return convertFormat2(payload,
              labelKey: 'paymentMethod', valueKey: 'totalAmount', limit: limit);
        }

        // Generic: find first string and first number
        String labelKey = '';
        String valueKey = '';

        for (var key in firstItem.keys) {
          var val = firstItem[key];
          if (val is String && labelKey.isEmpty) {
            labelKey = key;
          }
          if (val is num && valueKey.isEmpty) {
            valueKey = key;
          }
        }

        if (labelKey.isNotEmpty && valueKey.isNotEmpty) {
          return convertFormat2(payload,
              labelKey: labelKey, valueKey: valueKey, limit: limit);
        }
      }
    }

    return [];
  }

  // Auto-convert for multi-line charts
  static List<MultiLineChartData> autoConvertMultiLine(dynamic payload) {
    if (payload is Map && payload.containsKey('payload')) {
      return autoConvertMultiLine(payload['payload']);
    }

    if (payload is List) {
      return convertMultiLine(payload);
    }

    return [];
  }

  // Helper: Get category name from payload
  static String getCategoryName(dynamic payload) {
    if (payload is Map && payload.containsKey('paymentMethod')) {
      return payload['paymentMethod'];
    }
    if (payload is Map && payload.containsKey('brand')) {
      return payload['brand'];
    }
    return '';
  }
}