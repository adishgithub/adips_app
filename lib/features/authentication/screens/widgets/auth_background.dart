// lib/theme/auth_theme.dart
import 'package:flutter/material.dart'; // Change from cupertino to material
import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';

class AuthTheme {
  static Widget getAuthBackground(BuildContext context, {required Widget child}) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AdipsPalette.darkBackground
            : AdipsPalette.lightBackground,
      ),
      child: Stack(
        children: [
          // Top image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              AdipsImages.backgroundImageGraphicsTop,
              fit: BoxFit.fitWidth,
              width: double.infinity,
            ),
          ),
          // Bottom image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              AdipsImages.backgroundImageGraphicsBottom,
              fit: BoxFit.fitWidth,
              width: double.infinity,
            ),
          ),
          // Content
          child,
        ],
      ),
    );
  }
}