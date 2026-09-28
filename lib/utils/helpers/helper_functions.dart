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

  /// Symbol for a 3-letter currency code; unknown codes fall back to
  /// the code itself ("CHF"), so nothing is ever shown wrongly as ₹.
  static String symbolFor(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency.toUpperCase();
    }
  }

  /// Icon for an amount field's prefix. Material has no icons for
  /// most currencies, so unknown codes get a neutral payments icon.
  static IconData iconFor(String currency) {
    switch (currency.toUpperCase()) {
      case 'INR':
        return Icons.currency_rupee;
      case 'USD':
        return Icons.attach_money;
      case 'EUR':
        return Icons.euro;
      case 'GBP':
        return Icons.currency_pound;
      default:
        return Icons.payments_outlined;
    }
  }

  /// "₹1,234.50" — symbol + formatted amount for [currency].
  static String money(double amount, String currency) {
    final symbol = symbolFor(currency);
    // Codes (unknown currencies) read better with a space: "CHF 10.00".
    final sep = symbol.length > 1 ? ' ' : '';
    return '$symbol$sep${formatCurrency(amount)}';
  }
}