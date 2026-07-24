import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/adips_palette.dart';
import '../../../utils/helpers/helper_functions.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = double.infinity,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double width;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);

    final Color bgColor = isDark
        ? AdipsPalette.darkPrimaryButtonBackground
        : AdipsPalette.lightPrimaryButtonBackground;

    final Color shadowColor = isDark
        ? Colors.black.withOpacity(0.5)
        : AdipsPalette.lightPrimaryButtonBackground.withOpacity(0.4);

    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return bgColor.withOpacity(0.5);
            }
            return bgColor;
          }),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shadowColor: WidgetStatePropertyAll(shadowColor),
          elevation: const WidgetStatePropertyAll(AdipsSizes.buttonElevation),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: AdipsSizes.sm),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AdipsSizes.buttonRadius),
              side: BorderSide.none,
            ),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          text,
          style: const TextStyle(
            fontSize: AdipsSizes.fontSizesMd,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}