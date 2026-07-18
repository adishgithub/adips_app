import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsInputDecorationTheme {
  AdipsInputDecorationTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AdipsPalette.lightSubtle,
    hintStyle: const TextStyle(
      fontSize: 14,
      color: AdipsPalette.lightTextHint,
      fontFamily: 'Poppins',
    ),
    labelStyle: const TextStyle(
      fontSize: 14,
      color: AdipsPalette.lightTextMuted,
      fontFamily: 'Poppins',
    ),
    floatingLabelStyle: const TextStyle(
      fontSize: 12,
      color: AdipsPalette.lightAction,
      fontFamily: 'Poppins',
    ),
    errorStyle: const TextStyle(
      fontSize: 11,
      color: AdipsPalette.lightLoss,
      fontFamily: 'Poppins',
    ),
    prefixIconColor: AdipsPalette.lightTextMuted,
    suffixIconColor: AdipsPalette.lightTextMuted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AdipsPalette.lightBorder, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AdipsPalette.lightBorder, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AdipsPalette.lightAction, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AdipsPalette.lightLoss, width: 0.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AdipsPalette.lightLoss, width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: AdipsPalette.lightDivider,
        width: 0.5,
      ),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: AdipsPalette.darkSubtle,
    hintStyle: const TextStyle(
      fontSize: 14,
      color: AdipsPalette.darkTextHint,
      fontFamily: 'Poppins',
    ),
    labelStyle: const TextStyle(
      fontSize: 14,
      color: AdipsPalette.darkTextMuted,
      fontFamily: 'Poppins',
    ),
    floatingLabelStyle: const TextStyle(
      fontSize: 12,
      color: AdipsPalette.darkAction,
      fontFamily: 'Poppins',
    ),
    errorStyle: const TextStyle(
      fontSize: 11,
      color: AdipsPalette.darkLoss,
      fontFamily: 'Poppins',
    ),
    prefixIconColor: AdipsPalette.darkTextMuted,
    suffixIconColor: AdipsPalette.darkTextMuted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AdipsPalette.darkBorder, width: 0.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AdipsPalette.darkBorder, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AdipsPalette.darkAction, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AdipsPalette.darkLoss, width: 0.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AdipsPalette.darkLoss, width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AdipsPalette.darkDivider, width: 0.5),
    ),
  );
}
