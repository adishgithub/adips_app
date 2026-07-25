// utils/models/date_range_option.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateRangeSelection {
  final String label;
  final DateTimeRange range;

  const DateRangeSelection({required this.label, required this.range});
}

class DateRangeOptions {
  /// Builds the standard preset list: This Month, Last 30 Days,
  /// then the previous few calendar months by name.
  static List<DateRangeSelection> presets({int pastMonths = 3}) {
    final now = DateTime.now();
    final List<DateRangeSelection> options = [];

    // This Month
    final startOfMonth = DateTime(now.year, now.month, 1);
    options.add(DateRangeSelection(
      label: 'This Month',
      range: DateTimeRange(start: startOfMonth, end: now),
    ));

    // Last 30 Days
    options.add(DateRangeSelection(
      label: 'Last 30 Days',
      range: DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
    ));

    // Previous full calendar months, by name
    for (int i = 1; i <= pastMonths; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final start = DateTime(monthDate.year, monthDate.month, 1);
      final end = DateTime(monthDate.year, monthDate.month + 1, 0); // last day of that month
      options.add(DateRangeSelection(
        label: DateFormat.MMMM().format(monthDate), // e.g. "June"
        range: DateTimeRange(start: start, end: end),
      ));
    }

    return options;
  }
}