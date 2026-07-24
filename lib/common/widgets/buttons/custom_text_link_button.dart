import 'package:flutter/material.dart';

import '../../../utils/constants/adips_palette.dart';
import '../../../utils/helpers/helper_functions.dart';

/// A basic, reusable link-style text button.
/// No dark/light mode handling — plain fixed colors only.
class CustomTextLinkButton extends StatelessWidget {
  const CustomTextLinkButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.underline = false,
  });

  final String text;
  final VoidCallback onPressed;
  final bool underline;

  @override
  Widget build(BuildContext context) {

    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText,
        padding: EdgeInsets.zero,
        minimumSize: const Size(50, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          decoration: underline ? TextDecoration.underline : TextDecoration.none,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}