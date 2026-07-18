import '../../../controllers/onboarding/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/device/device_utility.dart';

class OnBoardNextButton extends StatelessWidget {
  const OnBoardNextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = OnboardingController.instance;
    return Positioned(
      right: AdipsSizes.defaultSpace,
      bottom: AdipsDeviceUtils.getBottomNavBarHeight(),
      child: Obx(
            () => TextButton(
          onPressed: controller.nextPage,
          style: TextButton.styleFrom(
            foregroundColor: AdipsPalette.onboardSecondary,
          ),
          child: Row(
            children: [
              Text(controller.currentPageIndex.value == 2 ? "Get Started " : "Next "),
              Icon(controller.currentPageIndex.value == 2
                  ? Iconsax.arrow_right_1
                  : Iconsax.arrow_right_4),
            ],
          ),
        ),
      ),
    );
  }
}