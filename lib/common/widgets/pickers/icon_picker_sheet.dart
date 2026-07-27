// common/widgets/pickers/icon_picker_sheet.dart
import 'package:flutter/material.dart';

import '../../../utils/constants/adips_icons.dart';
import '../../../utils/constants/adips_palette.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

/// Opens the picker and returns the chosen icon_id (1-80), or null if
/// the user dismissed it without picking one.
Future<int?> showIconPickerSheet({
  required BuildContext context,
  required int selectedIconId,
  required Color accentColor,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => IconPickerSheet(selectedIconId: selectedIconId, accentColor: accentColor),
  );
}

class IconPickerSheet extends StatelessWidget {
  const IconPickerSheet({
    super.key,
    required this.selectedIconId,
    required this.accentColor,
  });

  final int selectedIconId;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;

    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        margin: const EdgeInsets.all(AdipsSizes.sm),
        padding: const EdgeInsets.all(AdipsSizes.md),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AdipsSizes.cardRadiusLg),
          border: Border.all(color: lineColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AdipsSizes.sm),
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Choose an icon',
              style: TextStyle(
                fontSize: AdipsSizes.fontSizesLg,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AdipsSizes.sm),
            Expanded(
              child: GridView.builder(
                itemCount: AdipsIcons.all.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: AdipsSizes.sm,
                  crossAxisSpacing: AdipsSizes.sm,
                ),
                itemBuilder: (context, index) {
                  final entry = AdipsIcons.all[index];
                  final bool selected = entry.key == selectedIconId;
                  return InkWell(
                    borderRadius: BorderRadius.circular(AdipsSizes.cardRadiusSm),
                    onTap: () => Navigator.of(context).pop(entry.key),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected ? accentColor.withOpacity(0.15) : Colors.transparent,
                        border: Border.all(
                          color: selected ? accentColor : lineColor,
                          width: selected ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(AdipsSizes.cardRadiusSm),
                      ),
                      child: Icon(
                        entry.value,
                        color: selected ? accentColor : mutedColor,
                        size: AdipsSizes.iconMd,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
