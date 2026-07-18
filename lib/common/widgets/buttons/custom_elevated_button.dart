import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

/// A basic, reusable primary/elevated button.
/// No dark/light mode handling — plain fixed colors only.
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
    return SizedBox(
      width: width,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.blue.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: AdipsSizes.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AdipsSizes.buttonRadius),
          ),
          elevation: AdipsSizes.buttonElevation,
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