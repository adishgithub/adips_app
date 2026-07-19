import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/local_storage/storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  RxBool isLoading = false.obs;

  Future<void> login({
    required GlobalKey<FormState> formKey,
    required String email,
    required String password,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;

    try {
      // POST https://adips-backend.onrender.com/api/v1/users/login
      // Response: { success, message, data: { token, user: { id, name, email } } }
      final loginResponse = await AdipsHttpHelper.post('/api/v1/users/login', {
        'email': email,
        'password': password,
      });

      final data = AdipsHttpHelper.data(loginResponse);
      final String? token = data['token'] as String?;
      if (token == null) {
        throw Exception('No token returned by server');
      }
      await AdipsLocalStorage.saveToken(token);

      // Login already returns the user's name/email directly, so we
      // no longer need a separate /validate round trip here.
      final user = data['user'] as Map<String, dynamic>? ?? {};
      final String fullName = (user['name'] ?? '').toString();

      Get.offAllNamed('/landing', arguments: {
        'fullName': fullName,
        'email': email,
      });
    } catch (e) {
      Get.snackbar(
        'Login failed',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}