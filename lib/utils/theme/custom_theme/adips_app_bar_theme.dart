import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsAppBar {
  AdipsAppBar._();

  static const lightAppBarTheme = AppBarTheme(
    backgroundColor: AdipsPalette.lightSurface,
    foregroundColor: AdipsPalette.lightTextPrimary,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: AdipsPalette.lightTextPrimary,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
      letterSpacing: -0.2,
    ),
    iconTheme: IconThemeData(color: AdipsPalette.lightTextPrimary, size: 22),
    actionsIconTheme: IconThemeData(
      color: AdipsPalette.lightTextMuted,
      size: 22,
    ),
    shadowColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  static const darkAppBarTheme = AppBarTheme(
    backgroundColor: AdipsPalette.darkSurface,
    foregroundColor: AdipsPalette.darkTextPrimary,
    elevation: 0,
    scrolledUnderElevation: 0.5,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: AdipsPalette.darkTextPrimary,
      fontSize: 17,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
      letterSpacing: -0.2,
    ),
    iconTheme: IconThemeData(color: AdipsPalette.darkTextPrimary, size: 22),
    actionsIconTheme: IconThemeData(
      color: AdipsPalette.darkTextMuted,
      size: 22,
    ),
    shadowColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
}
