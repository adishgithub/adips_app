import '../../../controllers/onboarding/onboarding_controller.dart';
import 'package:flutter/material.dart';
import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';

class OnBoardSkip extends StatelessWidget {
  const OnBoardSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: AdipsDeviceUtils.getBottomNavBarHeight(),
      left: AdipsSizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnboardingController.instance.skipPage(), // fix: removed {}
        style: TextButton.styleFrom(
          foregroundColor: AdipsPalette.onboardSecondary,
        ),
        child: const Text('Skip'),
      ),
    );
  }
}