import 'package:adips/common/widgets/buttons/custom_elevated_button.dart';
import 'package:adips/common/widgets/buttons/custom_text_link_button.dart';
import 'package:adips/common/widgets/text_fields/custom_text_field.dart';
import 'package:adips/features/authentication/controllers/register/register_controller.dart';
import 'package:adips/utils/constants/sizes.dart';
import 'package:adips/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  // Local UI-only state — kept out of Obx/GetX so toggling visibility
  // doesn't tear down and rebuild the TextFormField's RenderEditable
  // mid-frame, which was causing:
  // "'attached': is not true" on RenderObject.getTransformTo.
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();

    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full name
          CustomTextField(
            controller: controller.fullNameController,
            labelText: "Full Name",
            hintText: "Enter your full name",
            prefixIcon: Icons.person_outline,
            validator: AdipsValidator.validateFullName,
          ),
          const SizedBox(height: AdipsSizes.spaceBtwInputFields),

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
          CustomTextField(
            controller: controller.passwordController,
            labelText: "Password",
            hintText: "Create a password",
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
          const SizedBox(height: AdipsSizes.spaceBtwInputFields),

          // Confirm password
          CustomTextField(
            controller: controller.confirmPasswordController,
            labelText: "Confirm Password",
            hintText: "Re-enter your password",
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: _obscureConfirmPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            onSuffixIconTap: () {
              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
            },
            validator: controller.validateConfirmPassword,
          ),
          const SizedBox(height: AdipsSizes.spaceBtwSections),

          // Register button
          Obx(
                () => CustomButton(
              text: "Create Account",
              isLoading: controller.isLoading.value,
              onPressed: controller.register,
            ),
          ),
          const SizedBox(height: AdipsSizes.spaceBtwItems),

          // Back to login
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?"),
                CustomTextLinkButton(
                  text: "Login",
                  onPressed: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
