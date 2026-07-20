import 'package:adips/utils/constants/image_strings.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: AssetImage(
                  isDark
                      ? AdipsImages.darkAppLogo
                      : AdipsImages.lightAppLogo,
                ),
                height: AdipsSizes.logoMd,
              ),
              Text(
                "Adips",
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText
                ),
              ),
              const SizedBox(height: AdipsSizes.xs),
              SizedBox(
                width: 200,
                child: Text(
                  "Manage your finance smartly with Adips",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AdipsSizes.fontSizesMd,
                    color: isDark ? AdipsPalette.darkSubtext : AdipsPalette.lightSubtext,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AdipsSizes.spaceBtwSections),
      ],
    );
  }
}