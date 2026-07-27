import 'package:adips/features/authentication/controllers/home/home_binding.dart';
import 'package:adips/features/authentication/controllers/login/login_binding.dart';
import 'package:adips/features/authentication/controllers/register/register_binding.dart';
import 'package:adips/features/authentication/screens/login/login.dart';
import 'package:adips/features/authentication/screens/onboarding/onboarding.dart';
import 'package:adips/features/authentication/screens/register/register.dart';
import 'package:adips/features/settings/screens/settings_screen.dart';
import 'package:adips/screens/Dashboard.dart';
import 'package:adips/utils/startup/start_destination.dart';
import 'package:adips/utils/theme/adips_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import 'features/authentication/screens/homepage/home.dart';

/// -- Use This class to setup themes, initial binding, any animation and much more

class App extends StatelessWidget {
  const App({super.key, required this.startDestination});

  final StartDestination startDestination;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AdipsAppTheme.lightTheme,
      darkTheme: AdipsAppTheme.darkTheme,
      home: _StartupRouter(destination: startDestination),
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          binding: LoginBinding(),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
          binding: RegisterBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeScreen(),
          binding: HomeBinding(),
        ),
        GetPage(name: '/settings', page: () => const SettingsScreen()),
        GetPage(name: '/dashboard', page: () => const Dashboard()),
      ],
    );
  }
}

/// Forwards straight to the resolved start screen using normal GetX
/// navigation (so route bindings/arguments work exactly like any other
/// navigation), then removes the native splash. The native splash (see
/// splash.yaml / main.dart) stays on screen the entire time this happens,
/// so the user never actually sees this widget — it's covered the whole
/// time, and the background here matches the splash background as a
/// fallback in case a frame renders before the redirect fires.
class _StartupRouter extends StatefulWidget {
  const _StartupRouter({required this.destination});

  final StartDestination destination;

  @override
  State<_StartupRouter> createState() => _StartupRouterState();
}

class _StartupRouterState extends State<_StartupRouter> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirect());
  }

  void _redirect() {
    try {
      switch (widget.destination.route) {
        case StartRoute.onboarding:
          Get.offAll(() => const OnboardingScreen());
          break;
        case StartRoute.login:
          Get.offAllNamed('/login');
          break;
        case StartRoute.home:
          Get.offAllNamed('/home', arguments: widget.destination.arguments);
          break;
      }
    } finally {
      // Always remove the splash, even if navigation above throws for any
      // reason (bad/unregistered route, etc.) — the user should never get
      // stuck staring at the splash screen.
      FlutterNativeSplash.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121A26) : const Color(0xFFF7F9FC),
    );
  }
}