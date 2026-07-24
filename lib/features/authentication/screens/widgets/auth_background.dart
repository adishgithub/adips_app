// lib/features/authentication/screens/widgets/auth_background.dart
import 'package:flutter/material.dart';
import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/helpers/helper_functions.dart';

class AuthTheme {
  static Widget getAuthBackground(BuildContext context, {required Widget child}) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);

    return Scaffold(
      resizeToAvoidBottomInset: false, // <- keeps background fixed when keyboard opens
      backgroundColor: isDark
          ? AdipsPalette.darkBackground
          : AdipsPalette.lightBackground,
      body: Stack(
        children: [
          // Top image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                AdipsImages.backgroundImageGraphicsTop,
                fit: BoxFit.fitWidth,
                width: double.infinity,
                cacheWidth: 1000,
              ),
            ),
          ),
          // Bottom image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                AdipsImages.backgroundImageGraphicsBottom,
                fit: BoxFit.fitWidth,
                width: double.infinity,
                cacheWidth: 1000,
              ),
            ),
          ),
          // Content — handles its own keyboard-avoidance via padding
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}