import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/local_storage/storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  static LoginController get instance => Get.find();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RxBool isLoading = false.obs;

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Dismiss the keyboard/caret before doing anything that might rebuild
    // or replace this screen. Without this, a pending caret-position frame
    // callback can fire against a TextFormField that's already been torn
    // down by navigation, throwing:
    // "'attached': is not true" on RenderObject.getTransformTo.
    FocusManager.instance.primaryFocus?.unfocus();

    isLoading.value = true;

    try {
      // POST https://adips-backend.onrender.com/login
      final loginResponse = await AdipsHttpHelper.post('/login', {
        'email': emailController.text.trim(),
        'password': passwordController.text,
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
        'email': emailController.text.trim(),
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

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
