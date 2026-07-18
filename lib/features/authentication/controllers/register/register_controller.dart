import 'package:adips/utils/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  static RegisterController get instance => Get.find();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final fullNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool obscurePassword = true.obs;
  RxBool obscureConfirmPassword = true.obs;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      // POST https://adips-backend.onrender.com/signup
      // Backend expects "name", not "fullName".
      final response = await AdipsHttpHelper.post('/signup', {
        'name': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });

      // Response shape: {success, message, user: {id, name, email}}
      Get.snackbar(
        'Success',
        'Account created! Please log in.',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Signup does not log the user in (no token returned), so send
      // them to Login rather than straight to the landing page.
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Registration failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}