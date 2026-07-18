import 'package:flutter/material.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.image,
    required this.title,
    required this.title2,
    required this.subTitle,
  });

  final String image, title, title2, subTitle;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);

    return Padding(
      padding: const EdgeInsets.all(AdipsSizes.defaultSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top spacer to push image below the logo
          SizedBox(
            height:
            AdipsDeviceUtils.getAppBarHeight() +
                AdipsSizes.logoMd +
                AdipsSizes.spaceBtwItems,
          ),

          // Illustration
          Center(
            child: Image(
              image: AssetImage(image),
              width: AdipsHelperFunctions.screenWidth() * 0.80,
              height: AdipsHelperFunctions.screenHeight() * 0.45,
              fit: BoxFit.contain,
            ),
          ),

          const Spacer(),

          // Title using RichText so both parts are same size & wrap naturally
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AdipsPalette.darkTextPrimary
                    : AdipsPalette.lightTextPrimary,
              ),
              children: [
                TextSpan(text: title),
                TextSpan(
                  text: title2,
                  style: TextStyle(
                    color: AdipsPalette.onboardSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AdipsSizes.spaceBtwItems),

          // Subtitle
          Text(
            subTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AdipsPalette.darkTextMuted
                  : AdipsPalette.lightTextMuted,
            ),
          ),

          // Bottom padding so Skip button doesn't overlap
          SizedBox(height: AdipsDeviceUtils.getBottomNavBarHeight() + 48),
        ],
      ),
    );
  }
}
