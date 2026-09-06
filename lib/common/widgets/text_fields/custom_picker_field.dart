// common/widgets/text_fields/custom_picker_field.dart
import 'package:flutter/material.dart';

import '../../../utils/constants/adips_palette.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

/// A read-only field that opens something else on tap (a bottom
/// sheet, a date picker, ...) but is styled identically to
/// [CustomTextField] / [CustomDropdown] — same fill color, border,
/// and label behaviour in both light and dark mode — so it never
/// looks out of place next to the fields it sits beside.
class CustomPickerField extends StatelessWidget {
  const CustomPickerField({
    super.key,
    required this.labelText,
    required this.valueText,
    required this.onTap,
    this.leading,
    this.validator,
  });

  final String labelText;
  final String valueText;
  final VoidCallback onTap;
  final Widget? leading;

  /// Only used to surface a validation error (e.g. "Select a
  /// category") through the surrounding Form; the field itself is
  /// never directly editable.
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final fillColor = isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField;
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final labelColor =
    isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;

    return FormField<String>(
      initialValue: valueText,
      validator: validator,
      builder: (state) {
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              labelStyle: TextStyle(color: labelColor),
              floatingLabelStyle: TextStyle(color: labelColor),
              prefixIcon: leading,
              suffixIcon: Icon(Icons.keyboard_arrow_down, color: labelColor),
              filled: true,
              fillColor: fillColor,
              errorText: state.errorText,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AdipsSizes.inputFieldContentPadding,
                vertical: AdipsSizes.inputFieldContentPadding,
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
            ),
            child: Text(
              valueText.isEmpty ? 'Select' : valueText,
              style: TextStyle(
                color: valueText.isEmpty ? mutedColor : textColor,
                fontSize: AdipsSizes.fontSizesMd,
              ),
            ),
          ),
        );
      },
    );
  }
}