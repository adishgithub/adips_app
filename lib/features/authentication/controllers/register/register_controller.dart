import 'package:adips/utils/http/http_client.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  static RegisterController get instance => Get.find();

  RxBool isLoading = false.obs;

  Future<void> register({
    required GlobalKey<FormState> formKey,
    required String name,
    required String email,
    required String password,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;

    try {
      // POST https://adips-backend.onrender.com/api/v1/users/signup
      final response = await AdipsHttpHelper.post('/api/v1/users/signup', {
        'name': name,
        'email': email,
        'password': password,
      });

      // Response shape: { success, message, data: { id, name, email } }
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
}