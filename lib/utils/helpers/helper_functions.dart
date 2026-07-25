import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class AdipsHelperFunctions {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Size screenSize() {
    return MediaQuery.of(Get.context!).size;
  }

  static double screenHeight() {
    return MediaQuery.of(Get.context!).size.height;
  }

  static double screenWidth() {
    return MediaQuery.of(Get.context!).size.width;
  }
}

class AdipsFormatters {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.decimalPatternDigits(
      locale: 'en_IN',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }
}