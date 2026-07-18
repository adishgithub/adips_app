import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsElevatedButtonTheme {
  AdipsElevatedButtonTheme._();

  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: AdipsPalette.lightAction,
      disabledForegroundColor: AdipsPalette.lightTextHint,
      disabledBackgroundColor: AdipsPalette.lightSubtle,
      side: const BorderSide(color: AdipsPalette.lightAction, width: 0),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: AdipsPalette.darkCanvas,
      backgroundColor: AdipsPalette.darkTextPrimary,
      disabledForegroundColor: AdipsPalette.darkTextHint,
      disabledBackgroundColor: AdipsPalette.darkSubtle,
      side: const BorderSide(color: AdipsPalette.darkTextPrimary, width: 0),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
