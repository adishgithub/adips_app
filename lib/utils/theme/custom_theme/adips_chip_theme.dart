import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsChipTheme {
  AdipsChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    backgroundColor: AdipsPalette.lightSubtle,
    selectedColor: AdipsPalette.lightActionTint,
    disabledColor: AdipsPalette.lightDivider,
    labelStyle: const TextStyle(
      fontSize: 12,
      color: AdipsPalette.lightTextMuted,
      fontFamily: 'Poppins',
    ),
    secondaryLabelStyle: const TextStyle(
      fontSize: 12,
      color: AdipsPalette.lightAction,
      fontFamily: 'Poppins',
    ),
    side: const BorderSide(color: AdipsPalette.lightBorder, width: 0.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    elevation: 0,
    pressElevation: 0,
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    backgroundColor: AdipsPalette.darkSubtle,
    selectedColor: AdipsPalette.darkActionTint,
    disabledColor: AdipsPalette.darkDivider,
    labelStyle: const TextStyle(
      fontSize: 12,
      color: AdipsPalette.darkTextMuted,
      fontFamily: 'Poppins',
    ),
    secondaryLabelStyle: const TextStyle(
      fontSize: 12,
      color: AdipsPalette.darkAction,
      fontFamily: 'Poppins',
    ),
    side: const BorderSide(color: AdipsPalette.darkBorder, width: 0.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    elevation: 0,
    pressElevation: 0,
  );
}
