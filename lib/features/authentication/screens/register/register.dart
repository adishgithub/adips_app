import 'package:adips/features/authentication/screens/register/widgets/register_form.dart';
import 'package:adips/utils/constants/image_strings.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AdipsSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image(
                  image: const AssetImage(AdipsImages.lightFullLogo),
                  height: AdipsSizes.logoMd,
                ),
              ),
              const SizedBox(height: AdipsSizes.spaceBtwSections),
              const Text(
                "Create your account",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AdipsSizes.xs),
              const Text(
                "Register to start managing your personal finance",
                style: TextStyle(fontSize: AdipsSizes.fontSizesMd, color: Colors.grey),
              ),
              const SizedBox(height: AdipsSizes.spaceBtwSections),
              const RegisterForm(),
            ],
          ),
        ),
      ),
    );
  }
}