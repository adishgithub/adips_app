import 'package:adips/app.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

///Entry point of adips app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Local Storage
  await GetStorage.init();

  // Todo: Await Native Splash
  // Todo: Initialize Authentication

  runApp(const App());
}