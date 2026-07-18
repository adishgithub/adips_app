import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsDividerTheme {
  AdipsDividerTheme._();

  static const lightDividerTheme = DividerThemeData(
    color: AdipsPalette.lightDivider,
    thickness: 0.5,
    space: 0,
  );

  static const darkDividerTheme = DividerThemeData(
    color: AdipsPalette.darkDivider,
    thickness: 0.5,
    space: 0,
  );
}
