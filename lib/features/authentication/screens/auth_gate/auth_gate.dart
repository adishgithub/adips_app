import 'package:adips/features/authentication/screens/onboarding/onboarding.dart';
import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/local_storage/storage_utility.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shown briefly on app start while we decide where to send the user:
/// - No saved token           -> Onboarding (first run, or logged out)
/// - Saved token still valid  -> straight to Landing (skip onboarding/login)
/// - Saved token expired/bad  -> Login (skip onboarding — they already have
///                                an account, just need to sign back in)
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Defer to after the first frame so the navigator is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveStartRoute());
  }

  Future<void> _resolveStartRoute() async {
    final token = AdipsLocalStorage.token;

    if (token == null) {
      Get.offAll(() => const OnboardingScreen());
      return;
    }

    try {
      final validateResponse = await AdipsHttpHelper.get(
        '/validate',
        cookie: 'Authorization=$token',
      );
      final user = validateResponse['user'] as Map<String, dynamic>? ?? {};
      final fullName = (user['Name'] ?? user['name'] ?? '').toString();
      final email = (user['Email'] ?? user['email'] ?? '').toString();

      Get.offAllNamed('/landing', arguments: {
        'fullName': fullName,
        'email': email,
      });
    } catch (_) {
      // Token missing/expired/invalid, or the request failed — clear it
      // and fall back to Login rather than Onboarding.
      await AdipsLocalStorage.clearToken();
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}