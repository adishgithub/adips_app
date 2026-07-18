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
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Email
          CustomTextField(
            controller: controller.emailController,
            labelText: "Email",
            hintText: "Enter your email",
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: AdipsValidator.validateEmail,
          ),
          const SizedBox(height: AdipsSizes.spaceBtwInputFields),

          // Password
          Obx(
                () => CustomTextField(
              controller: controller.passwordController,
              labelText: "Password",
              hintText: "Enter your password",
              prefixIcon: Icons.lock_outline,
              obscureText: controller.obscurePassword.value,
              suffixIcon: controller.obscurePassword.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              onSuffixIconTap: controller.togglePasswordVisibility,
              validator: AdipsValidator.validatePassword,
            ),
          ),
          const SizedBox(height: AdipsSizes.sm),

          // Forgot password
          // CustomTextLinkButton(
          //   text: "Forgot password?",
          //   onPressed: () {
          //     // TODO: Navigate to forgot password screen
          //   },
          // ),
          const SizedBox(height: AdipsSizes.spaceBtwItems),

          // Login button
          Obx(
                () => CustomButton(
              text: "Login",
              isLoading: controller.isLoading.value,
              onPressed: controller.login,
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
                  onPressed: () => Get.toNamed('/register'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}