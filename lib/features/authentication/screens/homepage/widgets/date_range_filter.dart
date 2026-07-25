import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/models/date_range_option.dart';

class DateRangeFilter extends StatefulWidget {
  const DateRangeFilter({super.key, required this.onChanged});

  final ValueChanged<DateRangeSelection> onChanged;

  @override
  State<DateRangeFilter> createState() => _DateRangeFilterState();
}

class _DateRangeFilterState extends State<DateRangeFilter> {
  late DateRangeSelection _selected;
  late List<DateRangeSelection> _presets;

  static const String customLabel = 'Custom';

  @override
  void initState() {
    super.initState();
    _presets = DateRangeOptions.presets();
    _selected = _presets.first; // "This Month" by default
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
    );

    if (picked != null) {
      final formatted =
          '${DateFormat.MMMd().format(picked.start)} - ${DateFormat.MMMd().format(picked.end)}';
      final selection = DateRangeSelection(label: formatted, range: picked);
      setState(() => _selected = selection);
      widget.onChanged(selection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final brandColor = isDark
        ? AdipsPalette.darkPrimaryBrandText
        : AdipsPalette.lightPrimaryBrandText;
    final surfaceColor = isDark
        ? AdipsPalette.darkTextField
        : AdipsPalette.lightTextField;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      color: surfaceColor, // <-- popup menu background must also follow theme
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
      ),
      onSelected: (value) {
        if (value == customLabel) {
          _pickCustomRange();
        } else {
          final selection = _presets.firstWhere((p) => p.label == value);
          setState(() => _selected = selection);
          widget.onChanged(selection);
        }
      },
      itemBuilder: (context) => [
        ..._presets.map(
              (p) => PopupMenuItem<String>(
            value: p.label,
            child: Row(
              children: [
                if (_selected.label == p.label)
                  Icon(Icons.check, size: 18, color: brandColor)
                else
                  const SizedBox(width: 18),
                const SizedBox(width: 8),
                Text(p.label, style: TextStyle(color: textColor)),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: customLabel,
          child: Row(
            children: [
              Icon(Icons.date_range, size: 18, color: brandColor),
              const SizedBox(width: 8),
              Text('Custom Range', style: TextStyle(color: textColor)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
          border: Border.all(
            color: isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine,
          ),
          boxShadow: [
            BoxShadow(
              color: AdipsPalette.shadowColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined, size: 16, color: brandColor),
            const SizedBox(width: 8),
            Text(
              _selected.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: brandColor),
          ],
        ),
      ),
    );
  }
}