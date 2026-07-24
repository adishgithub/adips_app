import 'package:adips/common/widgets/buttons/custom_elevated_button.dart';
import 'package:adips/common/widgets/buttons/custom_text_link_button.dart';
import 'package:adips/common/widgets/text_fields/custom_text_field.dart';
import 'package:adips/features/authentication/controllers/login/login_controller.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:adips/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AdipsSizes.defaultSpace),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email
            CustomTextField(
              controller: _emailController,
              labelText: "Email",
              hintText: "Enter your email",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: AdipsValidator.validateEmail,
            ),
            const SizedBox(height: AdipsSizes.spaceBtwInputFields),

            // Password
            CustomTextField(
              controller: _passwordController,
              labelText: "Password",
              hintText: "Enter your password",
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixIconTap: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              validator: AdipsValidator.validatePassword,
            ),
            const SizedBox(height: AdipsSizes.lg),

            const SizedBox(height: AdipsSizes.spaceBtwItems),

            // Login button
            Obx(
                  () => CustomButton(
                text: "Login",
                isLoading: controller.isLoading.value,
                onPressed: () => controller.login(
                  formKey: _formKey,
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                ),
              ),
            ),
            const SizedBox(height: AdipsSizes.spaceBtwItems),

            // Create account
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  CustomTextLinkButton(
                    text: "Create Account",
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.toNamed('/register');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}