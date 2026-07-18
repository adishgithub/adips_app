import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsOutlinedButtonTheme {
  AdipsOutlinedButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AdipsPalette.lightTextPrimary,
      disabledForegroundColor: AdipsPalette.lightTextHint,
      side: const BorderSide(color: AdipsPalette.lightBorder, width: 0.5),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AdipsPalette.darkTextPrimary,
      disabledForegroundColor: AdipsPalette.darkTextHint,
      side: const BorderSide(color: AdipsPalette.darkBorder, width: 0.5),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
