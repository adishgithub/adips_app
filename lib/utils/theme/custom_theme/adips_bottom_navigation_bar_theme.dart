import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsBottomNavigationBarTheme {
  AdipsBottomNavigationBarTheme._();

  static const lightBottomNavTheme = BottomNavigationBarThemeData(
    backgroundColor: AdipsPalette.lightSurface,
    selectedItemColor: AdipsPalette.lightAction,
    unselectedItemColor: AdipsPalette.lightTextMuted,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      fontFamily: 'Poppins',
    ),
    selectedIconTheme: IconThemeData(size: 22, color: AdipsPalette.lightAction),
    unselectedIconTheme: IconThemeData(
      size: 22,
      color: AdipsPalette.lightTextMuted,
    ),
  );

  static const darkBottomNavTheme = BottomNavigationBarThemeData(
    backgroundColor: AdipsPalette.darkSurface,
    selectedItemColor: AdipsPalette.darkAction,
    unselectedItemColor: AdipsPalette.darkTextMuted,
    showSelectedLabels: true,
    showUnselectedLabels: true,
    elevation: 0,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      fontFamily: 'Poppins',
    ),
    unselectedLabelStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      fontFamily: 'Poppins',
    ),
    selectedIconTheme: IconThemeData(size: 22, color: AdipsPalette.darkAction),
    unselectedIconTheme: IconThemeData(
      size: 22,
      color: AdipsPalette.darkTextMuted,
    ),
  );
}
