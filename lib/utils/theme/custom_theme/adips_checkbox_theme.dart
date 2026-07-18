import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsCheckboxTheme {
  AdipsCheckboxTheme._();

  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    checkColor: WidgetStateProperty.all(Colors.white),
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AdipsPalette.lightAction
          : AdipsPalette.lightSubtle,
    ),
    side: const BorderSide(color: AdipsPalette.lightBorder, width: 0.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    overlayColor: WidgetStateProperty.all(AdipsPalette.lightActionTint),
  );

  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    checkColor: WidgetStateProperty.all(AdipsPalette.darkCanvas),
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AdipsPalette.darkAction
          : AdipsPalette.darkSubtle,
    ),
    side: const BorderSide(color: AdipsPalette.darkBorder, width: 0.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    overlayColor: WidgetStateProperty.all(AdipsPalette.darkActionTint),
  );
}
