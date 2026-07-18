import 'package:flutter/material.dart';
import 'package:adips/utils/constants/adips_palette.dart';

class AdipsSwitchTheme {
  AdipsSwitchTheme._();

  static SwitchThemeData lightSwitchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AdipsPalette.lightAction
          : AdipsPalette.lightTextHint,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AdipsPalette.lightActionTint
          : AdipsPalette.lightSubtle,
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.transparent
          : AdipsPalette.lightBorder,
    ),
    trackOutlineWidth: WidgetStateProperty.all(0.5),
  );

  static SwitchThemeData darkSwitchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AdipsPalette.darkAction
          : AdipsPalette.darkTextHint,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AdipsPalette.darkActionTint
          : AdipsPalette.darkSubtle,
    ),
    trackOutlineColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? Colors.transparent
          : AdipsPalette.darkBorder,
    ),
    trackOutlineWidth: WidgetStateProperty.all(0.5),
  );
}
