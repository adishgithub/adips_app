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
      // POST https://adips-backend.onrender.com/login
      final loginResponse = await AdipsHttpHelper.post('/login', {
        'email': email,
        'password': password,
      });

      final String? token = loginResponse['token'] as String?;
      if (token == null) {
        throw Exception('No token returned by server');
      }
      await AdipsLocalStorage.saveToken(token);

      // The login response only contains a token, not the user's name,
      // so fetch the full profile with a manually-attached auth cookie
      // (see the note in http_client.dart on why it's a cookie, not Bearer).
      String fullName = '';
      try {
        final validateResponse = await AdipsHttpHelper.get(
          '/validate',
          cookie: 'Authorization=$token',
        );
        final user = validateResponse['user'] as Map<String, dynamic>? ?? {};
        fullName = (user['Name'] ?? user['name'] ?? '').toString();
      } catch (_) {
        // Non-fatal — proceed to landing even if /validate fails.
      }

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