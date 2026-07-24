import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/adips_palette.dart';
import '../../../utils/helpers/helper_functions.dart';

/// A basic, reusable text field.
/// No dark/light mode handling — plain fixed colors only.
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {

    final bool isDark = AdipsHelperFunctions.isDarkMode(context);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText
        ),
        floatingLabelStyle: TextStyle(
            color: isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText
        ),
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon,color: isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText) : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
          icon: Icon(suffixIcon),
          onPressed: onSuffixIconTap,
          color: isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText,
        )
            : null,
        filled: true,
        fillColor: isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AdipsSizes.inputFieldContentPadding,
          vertical: AdipsSizes.inputFieldContentPadding,
        ),
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: BorderSide(color: isDark ? AdipsPalette.darkTextField : AdipsPalette.lightTextField),
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: BorderSide(color: isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: BorderSide(color: isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine, width: 1.5),
        ),
        errorBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(AdipsSizes.inputFieldRadius),
          borderSide: const BorderSide(color: Colors.red)
        )
      ),
    );
  }
}