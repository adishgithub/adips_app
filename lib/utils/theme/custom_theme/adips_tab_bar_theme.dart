import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsTabBar {
  AdipsTabBar._();

  static const lightTabBarTheme = TabBarThemeData(
    labelColor: AdipsPalette.lightAction,
    unselectedLabelColor: AdipsPalette.lightTextMuted,
    indicatorColor: AdipsPalette.lightAction,
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: AdipsPalette.lightDivider,
    labelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      fontFamily: 'Poppins',
    ),
    overlayColor: WidgetStatePropertyAll(AdipsPalette.lightActionTint),
  );

  static const darkTabBarTheme = TabBarThemeData(
    labelColor: AdipsPalette.darkAction,
    unselectedLabelColor: AdipsPalette.darkTextMuted,
    indicatorColor: AdipsPalette.darkAction,
    indicatorSize: TabBarIndicatorSize.tab,
    dividerColor: AdipsPalette.darkDivider,
    labelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      fontFamily: 'Poppins',
    ),
    overlayColor: WidgetStatePropertyAll(AdipsPalette.darkActionTint),
  );
}
