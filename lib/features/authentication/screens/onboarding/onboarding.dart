import 'package:adips/features/authentication/controllers/onboarding/onboarding_controller.dart';
import 'package:adips/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:adips/features/authentication/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:adips/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:adips/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:adips/utils/constants/image_strings.dart';
import 'package:adips/utils/constants/text_strings.dart';
import 'package:adips/utils/device/device_utility.dart';
import 'package:adips/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/sizes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final controller = Get.put(OnboardingController());
    return Scaffold(
      body: Stack(
        children: [
          // Adips Logo
          Positioned(
            top: AdipsDeviceUtils.getAppBarHeight(),
            left: AdipsSizes.defaultSpace,
            child: Row(
              children: [
                Image(
                  image: isDark
                      ? AssetImage(AdipsImages.darkFullLogo)
                      : AssetImage(AdipsImages.lightFullLogo),
                  width: AdipsSizes.logoMd,
                  height: AdipsSizes.logoMd,
                ),
              ],
            ),
          ),
          // Horizontal scrollable pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: [
              OnboardingPage(
                image: isDark
                    ? AdipsImages.onBoardingImageDark1
                    : AdipsImages.onBoardingImageLight1,
                title: AdipsText.onBoardingTitle1,
                title2: AdipsText.onBoardingTitle1a,
                subTitle: AdipsText.onBoardingSubTitle1,
              ),
              OnboardingPage(
                image: isDark
                    ? AdipsImages.onBoardingImageDark2
                    : AdipsImages.onBoardingImageLight2,
                title: AdipsText.onBoardingTitle2,
                title2: AdipsText.onBoardingTitle2a,
                subTitle: AdipsText.onBoardingSubTitle2,
              ),
              OnboardingPage(
                image: isDark
                    ? AdipsImages.onBoardingImageDark3
                    : AdipsImages.onBoardingImageLight3,
                title: AdipsText.onBoardingTitle3,
                title2: AdipsText.onBoardingTitle3a,
                subTitle: AdipsText.onBoardingSubTitle3,
              ),
            ],
          ),
          // Skip Button
          const OnBoardSkip(),
          // Dot Navigation SmoothPageIndicator
          const OnBoardingDotNavigation(),
          // next link Button
          const OnBoardNextButton(),
        ],
      ),
    );
  }
}