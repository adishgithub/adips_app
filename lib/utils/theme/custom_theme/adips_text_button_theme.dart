import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';
import 'package:adips/utils/constants/sizes.dart';

class AdipsTextButtonTheme {
  AdipsTextButtonTheme._();

  static final lightTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AdipsPalette.lightAction,
      disabledForegroundColor: AdipsPalette.lightTextHint,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm)),
    ),
  );

  static final darkTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AdipsPalette.darkAction,
      disabledForegroundColor: AdipsPalette.darkTextHint,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      textStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        fontFamily: 'Poppins',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm)),
    ),
  );
}