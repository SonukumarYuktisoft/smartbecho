import 'package:flutter/material.dart';

class DatePickerHelper {
 static Future<DateTime?> pickDate({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now = DateTime.now();

    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(now.year + 1, now.month, now.day),
      helpText: 'Select Date',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );
  }

 static Future<DateTimeRange?> pickDateRange({
    required BuildContext context,
    DateTimeRange? initialRange,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final DateTime now = DateTime.now();

    return await showDateRangePicker(
      context: context,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(now.year + 1, now.month, now.day),
      initialDateRange: initialRange,
      helpText: 'Select Date Range',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );
  }
}
