import 'package:adips/features/authentication/screens/register/widgets/register_form.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

import '../login/widgets/login_header.dart';
import '../widgets/auth_background.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthTheme.getAuthBackground(
      context,
      child: const Padding(
        padding: EdgeInsets.all(AdipsSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LoginRegisterHeader(),
            SizedBox(height: AdipsSizes.spaceBtwSections),
            RegisterForm(),
          ],
        ),
      ),
    );
  }
}