import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsListTileTheme {
  AdipsListTileTheme._();

  static const lightListTileTheme = ListTileThemeData(
    tileColor: AdipsPalette.lightSurface,
    iconColor: AdipsPalette.lightTextMuted,
    textColor: AdipsPalette.lightTextPrimary,
    titleTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AdipsPalette.lightTextPrimary,
      fontFamily: 'Poppins',
    ),
    subtitleTextStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AdipsPalette.lightTextMuted,
      fontFamily: 'Poppins',
    ),
    leadingAndTrailingTextStyle: TextStyle(
      fontSize: 12,
      color: AdipsPalette.lightTextMuted,
      fontFamily: 'Poppins',
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    minLeadingWidth: 0,
    minVerticalPadding: 8,
    dense: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );

  static const darkListTileTheme = ListTileThemeData(
    tileColor: AdipsPalette.darkSurface,
    iconColor: AdipsPalette.darkTextMuted,
    textColor: AdipsPalette.darkTextPrimary,
    titleTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AdipsPalette.darkTextPrimary,
      fontFamily: 'Poppins',
    ),
    subtitleTextStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AdipsPalette.darkTextMuted,
      fontFamily: 'Poppins',
    ),
    leadingAndTrailingTextStyle: TextStyle(
      fontSize: 12,
      color: AdipsPalette.darkTextMuted,
      fontFamily: 'Poppins',
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    minLeadingWidth: 0,
    minVerticalPadding: 8,
    dense: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );
}
