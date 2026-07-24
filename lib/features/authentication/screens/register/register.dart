import 'package:adips/features/authentication/screens/register/widgets/register_form.dart';
import 'package:adips/utils/constants/adips_palette.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

import '../../../../utils/helpers/helper_functions.dart';
import '../login/widgets/login_header.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              LoginRegisterHeader(),
              SizedBox(height: AdipsSizes.spaceBtwSections),
              RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}