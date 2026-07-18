import 'package:adips/features/authentication/screens/login/login.dart';
import 'package:adips/features/authentication/screens/onboarding/onboarding.dart';
import 'package:adips/features/authentication/screens/register/register.dart';
import 'package:adips/features/dashboard/screens/landing/landing.dart';
import 'package:adips/utils/theme/adips_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

/// -- Use This class to setup themes, initial binding, any animation and much more

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AdipsAppTheme.lightTheme,
      darkTheme: AdipsAppTheme.darkTheme,
      home: const OnboardingScreen(),
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/landing', page: () => const LandingScreen()),
      ],
    );
  }
}