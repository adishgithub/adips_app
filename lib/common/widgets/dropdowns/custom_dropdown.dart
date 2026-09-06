import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/adips_palette.dart';
import '../../../utils/helpers/helper_functions.dart';

/// A basic, reusable dropdown field. Generic over [T] so it can be used
/// for currency, category, or any other picklist.
/// Mirrors CustomTextField's dark/light handling so every dropdown in
/// the app matches the surrounding text fields instead of always
/// rendering a plain white box.
class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelText,
    this.hintText,
    this.itemLabelBuilder,
    this.prefixIcon,
    this.validator,
  });

  final T? value;
  final List<T> items;
  final void Function(T?) onChanged;
  final String? labelText;
  final String? hintText;

  /// How to turn an item of type [T] into display text.
  /// Defaults to `item.toString()` if not provided.
  final String Function(T item)? itemLabelBuilder;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final fillColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final labelColor =
    isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final lossColor = isDark ? AdipsPalette.darkLoss : AdipsPalette.lightLoss;

    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      dropdownColor: fillColor,
      style: TextStyle(color: textColor, fontSize: AdipsSizes.fontSizesMd),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabelBuilder != null ? itemLabelBuilder!(item) : item.toString(),
            style: TextStyle(color: textColor),
          ),
        ),
      )
          .toList(),
      onChanged: onChanged,
      icon: Icon(Icons.keyboard_arrow_down, color: labelColor),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: labelColor),
        floatingLabelStyle: TextStyle(color: labelColor),
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: labelColor) : null,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AdipsSizes.md,
          vertical: AdipsSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: BorderSide(color: fillColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: BorderSide(color: lineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: BorderSide(color: lineColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: BorderSide(color: lossColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: BorderSide(color: lossColor),
        ),
      ),
    );
  }
}