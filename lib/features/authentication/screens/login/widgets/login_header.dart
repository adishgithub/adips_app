import 'package:adips/utils/constants/image_strings.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image(
            image: const AssetImage(AdipsImages.lightFullLogo),
            height: AdipsSizes.logolg,
          ),
        ),
        const SizedBox(height: AdipsSizes.spaceBtwSections),
        const Text(
          "Welcome back",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AdipsSizes.xs),
        const Text(
          "Manage your finance using Adips",
          style: TextStyle(fontSize: AdipsSizes.fontSizesMd, color: Colors.grey),
        ),
      ],
    );
  }
}