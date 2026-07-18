import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsCardTheme {
  AdipsCardTheme._();

  static CardThemeData lightCardTheme = CardThemeData(
    color: AdipsPalette.lightSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AdipsPalette.lightBorder, width: 0.5),
    ),
  );

  static CardThemeData darkCardTheme = CardThemeData(
    color: AdipsPalette.darkSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AdipsPalette.darkBorder, width: 0.5),
    ),
  );
}
