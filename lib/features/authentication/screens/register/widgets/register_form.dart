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

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RegisterController>();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full name
          CustomTextField(
            controller: _fullNameController,
            labelText: "Full Name",
            hintText: "Enter your full name",
            prefixIcon: Icons.person_outline,
            validator: AdipsValidator.validateFullName,
          ),
          const SizedBox(height: AdipsSizes.spaceBtwInputFields),

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
            controller: _confirmPasswordController,
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
            validator: _validateConfirmPassword,
          ),
          const SizedBox(height: AdipsSizes.spaceBtwSections),

          // Register button
          Obx(
                () => CustomButton(
              text: "Create Account",
              isLoading: controller.isLoading.value,
              onPressed: () => controller.register(
                formKey: _formKey,
                name: _fullNameController.text.trim(),
                email: _emailController.text.trim(),
                password: _passwordController.text,
              ),
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