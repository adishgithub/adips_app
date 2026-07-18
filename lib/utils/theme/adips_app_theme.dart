import 'package:flutter/material.dart';
import 'package:adips/utils/theme/custom_theme/adips_app_bar_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_bottom_navigation_bar_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_card_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_checkbox_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_chip_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_colors.dart';
import 'package:adips/utils/theme/custom_theme/adips_divider_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_elevated_button_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_input_decoration_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_list_tile_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_outlined_button_theme.dart';
import 'package:adips/utils/constants/adips_palette.dart';
import 'package:adips/utils/theme/custom_theme/adips_switch_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_tab_bar_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_text_button_theme.dart';
import 'package:adips/utils/theme/custom_theme/adips_text_theme.dart';

class AdipsAppTheme {
  AdipsAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: AdipsPalette.lightAction,
    scaffoldBackgroundColor: AdipsPalette.lightCanvas,
    colorScheme: const ColorScheme.light(
      primary: AdipsPalette.lightAction,
      onPrimary: Colors.white,
      primaryContainer: AdipsPalette.lightActionTint,
      onPrimaryContainer: AdipsPalette.lightAction,
      secondary: AdipsPalette.lightTextMuted,
      onSecondary: Colors.white,
      surface: AdipsPalette.lightSurface,
      onSurface: AdipsPalette.lightTextPrimary,
      surfaceContainerHighest: AdipsPalette.lightSubtle,
      error: AdipsPalette.lightLoss,
      onError: Colors.white,
      errorContainer: AdipsPalette.lightLossTint,
      onErrorContainer: AdipsPalette.lightLoss,
      outline: AdipsPalette.lightBorder,
      outlineVariant: AdipsPalette.lightDivider,
    ),
    extensions: const [AdipsColors.light],
    textTheme: AdipsTextTheme.lightTextTheme,
    appBarTheme: AdipsAppBar.lightAppBarTheme,
    cardTheme: AdipsCardTheme.lightCardTheme,
    elevatedButtonTheme: AdipsElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: AdipsOutlinedButtonTheme.lightOutlinedButtonTheme,
    textButtonTheme: AdipsTextButtonTheme.lightTextButtonTheme,
    inputDecorationTheme: AdipsInputDecorationTheme.lightInputDecorationTheme,
    chipTheme: AdipsChipTheme.lightChipTheme,
    dividerTheme: AdipsDividerTheme.lightDividerTheme,
    switchTheme: AdipsSwitchTheme.lightSwitchTheme,
    checkboxTheme: AdipsCheckboxTheme.lightCheckboxTheme,
    listTileTheme: AdipsListTileTheme.lightListTileTheme,
    tabBarTheme: AdipsTabBar.lightTabBarTheme,
    bottomNavigationBarTheme: AdipsBottomNavigationBarTheme.lightBottomNavTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: AdipsPalette.darkAction,
    scaffoldBackgroundColor: AdipsPalette.darkCanvas,
    colorScheme: const ColorScheme.dark(
      primary: AdipsPalette.darkAction,
      onPrimary: Colors.white,
      primaryContainer: AdipsPalette.darkActionTint,
      onPrimaryContainer: AdipsPalette.darkAction,
      secondary: AdipsPalette.darkTextMuted,
      onSecondary: Colors.white,
      surface: AdipsPalette.darkSurface,
      onSurface: AdipsPalette.darkTextPrimary,
      surfaceContainerHighest: AdipsPalette.darkSubtle,
      error: AdipsPalette.darkLoss,
      onError: Colors.white,
      errorContainer: AdipsPalette.darkLossTint,
      onErrorContainer: AdipsPalette.darkLoss,
      outline: AdipsPalette.darkBorder,
      outlineVariant: AdipsPalette.darkDivider,
    ),
    extensions: const [AdipsColors.dark],
    textTheme: AdipsTextTheme.darkTextTheme,
    appBarTheme: AdipsAppBar.darkAppBarTheme,
    cardTheme: AdipsCardTheme.darkCardTheme,
    elevatedButtonTheme: AdipsElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: AdipsOutlinedButtonTheme.darkOutlinedButtonTheme,
    textButtonTheme: AdipsTextButtonTheme.darkTextButtonTheme,
    inputDecorationTheme: AdipsInputDecorationTheme.darkInputDecorationTheme,
    chipTheme: AdipsChipTheme.darkChipTheme,
    dividerTheme: AdipsDividerTheme.darkDividerTheme,
    switchTheme: AdipsSwitchTheme.darkSwitchTheme,
    checkboxTheme: AdipsCheckboxTheme.darkCheckboxTheme,
    listTileTheme: AdipsListTileTheme.darkListTileTheme,
    tabBarTheme: AdipsTabBar.darkTabBarTheme,
    bottomNavigationBarTheme: AdipsBottomNavigationBarTheme.darkBottomNavTheme,
  );
}
