// common/widgets/pickers/category_picker_sheet.dart
import 'package:flutter/material.dart';

import '../../../utils/constants/adips_category_colors.dart';
import '../../../utils/constants/adips_icons.dart';
import '../../../utils/constants/adips_palette.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../../../utils/models/transaction_category_model.dart';
import '../../../utils/models/transaction_type_model.dart';

/// Opens a sheet listing every category (icon, color, and name — the
/// same look as Settings > Categories), grouped under its
/// transaction type. Picking one selects both the category *and* its
/// type/direction in a single tap, since a category always belongs
/// to exactly one type — there's no separate "Type" step to fill in.
///
/// Returns the picked category, or null if dismissed without a pick.
Future<TransactionCategoryModel?> showCategoryPickerSheet({
  required BuildContext context,
  required List<TransactionTypeModel> types,
  required List<TransactionCategoryModel> categories,
  TransactionCategoryModel? selected,
}) {
  return showModalBottomSheet<TransactionCategoryModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CategoryPickerSheet(
      types: types,
      categories: categories,
      selected: selected,
    ),
  );
}

class CategoryPickerSheet extends StatelessWidget {
  const CategoryPickerSheet({
    super.key,
    required this.types,
    required this.categories,
    this.selected,
  });

  final List<TransactionTypeModel> types;
  final List<TransactionCategoryModel> categories;
  final TransactionCategoryModel? selected;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final surfaceColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final brandColor =
    isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
          margin: const EdgeInsets.all(AdipsSizes.sm),
          padding: const EdgeInsets.all(AdipsSizes.md),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(AdipsSizes.cardRadiusLg),
            border: Border.all(color: lineColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                'Choose a category',
                style: TextStyle(
                  fontSize: AdipsSizes.fontSizesLg,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: AdipsSizes.sm),
              Flexible(
                child: categories.isEmpty
                    ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: AdipsSizes.lg),
                  child: Text(
                    'No categories yet — add one in Settings > Categories.',
                    style: TextStyle(color: mutedColor),
                  ),
                )
                    : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final type in types) ...[
                      if (categories.any((c) => c.transactionTypeId == type.id)) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AdipsSizes.xs),
                          child: Text(
                            type.name,
                            style: TextStyle(
                              fontSize: AdipsSizes.fontSizesSm,
                              fontWeight: FontWeight.w700,
                              color: brandColor,
                            ),
                          ),
                        ),
                        for (final category in categories.where(
                              (c) => c.transactionTypeId == type.id,
                        ))
                          _CategoryRow(
                            category: category,
                            isSelected: category.id == selected?.id,
                            textColor: textColor,
                            mutedColor: mutedColor,
                            lineColor: lineColor,
                            brandColor: brandColor,
                            onTap: () => Navigator.of(context).pop(category),
                          ),
                        const SizedBox(height: AdipsSizes.sm),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.isSelected,
    required this.textColor,
    required this.mutedColor,
    required this.lineColor,
    required this.brandColor,
    required this.onTap,
  });

  final TransactionCategoryModel category;
  final bool isSelected;
  final Color textColor;
  final Color mutedColor;
  final Color lineColor;
  final Color brandColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = AdipsCategoryColors.byId(category.colorId);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
      child: Container(
        margin: const EdgeInsets.only(bottom: AdipsSizes.xs),
        padding: const EdgeInsets.symmetric(horizontal: AdipsSizes.sm, vertical: AdipsSizes.xs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
          border: Border.all(color: isSelected ? brandColor : lineColor),
          color: isSelected ? brandColor.withOpacity(0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: accent.withOpacity(0.15),
              child: Icon(AdipsIcons.byId(category.iconId), color: accent, size: 18),
            ),
            const SizedBox(width: AdipsSizes.sm),
            Expanded(
              child: Text(
                category.name,
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle_rounded, color: brandColor, size: 20),
          ],
        ),
      ),
    );
  }
}