import 'package:adips/features/authentication/screens/login/widgets/login_form.dart';
import 'package:adips/features/authentication/screens/login/widgets/login_header.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import '../widgets/auth_background.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthTheme.getAuthBackground(
      context, // required positional arg
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginRegisterHeader(),
          SizedBox(height: AdipsSizes.spaceBtwSections),
          LoginForm(),
        ],
      ),
    );
  }
}