import 'package:adips/features/authentication/screens/login/widgets/login_form.dart';
import 'package:adips/features/authentication/screens/login/widgets/login_header.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/helpers/helper_functions.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final bool isDark = AdipsHelperFunctions.isDarkMode(context);

    return Scaffold(

      backgroundColor: isDark
          ? AdipsPalette.darkBackground
          : AdipsPalette.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AdipsSizes.defaultSpace),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LoginHeader(),
              SizedBox(height: AdipsSizes.spaceBtwSections),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}