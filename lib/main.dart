import 'package:adips/app.dart';
import 'package:adips/utils/startup/start_destination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';

///Entry point of adips app
void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keep the native splash screen (see splash.yaml) on screen while we
  // do startup work below, instead of letting it disappear into a blank
  // frame or a separate in-app loading screen.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Init Local Storage
  await GetStorage.init();

  // Decide where the app should land (Onboarding / Login / Landing)
  // before the first widget is even built.
  final startDestination = await resolveStartDestination();

  runApp(App(startDestination: startDestination));
}