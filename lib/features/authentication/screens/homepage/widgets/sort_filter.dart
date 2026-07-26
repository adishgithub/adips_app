// widgets/sort_filter.dart
import 'package:flutter/material.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

enum SortOption { newestFirst, oldestFirst, amountHighToLow, amountLowToHigh }

extension SortOptionLabel on SortOption {
  String get label {
    switch (this) {
      case SortOption.newestFirst:
        return 'Newest First';
      case SortOption.oldestFirst:
        return 'Oldest First';
      case SortOption.amountHighToLow:
        return 'Amount: High to Low';
      case SortOption.amountLowToHigh:
        return 'Amount: Low to High';
    }
  }
}

class SortFilter extends StatefulWidget {
  const SortFilter({super.key, required this.onChanged});

  final ValueChanged<SortOption> onChanged;

  @override
  State<SortFilter> createState() => _SortFilterState();
}

class _SortFilterState extends State<SortFilter> {
  SortOption _selected = SortOption.newestFirst; // default

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

    return PopupMenuButton<SortOption>(
      offset: const Offset(0, 48),
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
      ),
      onSelected: (value) {
        setState(() => _selected = value);
        widget.onChanged(value);
      },
      itemBuilder: (context) => SortOption.values.map((option) {
        return PopupMenuItem<SortOption>(
          value: option,
          child: Row(
            children: [
              if (_selected == option)
                Icon(Icons.check, size: 18, color: brandColor)
              else
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(option.label, style: TextStyle(color: textColor)),
            ],
          ),
        );
      }).toList(),
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
            Icon(Icons.swap_vert_rounded, size: 16, color: brandColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _selected.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor,
                ),
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